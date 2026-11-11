#!/usr/bin/env python3


import sys
import re
from pathlib import Path, PosixPath


def is_in_xml_comment(s: str, pos: int) -> bool:
    last_open = s.rfind("<!--", 0, pos)
    last_close = s.rfind("-->", 0, pos)
    return last_open != -1 and last_open > last_close


def extract(path: PosixPath, pattern: re.Pattern) -> dict:
    result = dict()
    content = path.read_text(errors="ignore")
    for i, line in enumerate(content.splitlines(), 1):
        match = pattern.search(line)
        if match:
            result[match.group(1)] = f"{path}:{i}"
    return result


def main() -> int:
    labels, includes = dict(), dict()
    label_pattern = re.compile(r'<#GAPDoc\s+Label\s*=\s*"(\w+)">')
    include_pattern = re.compile(r'<#Include\s+Label\s*=\s*"(\w+)"')
    for path in sorted(Path("doc/").glob("*.xml")):
        if not path.name.startswith("_"):
            labels |= extract(path, label_pattern)
            includes |= extract(path, include_pattern)

    first_print = True
    for label, loc in labels.items():
        if label not in includes:
            if first_print:
                first_print = False
                print(
                    "The following labels were found without a corresponding include:"
                )
            print(f"{loc}: {label}")


if __name__ == "__main__":
    main()
    sys.exit(0)
