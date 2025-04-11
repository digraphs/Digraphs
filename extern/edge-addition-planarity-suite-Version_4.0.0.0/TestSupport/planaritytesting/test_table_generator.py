"""Compile planarity testAllGraphs() output into table

Classes:
    TestTableGeneratorPathError
    TestTableGeneratorFileProcessingError
    TestTableGenerator
"""

#!/usr/bin/env python

__all__ = [
    "TestTableGeneratorPathError",
    "TestTableGeneratorFileProcessingError",
    "TestTableGenerator",
]

import sys
import argparse
from pathlib import Path
from typing import Optional

from planaritytesting_utils import PLANARITY_ALGORITHM_SPECIFIERS
from planarity_testAllGraphs_output_parsing import (
    TestAllGraphsPathError,
    TestAllGraphsOutputFileContentsError,
    validate_infile_name,
    process_file_contents,
)


class TestTableGeneratorPathError(BaseException):
    """
    Custom exception signalling issues with the paths of input for the Test
    Table Generator.

    For example:
    - input_dir or output_dir don't correspond to directories that exist
    - input filename contains an order or command that doesn't align with the
        order and command extracted from the parts of the parent directory
    """

    def __init__(self, message):
        super().__init__(message)
        self.message = message


class TestTableGeneratorFileProcessingError(BaseException):
    """
    Custom exception signalling issues with the file contents of input for the
    Test Table Generator.
    """

    def __init__(self, message):
        super().__init__(message)
        self.message = message


