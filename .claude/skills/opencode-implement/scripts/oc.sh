#!/usr/bin/env bash
# oc.sh — worktree-isolated opencode runs for pettrainer.
#
# prepare <name>                      make a worktree mirroring the current tree, commit a baseline
# run     <name> <prompt-file> [model|-] [variant]
# summary <name>                      tool calls, messages, tokens; flags truncation and stash use
# diff    <name> [git-diff args...]   what the run changed, against the baseline
# apply   <name>                      put that diff onto the main working tree
# cleanup <name>                      remove the worktree and logs
# list                                active task worktrees
#
# Worktrees and logs live outside the repo so a wiped temp dir cannot take them.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CACHE="${OC_CACHE:-$HOME/.cache/pettrainer-opencode}"
DEFAULT_MODEL="${OC_MODEL:-swissquant-local/vision-flash}"
START_GAP="${OC_START_GAP:-5}"
START_MAX="${OC_START_MAX:-30}"

git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 || { echo "not a git repo: $REPO" >&2; exit 1; }
mkdir -p "$CACHE"

wt_path()  { echo "$CACHE/$1"; }
log_path() { echo "$CACHE/$1.jsonl"; }
err_path() { echo "$CACHE/$1.err"; }

need_wt() {
  local wt; wt="$(wt_path "$1")"
  [ -d "$wt" ] || { echo "no worktree for '$1' — run: oc.sh prepare $1" >&2; exit 1; }
  echo "$wt"
}

# ---------------------------------------------------------------- prepare
cmd_prepare() {
  local name="$1" wt; wt="$(wt_path "$name")"
  [ -e "$wt" ] && { echo "worktree '$name' already exists at $wt" >&2; exit 1; }

  git -C "$REPO" worktree add --detach "$wt" HEAD >/dev/null
  echo "worktree: $wt"

  # Carry over uncommitted tracked changes. Never 'git stash' — the stash stack
  # is shared by every worktree and session.
  local patch="$CACHE/$name.base.patch"
  git -C "$REPO" diff HEAD > "$patch" || true
  if [ -s "$patch" ]; then
    git -C "$wt" apply "$patch" && echo "carried over tracked changes"
  fi
  rm -f "$patch"

  # Carry over untracked, non-ignored files.
  local n=0
  while IFS= read -r -d '' f; do
    mkdir -p "$wt/$(dirname "$f")"
    cp "$REPO/$f" "$wt/$f"
    n=$((n + 1))
  done < <(git -C "$REPO" ls-files --others --exclude-standard -z)
  [ "$n" -gt 0 ] && echo "carried over $n untracked file(s)"

  # Dependencies are expensive to reinstall; share them.
  [ -d "$REPO/node_modules" ] && ln -s "$REPO/node_modules" "$wt/node_modules" && echo "linked node_modules"

  # Baseline commit, so the result diff holds only opencode's work.
  git -C "$wt" add -A -- . ':(exclude)node_modules' >/dev/null 2>&1 || true
  git -C "$wt" -c user.name=oc -c user.email=oc@local \
      commit -q --allow-empty -m "baseline: $name" >/dev/null
  echo "baseline committed — ready"
}

# ---------------------------------------------------------------- run
take_start_lock() {
  local lock="$CACHE/.start.lock" waited=0
  while ! mkdir "$lock" 2>/dev/null; do
    local age; age=$(( $(date +%s) - $(stat -f %m "$lock" 2>/dev/null || echo 0) ))
    if [ "$age" -gt 120 ]; then rm -rf "$lock"; continue; fi
    [ "$waited" -eq 0 ] && echo "waiting for another opencode start..."
    sleep 1; waited=$((waited + 1))
    [ "$waited" -ge "$START_MAX" ] && { rm -rf "$lock"; continue; }
  done
  trap 'rm -rf "'"$lock"'"' RETURN
}

cmd_run() {
  local name="$1" prompt="$2" model="${3:--}" variant="${4:-}"
  local wt; wt="$(need_wt "$name")"
  [ -f "$prompt" ] || { echo "prompt file not found: $prompt" >&2; exit 1; }
  [ "$model" = "-" ] && model="$DEFAULT_MODEL"
  [ -n "$variant" ] && model="$model#$variant"

  # Custom providers (swissquant-local) do not appear in `opencode models`,
  # so a missing name is a warning here, not a failure.
  if ! opencode models 2>/dev/null | grep -qx "${model%%#*}"; then
    echo "note: '${model%%#*}' is not listed by 'opencode models' (normal for a custom provider)"
  fi

  local log err stashes_before
  log="$(log_path "$name")"; err="$(err_path "$name")"
  stashes_before="$(git -C "$REPO" stash list | wc -l | tr -d ' ')"

  echo "model:  $model"
  echo "prompt: $prompt"
  echo "log:    $log"

  ( take_start_lock; sleep "$START_GAP" )

  ( cd "$wt" && opencode run --auto --format json -m "$model" < "$prompt" > "$log" 2> "$err" ) &
  local pid=$!
  echo "started (pid $pid)"

  # Heartbeat keyed to log activity, so a silent stall is visible.
  local last=0 now quiet
  while kill -0 "$pid" 2>/dev/null; do
    sleep 15
    now=$(date +%s)
    local mtime; mtime=$(stat -f %m "$log" 2>/dev/null || echo "$now")
    quiet=$(( now - mtime ))
    if [ "$quiet" -ne "$last" ]; then
      echo "still running, ${quiet}s since last event"
      last="$quiet"
    fi
  done
  wait "$pid"; local rc=$?

  local stashes_after; stashes_after="$(git -C "$REPO" stash list | wc -l | tr -d ' ')"
  [ "$stashes_after" != "$stashes_before" ] && echo "STASH CHANGED — inspect 'git stash list' before applying"

  [ -s "$err" ] && { echo "--- stderr (tail) ---"; tail -5 "$err"; }
  echo "exit=$rc"
  return "$rc"
}

