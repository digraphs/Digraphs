"""Shared utilities for planarity testing

Functions:
    PLANARITY_ALGORITHM_SPECIFIERS() -> tuple[str, ...]
    EDGE_DELETION_ANALYSIS_SPECIFIERS() -> tuple[str, ...]
    GRAPH_FORMAT_SPECIFIERS() -> dict[str, str]
    max_num_edges_for_order(order: int) -> int
    g6_header() -> str
    g6_suffix() -> str
    LEDA_header() -> str
    determine_input_filetype(infile_path: Path) -> str
    is_path_to_executable(executable_path: Path) -> bool
    parse_range(value: str) -> tuple[int, ...]
    raise_on_duplicates(ordered_pairs: list[tuple[Any, Any]]) -> Optional[Any]

"""

__all__ = [
    "PLANARITY_ALGORITHM_SPECIFIERS",
    "EDGE_DELETION_ANALYSIS_SPECIFIERS",
    "GRAPH_FORMAT_SPECIFIERS",
    "max_num_edges_for_order",
    "g6_header",
    "g6_suffix",
    "LEDA_header",
    "determine_input_filetype",
    "is_path_to_executable",
    "parse_range",
    "raise_on_duplicates",
]

import re
from pathlib import Path
import shutil
from typing import Any, Optional


def PLANARITY_ALGORITHM_SPECIFIERS() -> tuple[str, ...]:
    """Returns immutable tuple containing algorithm command specifiers"""
    return ("p", "d", "o", "2", "3", "4")


def EDGE_DELETION_ANALYSIS_SPECIFIERS() -> tuple[str, ...]:
    """Allowed algorithm command specifiers for edge-deletion analysis"""
    return ("2", "3", "4")


def GRAPH_FORMAT_SPECIFIERS() -> dict[str, str]:
    """Returns dict containing graph format specifiers mapped to extensions"""
    return {"g": "G6", "a": "AdjList", "m": "AdjMat"}


def max_num_edges_for_order(order: int) -> int:
    """Returns max number of edges possible for given graph order"""
    return (int)((order * (order - 1)) / 2)


def g6_header() -> str:
    """Returns expected .g6 file header string"""
    return ">>graph6<<"


def g6_suffix() -> str:
    """Returns expected .g6 file suffix"""
    return ".g6"


def LEDA_header() -> str:
    """Returns expected LEDA file header string"""
    return "LEDA.GRAPH"


def determine_input_filetype(infile_path: Path) -> str:
    """Determine input filetype

    Args:
        infile_path: Path to graph input file

    Returns:
        str: One of 'LEDA', 'AdjList', 'AdjMat', or 'G6'

    Raises:
        ValueError: If infile doesn't exist, if it is empty, or if unable to
            determine the input file encoding
    """
    if not infile_path.is_file():
        raise ValueError(f"'{infile_path}' doesn't exist.")

    with open(infile_path, "r", encoding="utf-8") as infile:
        first_line = infile.readline()
        if not first_line:
            raise ValueError(f"'{infile_path}' is empty.")
        if LEDA_header() in first_line:
            return "LEDA"
        if re.match(r"N=(\d+)", first_line):
            return "AdjList"
        if first_line[0].isdigit():
            return "AdjMat"
        if infile_path.suffix == g6_suffix() and (
            (first_line.find(g6_header()) == 0)
            or (ord(first_line[0]) >= 63 and ord(first_line[0]) <= 126)
        ):
            return "G6"

        raise ValueError(f"Unable to determine filetype of '{infile_path}'.")


def is_path_to_executable(executable_path: Path) -> bool:
    """Determine if Path corresponds to an executable

    Args:
        executable_path: Path for which we wish to determine whether it
            corresponds to an executable

    Returns:
        bool indicating whether (True) or not (False) the executable_path
            corresponds to an executable.
    """
    if (
        not executable_path
        or not isinstance(executable_path, Path)
        or not shutil.which(str(executable_path.resolve()))
    ):
        return False
    return True


def parse_range(value: str) -> tuple[int, ...]:
    """Parse a single integer or a range of integers.

    Args:
        value: A string of the form 'X[,Y]', i.e. either a single value for the
            desired order X, or an interval inclusive of the endpoints [X, Y]

    Returns:
        A tuple containing either a single element, X, or every integer from X
        up to and including Y

    Raises:
        ValueError: if input string does not correspond to range notation, or
            if range endpoints (or singleton) aren't integers
    """
    separator = ","
    if separator in value:
        if value.count(separator) > 1:
            raise ValueError(
                f"Invalid range '{value}' contains multiple commas; range "
                "should be of the form 'X,Y'"
            )

        start, end = value.split(separator)
        try:
            start, end = int(start), int(end)
        except ValueError as int_cast_error:
            raise ValueError(
                f"Invalid range '{value}': both start and end values must be "
                "integers."
            ) from int_cast_error

        if start > end:
            raise ValueError(
                f"Invalid range '{value}': start value must not be greater "
                "than end value."
            )
        # Transforms to interval that includes endpoints: '5,8' corresponds to
        # the tuple (5, 6, 7, 8)
        return tuple(range(start, end + 1))

    try:
        return (int(value),)
    except ValueError as int_cast_error:
        raise ValueError(
            f"Invalid order specifier '{value}': should be a single "
            "integer 'X'"
        ) from int_cast_error


def raise_on_duplicates(ordered_pairs: list[tuple[Any, Any]]) -> Optional[Any]:
    """Reject duplicate keys."""
    d = {}
    for k, v in ordered_pairs:
        if k in d:
            raise ValueError(f"Duplicate key: {k}")
        d[k] = v
    return d