class TestTableGenerator:  # pylint: disable=too-many-instance-attributes
    """Process output from running planarity testAllGraphs for a single command"""

    __COL_WIDTH_TOLERANCE = 2

    def __init__(
        self,
        test_table_input_dir: Path,
        test_table_output_dir: Path,
        canonical_files: bool = False,
        makeg_files: bool = False,
        edge_deletion_analysis_results: Optional[dict[str, dict]] = None,
    ):
        """Initializes TestTableGenerator instance.

        Checks that input_dir exists and is a directory, and that it contains
        input files. Also checks that the output_dir exists and is a directory.

        Args:
            input_dir: Directory containing the files output by running the
                planarity Test All Graphs functionality for a given algorithm
                command on .g6 input files containing all graphs of a given
                order and edge count.
            output_dir: Directory to which you wish to write the output file
                containing the tabulated results compiled from the input files
                in the input_dir.
            canonical_files: Optional bool to indicate planarity output
                corresponds to canonical format
            makeg_files: Optional bool to indicate planarity output corresponds
                to makeg .g6
            edge_deletion_analysis_results: (Optional) When generating the test
                table for K_{2, 3} search, K_{3, 3} search, or K_4 search, one
                may optionally pass in a dictionary mapping input filenames to
                a sub-dict containing the numInvalidOK count derived by running
                the EdgeDeletionAnalyzer for this graph algorithm extension,
                the sum of the system and user CPU time of the current process
                (proc_time_s), and the total time elapsed during measurement
                (tot_time_s).

        Raises:
            TestTableGeneratorPathError: If the input_dir doesn't correspond to
                a directory, or if it is empty; or if the output_dir doesn't
                correspond to a directory.
        """
        self.order = None
        self.command = None

        # According to PEP-8, one must use one leading underscore only for
        # non-public methods and instance variables.
        self._processed_data = {}
        self._totals = {}

        if not Path.is_dir(test_table_input_dir):
            raise TestTableGeneratorPathError(
                f"'{test_table_input_dir}' is not a valid directory."
            )

        if not any(test_table_input_dir.iterdir()):
            raise TestTableGeneratorPathError(
                f"'{test_table_input_dir}' contains no files."
            )

        self.input_dir = test_table_input_dir

        if Path.is_file(test_table_output_dir):
            raise TestTableGeneratorPathError(
                f"'{test_table_output_dir}' is not a valid directory."
            )

        self.output_dir = test_table_output_dir

        self.canonical_files = canonical_files
        self.makeg_files = makeg_files
        self._edge_deletion_analysis_results = (
            edge_deletion_analysis_results
            if edge_deletion_analysis_results
            else {}
        )

    def get_order_and_command_from_input_dir(self):
        """Extract order and command from input_dir if possible

        Takes the self.input_dir pathlib.Path object's parts and attempts to
        extract the order and command from the directory structure. If the
        input directory is such that the path is of the form
            {parent_dir}/{order}/{command}/
        Then we can extract these values early, allowing us to validate
        individual input files later in the process. Otherwise, sets
        self.order and self.command to None.
        """
        parts = self.input_dir.parts
        try:
            order_from_input_dir = int(parts[-2])
        except ValueError:
            order_from_input_dir = None

        command_from_input_dir = parts[-1]
        # You may reference class attributes either by the name of the class,
        # seen here, or by using "self"
        if command_from_input_dir not in PLANARITY_ALGORITHM_SPECIFIERS():
            command_from_input_dir = None

        self.order = order_from_input_dir
        self.command = command_from_input_dir

    def process_files(self):
        """Process input files to populate _processed_data and _totals dicts

        Iterates over the filenames within the input_dir and constructs the
        full infile_path, then calls self._process_file() on this infile_path.

        After all files have been processed, constructs the self._totals dict
        containing the compiled results for the numGraphs, numOK,
        numNONEMBEDDABLE, numErrors, and duration. Their values are generated
        by summing the results of a list-comprehension, which extracts the
        values of the same key name in the list of dicts within
        self._processed_data.values().

        If edge_deletion_analysis_results is nonempty, then the values in the
        self._processed_data dict for the numInvalidOK count derived by running
        the EdgeDeletionAnalyzer for this graph algorithm extension, the sum of
        the system and user CPU time of the current process (proc_time_s), and
        the total time elapsed during measurement (tot_time_s) will be summed
        and added to the self._totals dictionary.

        Raises:
            TestTableGeneratorFileProcessingError: If an error occurred
                processing the input file corresponding to path infile_path
        """
        for dirpath, _, filenames in Path.walk(self.input_dir):
            for filename in filenames:
                if (
                    (self.canonical_files and "canonical" not in filename)
                    or (not self.canonical_files and "canonical" in filename)
                    or (self.makeg_files and "makeg" not in filename)
                    or (not self.makeg_files and "makeg" in filename)
                ):
                    continue
                infile_path = Path.joinpath(dirpath, filename)
                try:
                    self._process_file(infile_path)
                except (
                    TestAllGraphsPathError,
                    TestAllGraphsOutputFileContentsError,
                ) as e:
                    raise TestTableGeneratorFileProcessingError(
                        f"Error processing '{infile_path}'."
                    ) from e

        if not self._processed_data:
            raise TestTableGeneratorFileProcessingError(
                f"No files in input directory '{self.input_dir}' matched the "
                "patterns indicated by the input flags:"
                f"\n\tcanonical_files={self.canonical_files}"
                f"\n\tmakeg_files={self.makeg_files}"
            )

        self._totals = {
            "numGraphs": sum(
                int(x.get("numGraphs")) for x in self._processed_data.values()
            ),
            "numOK": sum(
                int(x.get("numOK")) for x in self._processed_data.values()
            ),
            "numNONEMBEDDABLE": sum(
                int(x.get("numNONEMBEDDABLE"))
                for x in self._processed_data.values()
            ),
            "numErrors": sum(
                1
                for x in self._processed_data.values()
                if x.get("errorFlag") == "SUCCESS"
            ),
            "duration": sum(
                float(x.get("duration")) for x in self._processed_data.values()
            ),
            "numInvalidOK": sum(
                int(x.get("numInvalidOK"))
                for x in self._processed_data.values()
            ),
            "proc_time_s": sum(
                float(x.get("proc_time_s"))
                for x in self._processed_data.values()
            ),
            "tot_time_s": sum(
                float(x.get("tot_time_s"))
                for x in self._processed_data.values()
            ),
        }

    def _process_file(self, infile_path: Path):
        """Process infile and integrate into self._processed_data dict

        Validates the infile name, then processes file contents and adds them
        to the self._processed_data dict by mapping the num_edges to a sub-dict
        containing fields for the infilename, numGraphs, numOK,
        numNONEMBEDDABLE, errorFlag, and duration.

        If edge_deletion_analysis_results is nonempty, those results (i.e. the
        numInvalidOK count, the proc_time_s, and the "wall time" tot_time_s)
        are integrated into the self._processed_data dict.

        Args:
            infile_path: Corresponds to a file within the input_dir
            processed_data: Dict to which we wish to add information parsed
                from the infile

        Raises:
            TestAllGraphsPathError: If invalid infile_path
            TestAllGraphsOutputFileContentsError: If input file corresponds to
                results that have already been processed, or re-raises
                exception thrown by process_file_contents()
        """
        try:
            self.order, num_edges, self.command = validate_infile_name(
                infile_path, self.order, self.command
            )
        except TestAllGraphsPathError as e:
            raise TestAllGraphsPathError(
                "Unable to process file when given invalid infile name."
            ) from e

        if num_edges in self._processed_data:
            raise TestAllGraphsOutputFileContentsError(
                "Already processed a file corresponding to "
                f"{num_edges} edges."
            )

        try:
            (
                planarity_infile_name,
                duration,
                numGraphs,
                numOK,
                numNONEMBEDDABLE,
                errorFlag,
            ) = process_file_contents(infile_path, self.command)
        except TestAllGraphsOutputFileContentsError as e:
            raise TestAllGraphsOutputFileContentsError(
                f"Unable to process contents of '{infile_path}'."
            ) from e

        self._processed_data[num_edges] = {
            "infilename": planarity_infile_name,
            "numGraphs": numGraphs,
            "numOK": numOK,
            "numNONEMBEDDABLE": numNONEMBEDDABLE,
            "errorFlag": errorFlag,
            "duration": duration,
        }

        self._processed_data[num_edges].update(
            {
                "numInvalidOK": self._edge_deletion_analysis_results.get(
                    planarity_infile_name, {}
                ).get("numInvalidOK", 0),
                "proc_time_s": self._edge_deletion_analysis_results.get(
                    planarity_infile_name, {}
                ).get("proc_time_s", 0.0),
                "tot_time_s": self._edge_deletion_analysis_results.get(
                    planarity_infile_name, {}
                ).get("tot_time_s", 0.0),
            }
        )

    def write_table_formatted_data_to_file(
        self,
    ):  # pylint: disable=too-many-locals disable=too-many-statements
        """Writes the data extracted from the input files and totals to table"""
        self.output_dir = Path.joinpath(self.output_dir, f"{self.order}")
        Path.mkdir(self.output_dir, parents=True, exist_ok=True)

        makeg_ext = ".makeg" if self.makeg_files else ""
        canonical_ext = ".canonical" if self.canonical_files else ""
        output_path = Path.joinpath(
            self.output_dir,
            f"n{self.order}.mALL{makeg_ext}{canonical_ext}.{self.command}"
            + ".out.txt",
        )

        infilename_heading = "Input filename"
        num_edges_heading = "# Edges"
        num_graphs_heading = "# Graphs"
        numOK_heading = "# OK"
        num_NONEMBEDDABLE_heading = "# NONEMBEDDABLE"
        errorFlag_heading = "Error flag"
        duration_heading = "Duration"
        numInvalidOK_heading = "# Invalid OK"
        proc_time_s_heading = "EDA Proc Time"
        tot_time_s_heading = "EDA Total Time"

        infilename_len = (
            max(
                len(infilename_heading),
                *[
                    len(x.get("infilename"))
                    for x in self._processed_data.values()
                ],
            )
            + TestTableGenerator.__COL_WIDTH_TOLERANCE
        )
        num_edges_len = (
            max(
                len(num_edges_heading),
                *[len(str(num_edges)) for num_edges in self._processed_data],
            )
            + TestTableGenerator.__COL_WIDTH_TOLERANCE
        )
        numGraphs_len = (
            max(
                len(str(self._totals.get("numGraphs"))),
                len(num_graphs_heading),
            )
            + TestTableGenerator.__COL_WIDTH_TOLERANCE
        )
        numOK_len = (
            max(len(str(self._totals.get("numOK"))), len(numOK_heading))
            + TestTableGenerator.__COL_WIDTH_TOLERANCE
        )
        numNONEMBEDDABLE_len = (
            max(
                len(str(self._totals.get("numNONEMBEDDABLE"))),
                len(num_NONEMBEDDABLE_heading),
            )
            + TestTableGenerator.__COL_WIDTH_TOLERANCE
        )
        errorFlag_len = len(errorFlag_heading)
        duration_len = (
            max(len(str(self._totals.get("duration"))), len(duration_heading))
            + TestTableGenerator.__COL_WIDTH_TOLERANCE
        )

        nonempty_edge_deletion_analysis_results = bool(
            self._edge_deletion_analysis_results
        )
        numInvalidOK_len = 0
        proc_time_s_len = 0
        tot_time_s_len = 0
        if nonempty_edge_deletion_analysis_results:
            numInvalidOK_len = (
                max(
                    len(str(self._totals.get("numInvalidOK"))),
                    len(numInvalidOK_heading),
                )
                + TestTableGenerator.__COL_WIDTH_TOLERANCE
            )
            proc_time_s_len = (
                max(
                    len(str(self._totals.get("proc_time_s"))),
                    len(proc_time_s_heading),
                )
                + TestTableGenerator.__COL_WIDTH_TOLERANCE
            )
            tot_time_s_len = (
                max(
                    len(str(self._totals.get("tot_time_s"))),
                    len(tot_time_s_heading),
                )
                + TestTableGenerator.__COL_WIDTH_TOLERANCE
            )

        with open(output_path, "w", encoding="utf-8") as outfile:
            # Print the table header
            outfile.write(
                f"|{infilename_heading:^{infilename_len}}"
                f"|{num_edges_heading:^{num_edges_len}}"
                f"|{num_graphs_heading:^{numGraphs_len}}"
                f"|{numOK_heading:^{numOK_len}}"
                f"|{num_NONEMBEDDABLE_heading:^{numNONEMBEDDABLE_len}}"
                f"|{errorFlag_heading:^{errorFlag_len}}"
                f"|{duration_heading:^{duration_len}}"
            )
            if self._edge_deletion_analysis_results:
                outfile.write(f"|{numInvalidOK_heading:^{numInvalidOK_len}}")
                outfile.write(f"|{proc_time_s_heading:^{proc_time_s_len}}")
                outfile.write(f"|{tot_time_s_heading:^{tot_time_s_len}}")
            outfile.write("|\n")

            # Print the table header separator
            outfile.write(
                f"|{'='*infilename_len}"
                f"|{'='*num_edges_len}"
                f"|{'='*numGraphs_len}"
                f"|{'='*numOK_len}"
                f"|{'='*numNONEMBEDDABLE_len}"
                f"|{'='*len('Error flag')}"
                f"|{'='*duration_len}"
            )
            if nonempty_edge_deletion_analysis_results:
                outfile.write(f"|{'='*numInvalidOK_len}")
                outfile.write(f"|{'='*proc_time_s_len}")
                outfile.write(f"|{'='*tot_time_s_len}")
            outfile.write("|\n")

            # Print the table rows
            for num_edges in sorted(self._processed_data.keys()):
                data = self._processed_data.get(num_edges)
                if data is None:
                    raise TestTableGeneratorFileProcessingError(
                        f"Data for M = {num_edges} is missing from processed "
                        "data dict."
                    )

                outfile.write(
                    f"|{data.get('infilename'):<{infilename_len}}"
                    f"|{num_edges:<{num_edges_len}}"
                    f"|{data.get('numGraphs'):<{numGraphs_len}}"
                    f"|{data.get('numOK'):<{numOK_len}}"
                    f"|{data.get('numNONEMBEDDABLE'):<{numNONEMBEDDABLE_len}}"
                    f"|{data.get('errorFlag'):<{errorFlag_len}}"
                    f"|{data.get('duration'):<{duration_len}}"
                )
                if nonempty_edge_deletion_analysis_results:
                    outfile.write(
                        f"|{data.get('numInvalidOK'):<{numInvalidOK_len}}"
                    )
                    outfile.write(
                        f"|{data.get('proc_time_s'):<{proc_time_s_len}.{3}f}"
                    )
                    outfile.write(
                        f"|{data.get('tot_time_s'):<{tot_time_s_len}.{3}f}"
                    )
                outfile.write("|\n")

            # Print the table footer separator
            outfile.write(
                f"|{'='*infilename_len}"
                f"|{'='*num_edges_len}"
                f"|{'='*numGraphs_len}"
                f"|{'='*numOK_len}"
                f"|{'='*numNONEMBEDDABLE_len}"
                f"|{'='*len('Error flag')}"
                f"|{'='*duration_len}"
            )
            if nonempty_edge_deletion_analysis_results:
                outfile.write(f"|{'='*numInvalidOK_len}")
                outfile.write(f"|{'='*proc_time_s_len}")
                outfile.write(f"|{'='*tot_time_s_len}")
            outfile.write("|\n")

            # Print the totals footer
            data = self._totals
            outfile.write(
                f"|{'TOTALS':<{infilename_len + num_edges_len + 1}}"
                f"|{data.get('numGraphs'):<{numGraphs_len}}"
                f"|{data.get('numOK'):<{numOK_len}}"
                f"|{data.get('numNONEMBEDDABLE'):<{numNONEMBEDDABLE_len}}"
                f"|{data.get('numErrors'):<{errorFlag_len}}"
                f"|{data.get('duration'):<{duration_len}}"
            )
            if nonempty_edge_deletion_analysis_results:
                outfile.write(
                    f"|{data.get('numInvalidOK'):<{numInvalidOK_len}}"
                )
                outfile.write(
                    f"|{data.get('proc_time_s'):<{proc_time_s_len}.{3}f}"
                )
                outfile.write(
                    f"|{data.get('tot_time_s'):<{tot_time_s_len}.{3}f}"
                )
            outfile.write("|\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,
        usage="python %(prog)s [options]",
        description="Test Table Generator\n"
        "Tabulates results from output files produced by planarity's "
        "Test All Graphs functionality.\n\n"
        "Expects to be given an input directory containing only the "
        "output files produced by running planarity's Test All Graphs "
        "for a specific algorithm.\n\n"
        "Preferably, this will be the output from having run the "
        "Planarity Orchestrator, and will have a path of the form:\n"
        "\t{parent_dir}/{order}/{command}/\n"
        "And will contain files with the full path:\n"
        "\t{parent_dir}/{order}/{command}/n{order}.m{numEdges}(.makeg)?"
        "(.canonical)?.{command}.out.txt\n\n"
        "Will output one file per graph algorithm containing the "
        "tabulated data compiled from the planarity Test All Graphs "
        "output files:\n"
        "\t{output_dir}/n{order}.mALL(.makeg)?(.canonical)?.{command}.out"
        ".txt",
    )
    parser.add_argument(
        "-i", "--inputdir", type=Path, default=None, metavar="INPUT_DIR"
    )
    parser.add_argument(
        "-o", "--outputdir", type=Path, default=None, metavar="OUTPUT_DIR"
    )
    parser.add_argument(
        "-c",
        "--command",
        type=str,
        default="3",
        metavar="ALGORITHM_COMMAND",
        help="One of (pdo234); defaults to '%(default)s'",
    )
    parser.add_argument(
        "-n",
        "--order",
        type=int,
        default=11,
        metavar="ORDER",
        help="Order of graphs for which you wish to compile results of "
        "having run planarity with given command specifier. Defaults to "
        "N = %(default)s",
    )
    parser.add_argument(
        "-l",
        "--canonicalfiles",
        action="store_true",
        help="Planarity output files must contain 'canonical' in name",
    )
    parser.add_argument(
        "-m",
        "--makegfiles",
        action="store_true",
        help="Planarity output files must contain 'makeg' in name",
    )

    args = parser.parse_args()

    command = args.command
    order = args.order

    test_support_dir = Path(sys.argv[0]).resolve().parent.parent
    if not args.inputdir:
        input_dir = Path.joinpath(
            test_support_dir,
            "results",
            "planarity_testAllGraphs_orchestrator",
            f"{order}",
            f"{command}",
        )
    else:
        input_dir = Path(args.inputdir).resolve()

    if not args.outputdir:
        output_dir = Path.joinpath(test_support_dir, "tables")
    else:
        output_dir = Path(args.outputdir).resolve()

    ttg = TestTableGenerator(
        test_table_input_dir=input_dir,
        test_table_output_dir=output_dir,
        canonical_files=args.canonicalfiles,
        makeg_files=args.makegfiles,
    )
    ttg.get_order_and_command_from_input_dir()
    ttg.process_files()
    ttg.write_table_formatted_data_to_file()
