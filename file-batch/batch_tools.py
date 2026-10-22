#!/usr/bin/env python3
"""
Batch file utilities for freelance demos:
1) merge-csv  — merge multiple CSVs with the same header
2) rename     — batch-rename files with a sequential prefix

No network, no credentials. Safe to run on sample_input/.
"""

from __future__ import annotations

import argparse
import csv
import re
import shutil
import sys
from pathlib import Path


def merge_csv(inputs: list[Path], out_path: Path) -> int:
    if not inputs:
        raise SystemExit("No input CSV files given.")

    header: list[str] | None = None
    rows: list[list[str]] = []
    source_col = "_source_file"

    for path in inputs:
        with path.open(encoding="utf-8-sig", newline="") as f:
            reader = csv.reader(f)
            try:
                this_header = next(reader)
            except StopIteration:
                print(f"skip empty: {path}", file=sys.stderr)
                continue
            if header is None:
                header = this_header + [source_col]
            elif this_header != header[:-1]:
                raise SystemExit(
                    f"Header mismatch in {path.name}:\n"
                    f"  expected {header[:-1]}\n"
                    f"  got      {this_header}"
                )
            for row in reader:
                if not any(cell.strip() for cell in row):
                    continue
                rows.append(row + [path.name])

    assert header is not None
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8-sig", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)

    print(f"Merged {len(inputs)} files → {len(rows)} rows → {out_path}")
    return len(rows)


def safe_stem(name: str) -> str:
    stem = Path(name).stem
    stem = re.sub(r"\s+", "_", stem)
    stem = re.sub(r"[^\w\u4e00-\u9fff\-]+", "", stem, flags=re.UNICODE)
    return stem[:40] or "file"


def rename_files(
    src_dir: Path,
    dest_dir: Path,
    prefix: str,
    start: int,
    dry_run: bool,
    copy: bool,
) -> int:
    if not src_dir.is_dir():
        raise SystemExit(f"Not a directory: {src_dir}")

    files = sorted(
        [p for p in src_dir.iterdir() if p.is_file() and not p.name.startswith(".")],
        key=lambda p: p.name.lower(),
    )
    if not files:
        print("No files to rename.", file=sys.stderr)
        return 0

    dest_dir.mkdir(parents=True, exist_ok=True)
    width = max(3, len(str(start + len(files) - 1)))

    for i, src in enumerate(files):
        n = start + i
        new_name = f"{prefix}_{n:0{width}d}{src.suffix.lower()}"
        dest = dest_dir / new_name
        action = "COPY" if copy else "MOVE"
        print(f"{action}: {src.name}  →  {new_name}")
        if dry_run:
            continue
        if copy:
            shutil.copy2(src, dest)
        else:
            shutil.move(str(src), str(dest))

    mode = "dry-run" if dry_run else ("copied" if copy else "moved")
    print(f"Done ({mode}): {len(files)} files → {dest_dir}")
    return len(files)


def cmd_merge(args: argparse.Namespace) -> None:
    inputs = sorted(args.input_dir.glob("*.csv"))
    if args.files:
        inputs = [Path(p) for p in args.files]
    merge_csv(inputs, args.out)


def cmd_rename(args: argparse.Namespace) -> None:
    rename_files(
        src_dir=args.src,
        dest_dir=args.dest,
        prefix=args.prefix,
        start=args.start,
        dry_run=args.dry_run,
        copy=args.copy,
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Batch merge CSV files or rename files with a sequential prefix."
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p_merge = sub.add_parser("merge-csv", help="Merge CSVs that share the same header")
    p_merge.add_argument(
        "--input-dir",
        type=Path,
        default=Path("sample_input"),
        help="Directory of CSV files (default: sample_input)",
    )
    p_merge.add_argument(
        "--files",
        nargs="*",
        help="Explicit list of CSV paths (overrides --input-dir)",
    )
    p_merge.add_argument(
        "--out",
        type=Path,
        default=Path("sample_output/orders_merged.csv"),
        help="Output CSV path",
    )
    p_merge.set_defaults(func=cmd_merge)

    p_rename = sub.add_parser("rename", help="Batch rename files in a folder")
    p_rename.add_argument(
        "--src",
        type=Path,
        default=Path("sample_input/photos_raw"),
        help="Source folder",
    )
    p_rename.add_argument(
        "--dest",
        type=Path,
        default=Path("sample_output/photos_renamed"),
        help="Destination folder",
    )
    p_rename.add_argument("--prefix", default="cafe_shot", help="Filename prefix")
    p_rename.add_argument("--start", type=int, default=1, help="Starting index")
    p_rename.add_argument(
        "--copy",
        action="store_true",
        help="Copy instead of move (safer for demos)",
    )
    p_rename.add_argument(
        "--dry-run",
        action="store_true",
        help="Only print planned renames",
    )
    p_rename.set_defaults(func=cmd_rename)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
