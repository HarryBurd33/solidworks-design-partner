#!/usr/bin/env python3
"""Check public release structure/integrity; optionally create deterministic ZIP."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parents[1]
NAME = "solidworks-design-partner"
SKILL = ROOT / NAME
MANIFEST = ROOT / "release-manifest.json"


def digest(data):
    return hashlib.sha256(data).hexdigest()


def skill_files():
    result = {}
    for path in sorted(SKILL.rglob("*")):
        if path.is_symlink():
            raise ValueError("Symlink in skill: " + str(path.relative_to(ROOT)))
        if path.is_file():
            rel = path.relative_to(ROOT).as_posix()
            if any(part.startswith(".") or part == "__pycache__" for part in path.relative_to(SKILL).parts):
                raise ValueError("Private/generated skill entry: " + rel)
            result[rel] = digest(path.read_bytes())
    return result


def check():
    errors = []
    text = (SKILL / "SKILL.md").read_text(encoding="utf-8")
    if not text.startswith("---\n") or "\n---\n" not in text[4:]:
        errors.append("Missing front matter")
    else:
        front = text.split("---\n", 2)[1]
        if not re.search(r"^name: " + NAME + r"$", front, re.M):
            errors.append("Metadata/folder name mismatch")
        desc = re.search(r"^description: (.+)$", front, re.M)
        if not desc or not 1 <= len(desc.group(1)) <= 1024:
            errors.append("Invalid description")
    files = skill_files()
    required = ["SKILL.md", "README.md", "LICENSE", "templates/design-brief.md", "references/windows-macros.md", "references/direct-access.md", "references/manual-modeling.md", "references/integrations.md", "examples/SmokePlate.bas", "references/concept-outlines.md", "scripts/render-outline.mjs", "examples/concept-outline.json", "vendor/anatomy/iso-kit.mjs", "vendor/anatomy/LICENSE", "THIRD_PARTY_NOTICES.md"]
    for rel in required:
        if NAME + "/" + rel not in files:
            errors.append("Missing " + rel)
    public = [ROOT / "README.md", ROOT / "LICENSE"] + [ROOT / r for r in files]
    public += [p for folder in ("docs", "scripts", "validation") for p in (ROOT / folder).rglob("*") if p.is_file() and "__pycache__" not in p.parts]
    link_count = 0
    for path in public:
        data = path.read_text(encoding="utf-8")
        if path.suffix == ".md":
            for target in re.findall(r"\]\(([^)]+)\)", data):
                if target.startswith(("https://", "http://", "#")):
                    continue
                target = target.split("#", 1)[0]
                dest = (path.parent / target).resolve()
                if not dest.is_relative_to(ROOT) or not dest.exists():
                    errors.append("Broken/nonportable link in " + str(path.relative_to(ROOT)) + ": " + target)
                link_count += 1
        if re.search(r"gh[pousr]_[A-Za-z0-9]{30,}|sk-[A-Za-z0-9_-]{32,}", data):
            errors.append("Possible credential: " + str(path.relative_to(ROOT)))
        if re.search(r"/" + r"Users/[A-Za-z0-9._-]+/", data):
            errors.append("Private identity/path: " + str(path.relative_to(ROOT)))
    if (SKILL / "LICENSE").read_bytes() != (ROOT / "LICENSE").read_bytes():
        errors.append("License drift")
    return files, errors, link_count


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write-manifest", action="store_true")
    parser.add_argument("--package", action="store_true")
    args = parser.parse_args()
    files, errors, links = check()
    manifest = {"version": "1.1.0", "algorithm": "sha256", "files": files}
    if args.write_manifest and not errors:
        MANIFEST.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    if not MANIFEST.exists() or json.loads(MANIFEST.read_text()) != manifest:
        errors.append("Release manifest missing or drifted; inspect then use --write-manifest")
    output = {"ok": not errors, "skill_files": len(files), "local_links": links, "errors": errors}
    if args.package and not errors:
        archive = ROOT / "dist" / (NAME + "-1.1.0.zip")
        archive.parent.mkdir(exist_ok=True)
        with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
            for rel in files:
                info = zipfile.ZipInfo(rel, (1980, 1, 1, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED
                info.external_attr = 0o100644 << 16
                z.writestr(info, (ROOT / rel).read_bytes())
        with zipfile.ZipFile(archive) as z:
            assert z.testzip() is None
            assert z.namelist() == list(files)
            assert {rel: digest(z.read(rel)) for rel in z.namelist()} == files
        output.update(zip=str(archive.relative_to(ROOT)), zip_sha256=digest(archive.read_bytes()), zip_verified=True)
    print(json.dumps(output, indent=2))
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
