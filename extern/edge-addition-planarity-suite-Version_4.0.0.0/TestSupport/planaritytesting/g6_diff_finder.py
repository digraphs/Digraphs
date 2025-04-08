"""Tools to analyze .g6 files produced by nauty geng

Classes:
    G6DiffFinderException
    G6DiffFinder
"""

#!/usr/bin/env python

__all__ = ["G6DiffFinder", "G6DiffFinderException"]

import os
import sys
import json
import argparse
import logging
from pathlib import Path
from typing import Optional

from planaritytesting_utils import g6_header, determine_input_filetype


class G6DiffFinderException(Exception):
    """
    Custom exception for representing errors that arise when processing two
    .g6 files.
    """

    def __init__(self, message):
        super().__init__(message)
        self.message = message


class G6DiffFinder:
    """Tool to identify the diffs between two .g6 input files."""

    def __init__(
        self,
        first_comparand_infile_path: Path,
        second_comparand_infile_path: Path,
        log_path: Optional[Path] = None,
    ) -> None:
        """
        Initializes G6DiffFinder instance.

        For each .g6 path provided, validates the infile path and then
        populates the corresponding comparand dict.

        Args:
            first_comparand_infile_path: path to a .g6 file
            second_comparand_infile_path: path to a .g6 file

        Raises:
            ValueError: If either first_comparand_infile_path or
                second_comparand_infile_path are invalid
            FileNotFoundError: If _populate_comparand_dict() failed to open
                either input file, re-raise error
        """
        self._setup_logger(log_path)

        try:
            first_comparand_filetype = determine_input_filetype(
                first_comparand_infile_path
            )
        except ValueError as comparand_infile_error:
            raise comparand_infile_error

        if first_comparand_filetype != "G6":
            raise ValueError(
                f"'{first_comparand_infile_path}' is not a .g6 file."
            )

        try:
            self._first_comparand_dict = self._populate_comparand_dict(
                first_comparand_infile_path
            )
        except FileNotFoundError as comparand_infile_not_found_error:
            raise FileNotFoundError(
                "Unable to populate comparand dict: can't open first input file"
            ) from comparand_infile_not_found_error

        try:
            second_comparand_filetype = determine_input_filetype(
                second_comparand_infile_path
            )
        except ValueError as comparand_infile_error:
            raise comparand_infile_error

        if second_comparand_filetype != "G6":
            raise ValueError(
                f"'{second_comparand_infile_path}' is not a .g6 file."
            )

        try:
            self._second_comparand_dict = self._populate_comparand_dict(
                second_comparand_infile_path
            )
        except FileNotFoundError as comparand_infile_not_found_error:
            raise FileNotFoundError(
                "Unable to populate comparand dict: "
                "can't open second input file"
            ) from comparand_infile_not_found_error

    def _setup_logger(self, log_path: Optional[Path] = None) -> None:
        if not log_path:
            test_support_dir = Path(sys.argv[0]).resolve().parent.parent
            g6_diff_finder_logdir = Path.joinpath(
                test_support_dir, "g6_diff_finder_logs"
            )
            Path.mkdir(g6_diff_finder_logdir, parents=True, exist_ok=True)
            log_path = Path.joinpath(g6_diff_finder_logdir, "G6DiffFinder.log")
            if log_path.is_file():
                os.remove(log_path)

        # logging.getLogger() returns the *same instance* of a logger
        # when given the same name. In order to prevent this, must either give
        # a unique name, or must prevent adding additional handlers to the
        # logger
        self.logger = logging.getLogger(__name__ + str(log_path.name))
        self.logger.setLevel(logging.DEBUG)

        if not self.logger.handlers:
            # Create the Handler for logging data to a file
            logger_handler = logging.FileHandler(filename=log_path)
            logger_handler.setLevel(logging.DEBUG)

            # Create a Formatter for formatting the log messages
            logger_formatter = logging.Formatter(
                "%(asctime)s - [%(levelname)s] - %(module)s.%(funcName)s - "
                "%(message)s"
            )

            # Add the Formatter to the Handler
            logger_handler.setFormatter(logger_formatter)

            # Add the Handler to the Logger
            self.logger.addHandler(logger_handler)

    def _populate_comparand_dict(
        self, comparand_infile_path: Path
    ) -> dict[str, Path | dict[str, int | list[int]]]:
        """
        Opens the file corresponding to path comparand_infile_path, then
        iterates over the lines of the file object. If the first line contains
        the .g6 header, it is stripped from the line contents. Then,
        the line contents are stripped of whitespace, after which we check to
        see if the graph encoding already has appeared in the file. If so, we
        add the current line_num to the duplicate_line_nums list corresponding
        to that encoding. If not, we insert a key-value pair into the comparand
        dict corresponding to the graph encoding mapped to a sub-dict with the
        first_line on which the encoding occurs and an empty list of
        duplicate_line_nums in case that same encoding appears again in the
        file.

        Args:
            comparand_infile_path: path to a .g6 file
        Raises:
            FileNotFoundError: If open() fails on comparand_infile_path
        """
        try:
            self.logger.info(
                "Populating comparand dict from infile path '%s'.",
                comparand_infile_path,
            )

            with open(
                comparand_infile_path, "r", encoding="utf-8"
            ) as comparand_infile:
                comparand_dict = {}
                line_num = 1
                for line in comparand_infile:
                    if line_num == 1:
                        line = line.replace(g6_header(), "")
                    line = line.strip()
                    if not line:
                        continue
                    if line in comparand_dict:
                        if not comparand_dict[line].get("duplicate_line_nums"):
                            comparand_dict[line]["duplicate_line_nums"] = []
                        comparand_dict[line]["duplicate_line_nums"].append(
                            line_num
                        )
                    else:
                        comparand_dict[line] = {
                            "first_line": line_num,
                            "duplicate_line_nums": [],
                        }
                    line_num += 1
            comparand_dict["infile_path"] = comparand_infile_path
            return comparand_dict
        except FileNotFoundError as comparand_file_not_found_error:
            raise FileNotFoundError(
                "Unable to open comparand infile with path "
                f"'{comparand_infile_path}'."
            ) from comparand_file_not_found_error

    def output_duplicates(self):
        """Output duplicates in each comparand dict

        Calls self._output_duplicates() for each comparand dict so that we have
        two separate output files containing the duplicates within their
        respective .g6 input files.

        Raises:
            G6DiffFinderException: Re-raises if _output_duplicates() failed on
                either comparand dict
        """
        try:
            self._output_duplicates(self._first_comparand_dict)
        except G6DiffFinderException as first_comparand_find_duplicates_error:
            raise G6DiffFinderException(
                "Unable to output duplicates for first .g6 file."
            ) from first_comparand_find_duplicates_error

        try:
            self._output_duplicates(self._second_comparand_dict)
        except G6DiffFinderException as second_comparand_find_duplicates_error:
            raise G6DiffFinderException(
                "Unable to output duplicates for second .g6 file."
            ) from second_comparand_find_duplicates_error

    def _output_duplicates(self, comparand_dict: dict):
        """
        Performs a dictionary-comprehension to get each g6_encoded_graph whose
        corresponding value has a non-empty duplicate_line_nums list.

        If this dictionary is empty, emits a log message that no duplicates
        were found.

        If the dictionary is nonempty, json.dumps() to an output file whose
        path is:
            {comparand_infile_path}.duplicates.out.txt

        The file is overwritten if it already exists.

        Args:
            comparand_dict: contains key-value pairs of graph encodings mapped
                to sub-dicts, which contain the first_line on which the
                encoding occurred and the list of duplicate_line_nums on which
                the graph recurred in the file.

        Raises:
            G6DiffFinderException: If KeyError encountered when trying to
                get value corresponding to key infile_path from the comparand
                dict
        """
        try:
            comparand_infile_path = Path(
                comparand_dict["infile_path"]
            ).resolve()
        except KeyError as no_infile_path_error:
            raise G6DiffFinderException(
                "Invalid dict structure: missing 'infile_path'."
            ) from no_infile_path_error
        else:
            comparand_outfile_results_directory_path = Path.joinpath(
                comparand_infile_path.parent, "results"
            )
            Path.mkdir(
                comparand_outfile_results_directory_path,
                parents=True,
                exist_ok=True,
            )
            comparand_outfile_path = Path.joinpath(
                comparand_outfile_results_directory_path,
                comparand_infile_path.parts[-1] + ".duplicates.out.txt",
            )

            duplicated_g6_encodings = {
                g6_encoded_graph: comparand_dict[g6_encoded_graph]
                for g6_encoded_graph in comparand_dict
                if g6_encoded_graph != "infile_path"
                if len(comparand_dict[g6_encoded_graph]["duplicate_line_nums"])
                > 0
            }

            if not duplicated_g6_encodings:
                self.logger.info(
                    "No duplicates present in '%s'.", comparand_infile_path
                )
            else:
                with open(
                    comparand_outfile_path, "w", encoding="utf-8"
                ) as comparand_outfile:
                    self.logger.info(
                        "Outputting duplicates present in '%s'",
                        comparand_infile_path,
                    )
                    comparand_outfile.write(
                        "Comparand infile name: "
                        f"'{comparand_infile_path.name}'\n"
                    )
                    comparand_outfile.write(
                        json.dumps(duplicated_g6_encodings, indent=4)
                    )

    def graph_set_diff(self):
        """
        Calls self._graph_set_diff() for both the self._first_comparand_dict
        against the second self._second_comparand_dict and vice versa to output
        which graphs are in the first .g6 file that are absent from the second,
        and in the second .g6 file that are absent from the first.
        """
        self._graph_set_diff(
            self._first_comparand_dict, self._second_comparand_dict
        )
        self._graph_set_diff(
            self._second_comparand_dict, self._first_comparand_dict
        )

    def _graph_set_diff(
        self, first_comparand_dict: dict, second_comparand_dict: dict
    ):
        """
        Gets the first_comparand_infile_dir (which is where the output
        file will be written to, if the result is nonempty) and the infile
        names that were used to populate the respective dicts; these are used
        to construct the outfile path.

        Performs a list-comprehension to determine which graph encodings appear
        in the first file that don't appear in the second.

        If the graphs_in_first_but_not_second is empty, emits a log message
        indicating that no graphs were found in the first dict that were not
        in the second.

        If graphs_in_first_but_not_second is nonempty, writes each graph
        encoding followed by a newline so that the output constitutes a valid
        .g6 file.

        The output filepath will be of the form
        {first_comparand_infile_dir}/results/
            graphs_in_{first_comparand_infile_name}_not_in_{second_comparand_infile_name}.g6

        Args:
            first_comparand_dict: contains key-value pairs of graph encodings
                mapped to sub-dicts, which contain the first_line on which the
                encoding occurred and the list of duplicate_line_nums on which
                the graph recurred in the file.
            second_comparand_dict: Same structure as first_comparand_dict.

        Raises:
            G6DiffFinderException: Re-raises if exeption encountered when we
                _get_infile_names() from the two comparand dicts
        """
        try:
            (
                first_comparand_infile_dir,
                first_comparand_infile_name,
                second_comparand_infile_name,
            ) = self._get_infile_names(
                first_comparand_dict, second_comparand_dict
            )
        except G6DiffFinderException as get_infile_names_error:
            raise G6DiffFinderException(
                "Unable to extract infile_names from comparand dicts."
            ) from get_infile_names_error

        graphs_in_first_but_not_second = [
            g6_encoding
            for g6_encoding in first_comparand_dict
            if g6_encoding != "infile_path"
            if g6_encoding not in second_comparand_dict
        ]

        if not graphs_in_first_but_not_second:
            self.logger.info(
                "No graphs present in '%s' that aren't in '%s'",
                first_comparand_infile_name,
                second_comparand_infile_name,
            )
        else:
            comparand_outfile_results_directory_path = Path.joinpath(
                first_comparand_infile_dir, "results"
            )
            Path.mkdir(
                comparand_outfile_results_directory_path,
                parents=True,
                exist_ok=True,
            )
            outfile_path = Path.joinpath(
                comparand_outfile_results_directory_path,
                f"graphs_in_{first_comparand_infile_name}_not_in_"
                + f"{second_comparand_infile_name}.g6",
            )
            self.logger.info(
                "Outputting graphs present in '%s' that aren't in '%s' to "
                "'%s'.",
                first_comparand_infile_name,
                second_comparand_infile_name,
                outfile_path,
            )
            with open(
                outfile_path, "w", encoding="utf-8"
            ) as graph_set_diff_outfile:
                for g6_encoding in graphs_in_first_but_not_second:
                    graph_set_diff_outfile.write(g6_encoding)
                    graph_set_diff_outfile.write("\n")

    def graph_set_intersection_with_different_line_nums(self):
        """
        Takes the two comparand dicts associated with the G6DiffFinder and gets
        the first_comparand_infile_dir (which is where the output
        file will be written to, if the result is nonempty) and the infile
        names corresponding to the self._first_comparand_dict and
        self._second_comparand_dict; these are used to construct the outfile
        path.

        Performs a dictionary comprehension to produce key-value pairs of
        graph encoding mapped to a tuple containing the first_line on which the
        encoding occurred in the first .g6 infile and the first_line on which
        the encoding occurred in the second .g6 infile.

        If the graphs_in_first_and_second is empty, emits a log message
        indicating that the intersection is empty.

        If graphs_in_first_and_second is nonempty, json.dumps() the dict to the
        output file of the form:
        {first_comparand_infile_dir}/results/graphs_in_{first_comparand_infile_name}_and_{second_comparand_infile_name}.txt  # pylint: disable=line-too-long

        Raises:
            G6DiffFinderException: Re-raises if exeption encountered when we
                _get_infile_names() from the two comparand dicts
        """
        try:
            (
                first_comparand_infile_dir,
                first_comparand_infile_name,
                second_comparand_infile_name,
            ) = self._get_infile_names(
                self._first_comparand_dict, self._second_comparand_dict
            )
        except G6DiffFinderException as get_infile_names_error:
            raise G6DiffFinderException(
                "Unable to extract infile_names from comparand dicts."
            ) from get_infile_names_error

        graphs_in_first_and_second = {
            g6_encoding: (
                self._first_comparand_dict[g6_encoding]["first_line"],  # type: ignore
                self._second_comparand_dict[g6_encoding]["first_line"],  # type: ignore
            )
            for g6_encoding in self._first_comparand_dict
            if g6_encoding != "infile_path"
            if g6_encoding in self._second_comparand_dict
            if (
                self._first_comparand_dict[g6_encoding]["first_line"]  # type: ignore
                != self._second_comparand_dict[g6_encoding][  # type: ignore
                    "first_line"
                ]  # type: ignore
            )
        }

        if not graphs_in_first_and_second:
            self.logger.info(
                "No graphs present in both '%s' and '%s' that appear on "
                "different lines.",
                first_comparand_infile_name,
                second_comparand_infile_name,
            )
        else:
            comparand_outfile_results_directory_path = Path.joinpath(
                first_comparand_infile_dir, "results"
            )
            Path.mkdir(
                comparand_outfile_results_directory_path,
                parents=True,
                exist_ok=True,
            )
            outfile_path = Path.joinpath(
                comparand_outfile_results_directory_path,
                f"graphs_in_{first_comparand_infile_name}_and_"
                + f"{second_comparand_infile_name}.txt",
            )
            self.logger.info(
                "Outputting graphs present in both '%s' and '%s' that "
                "appear on different lines to '%s'.",
                first_comparand_infile_name,
                second_comparand_infile_name,
                outfile_path,
            )
            with open(
                outfile_path, "w", encoding="utf-8"
            ) as graph_set_intersection_outfile:
                graph_set_intersection_outfile.write(
                    json.dumps(graphs_in_first_and_second, indent=4)
                )

    def _get_infile_names(
        self, first_comparand_dict: dict, second_comparand_dict: dict
    ):
        """
        Uses pathlib.Path object's .parent attribute to get the directory of
        the first .g6 input file, stored in the first_comparand_dict's
        infile_path attribute. Then, gets the first_comparand_infile_name by
        stripping the .g6 extension, and likewise for the
        second_comparand_infile_name.

        Args:
            first_comparand_dict: Dict containing the key infile_name,
                in addition to the key-value pairs of graph encodings mapped to
                their first_line and the list of duplicate_line_nums
            second_comparand_dict: Same structure as first_comparand_dict

        Returns:
            first_comparand_infile_dir: Parent directory of the first .g6 file
            first_comparand_infile_name: base name of the first .g6 file
            second_comparand_infile_name: base name of the second .g6 file

        Raises:
            G6DiffFinderException: If KeyError encountered when trying to
                get value corresponding to key infile_path from either of the
                two comparand dicts
        """
        try:
            first_comparand_infile_path = Path(
                first_comparand_dict["infile_path"]
            ).resolve()
        except KeyError as key_error:
            raise G6DiffFinderException(
                "Invalid dict structure: missing key 'infile_path'."
            ) from key_error

        first_comparand_infile_dir = first_comparand_infile_path.parent
        first_comparand_infile_name = first_comparand_infile_path.with_suffix(
            ""
        ).name
        try:
            second_comparand_infile_name = (
                Path(second_comparand_dict["infile_path"]).with_suffix("").name
            )
        except KeyError as key_error:
            raise G6DiffFinderException(
                "Invalid dict structure: missing key 'infile_path'."
            ) from key_error

        return (
            first_comparand_infile_dir,
            first_comparand_infile_name,
            second_comparand_infile_name,
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,
        usage="python %(prog)s [options]",
        description="Tool to help interrogate and compare two .g6 files.\n"
        "- Determines if there are duplicates in the first and second "
        "comparand .g6 files; outputs to files with paths:\n"
        "\t{first_comparand_infile_dir}/results/"
        "{first_comparand_infile_name}.duplicates.out.txt\n"
        "\t{second_comparand_infile_dir}/results/"
        "{second_comparand_infile_name}.duplicates.out.txt\n"
        "- Determines if there any graphs that appear in the first .g6 "
        "file that do not appear in the second .g6 file, and vice versa; "
        "outputs to files with paths:\n"
        "\t{first_comparand_infile_dir}/results/graphs_in_"
        "{first_comparand_infile_name}_not_in_"
        "{second_comparand_infile_name}.g6\n"
        "\t{second_comparand_infile_dir}/results/graphs_in_"
        "{second_comparand_infile_name}_not_in_"
        "{first_comparand_infile_name}.g6\n"
        "- Records graphs that occur in both files but which appear on "
        "different line numbers; outputs to a file with path:\n"
        "\t{first_comparand_infile_dir}/results/graphs_in_"
        "{first_comparand_infile_name}_and_"
        "{second_comparand_infile_name}.txt",
    )
    parser.add_argument(
        "--first_comparand",
        "-f",
        type=Path,
        help="The first .g6 file to compare.",
        metavar="FIRST_COMPARAND.g6",
        required=True,
    )
    parser.add_argument(
        "--second_comparand",
        "-s",
        type=Path,
        help="The second .g6 file to compare.",
        metavar="SECOND_COMPARAND.g6",
        required=True,
    )

    args = parser.parse_args()

    try:
        g6_diff_finder = G6DiffFinder(
            args.first_comparand, args.second_comparand
        )
    except Exception as e:
        raise G6DiffFinderException(
            "Unable to initialize G6DiffFinder with given input files."
        ) from e

    try:
        g6_diff_finder.output_duplicates()
    except Exception as e:
        raise G6DiffFinderException(
            "Unable to output duplicates for given input files."
        ) from e

    try:
        g6_diff_finder.graph_set_diff()
    except Exception as e:
        raise G6DiffFinderException(
            "Failed to discern diff between two .g6 input files."
        ) from e

    try:
        g6_diff_finder.graph_set_intersection_with_different_line_nums()
    except Exception as e:
        raise G6DiffFinderException(
            "Failed to determine set intersection of two .g6 input files."
        ) from e
