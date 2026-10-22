#!/usr/bin/env python3
"""Generate the parity-manifest data section from the frozen JS baseline.

Reads src/content/data/*.json, catalogue order from src/content/load.ts,
locale keys from src/i18n/locales/*.ts and diagram bindings from src/ui/.
Emits baseline/parity-data.json (machine-checkable) — run from repo root.
"""
import json
import re
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]  # repo root (…/baseline/gen_manifest.py -> repo)
DATA = ROOT / "src/content/data"
OUT = Path(__file__).resolve().parent / "parity-data.json"

# Catalogue order is explicit in load.ts, not filename order.
load_ts = (ROOT / "src/content/load.ts").read_text()

def order_list(const_name, suffix):
    block = re.search(rf"const {const_name}[^=]+=\s*\[(.*?)\];", load_ts, re.S)
    return [m.group(1) + suffix for m in re.finditer(r"'([^']+)\.json'", block.group(1))]

exercise_files = order_list("EXERCISE_FILES", ".json")
nosework_files = order_list("NOSEWORK_FILES", ".json")
behaviour_files = order_list("BEHAVIOUR_FILES", ".json")
# MISTAKE_FILES entries are ['<exerciseId>', rawJson] — order by the first quoted id.
mistake_block = re.search(r"const MISTAKE_FILES[^=]+=\s*\[(.*?)\];", load_ts, re.S).group(1)
mistake_ids = re.findall(r"^\s*\['(\w+)'", mistake_block, re.M)
mistake_files = [f"{i}.json" for i in mistake_ids]

def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def jload(rel):
    return json.loads((DATA / rel).read_text())

manifest = {"source_commit": None, "files": {}}

manifest["files"] = {
    f"exercises/{Path(f).name}": sha(DATA / "exercises" / Path(f).name) for f in exercise_files
}
manifest["files"].update(
    {f"nosework/{Path(f).name}": sha(DATA / "nosework" / Path(f).name) for f in nosework_files}
)
manifest["files"].update(
    {f"behaviour/{Path(f).name}": sha(DATA / "behaviour" / Path(f).name) for f in behaviour_files}
)
manifest["files"].update(
    {f"mistakes/{Path(f).name}": sha(DATA / "mistakes" / Path(f).name) for f in mistake_files}
)
manifest["files"]["environments.json"] = sha(DATA / "environments.json")
manifest["order"] = {
    "exercises": [Path(f).stem for f in exercise_files],
    "nosework": [Path(f).stem for f in nosework_files],
    "behaviour": [Path(f).stem for f in behaviour_files],
    "mistakes": [Path(f).stem for f in mistake_files],
}

env = jload("environments.json")
manifest["environments"] = {
    "count": len(env["rungs"]) if "rungs" in env else len(env.get("environments", env)),
    "raw_keys": sorted(env.keys()) if isinstance(env, dict) else None,
}
# keep the whole environments file small enough to embed verbatim
manifest["environments"]["full"] = env

exercises = {}
for f in exercise_files:
    name = Path(f).stem
    e = jload(f"exercises/{name}.json")
    exercises[name] = {
        "id": e.get("id"),
        "category": e.get("category"),
        "requires": e.get("requires"),
        "gear": e.get("gear"),
        "pose": e.get("pose"),
        "motion": e.get("motion"),
        "sound": e.get("sound"),
        "names": {loc: {k: v for k, v in e.get("names", {}).get(loc, {}).items()} for loc in ("pl", "en")},
        "steps": [
            {
                "ordinal": s.get("ordinal"),
                "pose": s.get("pose"),
                "motion": s.get("motion"),
                "sound": s.get("sound"),
                "copy_fields": {
                    loc: sorted((s.get(loc) or {}).keys()) for loc in ("pl", "en")
                },
            }
            for s in e.get("steps", [])
        ],
    }
manifest["exercises"] = exercises

nosework = {}
for f in nosework_files:
    name = Path(f).stem
    n = jload(f"nosework/{name}.json")
    nosework[name] = {
        "id": n.get("id"),
        "gear": n.get("gear"),
        "pose": n.get("pose"),
        "level_count": len(n.get("levels", [])),
        "level_copy_fields": [sorted((l.get(loc) or {}).keys()) for l in n.get("levels", []) for loc in ("pl", "en")],
    }
manifest["nosework"] = nosework

behaviour = {}
for f in behaviour_files:
    name = Path(f).stem
    b = jload(f"behaviour/{name}.json")
    behaviour[name] = {
        "id": b.get("id"),
        "keys": sorted(b.keys()),
        "scene": b.get("scene"),
        "exercise_links": b.get("exercises") or b.get("related") or b.get("links"),
    }
manifest["behaviour"] = behaviour

mistakes = {}
for f in mistake_files:
    name = Path(f).stem
    m = jload(f"mistakes/{name}.json")
    mistakes[name] = {"count": len(m if isinstance(m, list) else m.get("mistakes", []))}
manifest["mistakes"] = mistakes

# UI locale keys + interpolations (flat key path per nested object).
def locale_keys(path):
    text = path.read_text()
    # match 'key': "…%{var}…" structures crudely: keys and %{...} tokens
    keys = re.findall(r"^\s*(?:'([\w.-]+)'|(\w+))\s*:", text, re.M)
    body = re.sub(r"%\{(\w+)\}", r"<\1>", text)
    interpolations = sorted(set(re.findall(r"%\{(\w+)\}", text)))
    return {
        "raw_len": len(text),
        "top_level_blocks": re.findall(r"^  (\w+): \{", text, re.M),
        "leaf_keys_estimate": sum(1 for _ in re.finditer(r"^\s{4,}\w+: ", text, re.M)),
        "interpolations": interpolations,
    }

manifest["i18n"] = {
    "en": locale_keys(ROOT / "src/i18n/locales/en.ts"),
    "pl": locale_keys(ROOT / "src/i18n/locales/pl.ts"),
}

# Diagram bindings: MOTION_BY_EXERCISE + lure stage rules + pose list.
step_diagram = (ROOT / "src/ui/StepDiagram.tsx").read_text()
manifest["diagrams"] = {
    "motion_by_exercise": dict(
        re.findall(r"(\w+):\s*'([a-z-]+)'", re.search(r"MOTION_BY_EXERCISE[^=]*=\s*\{(.*?)\}", step_diagram, re.S).group(1))
    ),
    "motions_defined": (lambda: sorted(set(re.findall(
        r"'([A-Za-z]+)'",
        re.search(r"MOTION_IDS\s*=\s*\[(.*?)\]\s*as const", (ROOT / "src/content/schema/checks.ts").read_text(), re.S).group(1),
    ))))(),
    "poses_defined": sorted(
        set(re.findall(r"^\s+\| '(\w+)'", (ROOT / "src/ui/DogPose.tsx").read_text(), re.M))
    ),
    "gear_defined": sorted(
        set(re.findall(r"^\s+\| '(\w+)'", (ROOT / "src/ui/Gear.tsx").read_text(), re.M))
    ),
    "lure_stages": (ROOT / "src/ui/lureStages.ts").read_text(),
}

OUT.write_text(json.dumps(manifest, indent=1, ensure_ascii=False))
print("wrote", OUT)
print("files:", len(manifest["files"]), "exercises:", len(exercises), "nosework:", len(nosework), "behaviour:", len(behaviour))
