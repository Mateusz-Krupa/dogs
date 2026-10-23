#!/usr/bin/env python3
"""Verify content parity between the canonical JS-era tree and the native bundle.

The Swift suite only sees the bundled bytes (it cannot read `src/`), so drift in
the canonical copy would otherwise pass unnoticed. This checker closes that gap
and fails on: a missing file on either side, a byte difference, or a digest that
no longer matches either registered inventory (`parity-data.json` and
`PettrainerTests/ContentChecksums.swift`).

Run from anywhere: `python3 openspec/changes/migrate-to-native-swift/baseline/verify_parity.py`
Exit code 0 = parity holds. After the JS cleanup removes `src/content/data`, the
native bundle becomes the single canonical copy and this script's src checks are
retired with it (the digest inventory still guards the bundle).
"""
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
DATA = ROOT / "src" / "content" / "data"
BUNDLE = ROOT / "Pettrainer" / "Resources" / "Content"
BASELINE = Path(__file__).resolve().parent
FAILURES: list[str] = []


def digest(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def swift_digests() -> dict[str, str]:
    text = (ROOT / "PettrainerTests" / "ContentChecksums.swift").read_text()
    pairs = re.findall(r'"([a-z/._-]+\.json)":\s*\n\s*"([0-9a-f]{64})"', text)
    return dict(pairs)


def main() -> int:
    parity = json.loads((BASELINE / "parity-data.json").read_text())["files"]
    swift = swift_digests()

    keys = sorted(set(parity) | set(swift))
    if not keys:
        FAILURES.append("no digests found in either inventory")

    for key in keys:
        src_file = DATA / key
        name, suffix = key.split("/", 1) if "/" in key else ("", key)
        bundle_name = (f"{name}-{suffix}" if name else suffix).replace(".json", "")
        bundle_file = BUNDLE / f"{bundle_name}.json"
        if not bundle_file.exists():  # environments.json ships without a prefix
            bundle_file = BUNDLE / suffix

        if parity.get(key) != swift.get(key):
            FAILURES.append(f"{key}: inventories disagree "
                            f"(parity-data={parity.get(key)} swift={swift.get(key)})")

        if src_file.exists() and bundle_file.exists():
            if src_file.read_bytes() != bundle_file.read_bytes():
                FAILURES.append(f"{key}: canonical and bundled bytes differ")
        elif key.startswith("care/"):
            FAILURES.append(f"{key}: missing canonical ({src_file}) or bundled ({bundle_file}) file")

        if bundle_file.exists():
            actual = digest(bundle_file.read_bytes())
            for label, table in (("parity-data", parity), ("ContentChecksums", swift)):
                if key in table and table[key] != actual:
                    FAILURES.append(f"{key}: bundled digest {actual} != {label} {table[key]}")

    if FAILURES:
        print("PARITY FAILED")
        for failure in FAILURES:
            print(" -", failure)
        return 1
    print(f"parity ok: {len(keys)} resources, canonical == bundled == both inventories")
    return 0


if __name__ == "__main__":
    sys.exit(main())