# ---------------------------------------------------------------- summary
cmd_summary() {
  local name="$1" log; log="$(log_path "$name")"
  [ -f "$log" ] || { echo "no log for '$name'" >&2; exit 1; }
  python3 - "$log" <<'PY'
import json, sys
from collections import Counter

path = sys.argv[1]
raw = open(path, encoding="utf-8", errors="replace").read().strip()

events = []
try:
    d = json.loads(raw)
    events = d if isinstance(d, list) else [d]
except json.JSONDecodeError:
    for line in raw.splitlines():
        line = line.strip()
        if line:
            try: events.append(json.loads(line))
            except json.JSONDecodeError: pass

tools, texts, tokens = [], [], {}
truncated = False

def walk(o):
    global truncated
    if isinstance(o, dict):
        t = o.get("type")
        if t == "tool" or isinstance(o.get("tool"), str):
            nm = o.get("tool") or o.get("name")
            if nm: tools.append(str(nm))
        if t == "text" and isinstance(o.get("text"), str):
            texts.append(o["text"])
        for k in ("tokens", "usage"):
            if isinstance(o.get(k), dict):
                for kk, vv in o[k].items():
                    if isinstance(vv, (int, float)): tokens[kk] = tokens.get(kk, 0) + vv
        if o.get("finishReason") in ("length", "max_tokens") or o.get("stopReason") == "max_tokens":
            truncated = True
        for v in o.values(): walk(v)
    elif isinstance(o, list):
        for v in o: walk(v)

for e in events: walk(e)

print(f"events: {len(events)}")
if tools:
    print("tool calls:", ", ".join(f"{k}x{v}" for k, v in Counter(tools).most_common()))
if tokens:
    print("tokens:", ", ".join(f"{k}={int(v)}" for k, v in sorted(tokens.items())))
if truncated:
    print("OUTPUT LIMIT HIT — the run failed mid-answer; retry once, then take it back into Claude")

joined = "\n".join(texts)
if "git stash" in joined:
    print("GIT STASH USED — check 'git stash list' before applying")

print("\n--- messages ---")
for t in texts:
    t = t.strip()
    if t:
        body = t[:600] + " ...[cut]" if len(t) > 600 else t
        print("  " + body.replace("\n", "\n  "))
        print()
if texts:
    print("--- final message (full) ---")
    print(texts[-1].strip())
PY
}

# ---------------------------------------------------------------- diff / apply
cmd_diff() {
  local name="$1"; shift
  local wt; wt="$(need_wt "$name")"
  git -C "$wt" add -A -N -- . ':(exclude)node_modules' >/dev/null 2>&1 || true
  git -C "$wt" diff HEAD -- . ':(exclude)node_modules' "$@"
}

cmd_apply() {
  local name="$1" wt patch
  wt="$(need_wt "$name")"; patch="$CACHE/$name.patch"
  git -C "$wt" add -A -N -- . ':(exclude)node_modules' >/dev/null 2>&1 || true
  git -C "$wt" diff HEAD -- . ':(exclude)node_modules' > "$patch"
  [ -s "$patch" ] || { echo "nothing to apply"; return 0; }

  if ! git -C "$REPO" apply --check "$patch" 2>/dev/null; then
    echo "apply FAILED — patch kept at $patch" >&2
    exit 1
  fi
  git -C "$REPO" apply "$patch"
  echo "applied to $REPO:"
  git -C "$REPO" apply --numstat "$patch" | sed 's/^/  /'
  rm -f "$patch"
}

# ---------------------------------------------------------------- misc
cmd_cleanup() {
  local name="$1" wt; wt="$(wt_path "$name")"
  [ -d "$wt" ] && git -C "$REPO" worktree remove --force "$wt" && echo "removed $wt"
  rm -f "$(log_path "$name")" "$(err_path "$name")" "$CACHE/$name.patch"
  git -C "$REPO" worktree prune
  echo "cleaned up '$name'"
}

cmd_list() {
  echo "cache: $CACHE"
  git -C "$REPO" worktree list | tail -n +2 || true
}

usage() { sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; }

case "${1:-}" in
  prepare) shift; cmd_prepare "$@" ;;
  run)     shift; cmd_run "$@" ;;
  summary) shift; cmd_summary "$@" ;;
  diff)    shift; cmd_diff "$@" ;;
  apply)   shift; cmd_apply "$@" ;;
  cleanup) shift; cmd_cleanup "$@" ;;
  list)    shift; cmd_list "$@" ;;
  *)       usage; exit 1 ;;
esac
