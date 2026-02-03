"""Automate the edge-deletion analysis on the graph(s) in a .g6 input file

Classes:
    EdgeDeletionAnalysisError
    EdgeDeletionAnalyzer
"""  # pylint: disable=too-many-lines

#!/usr/bin/env python

__all__ = ["EdgeDeletionAnalyzer", "EdgeDeletionAnalysisError"]

import argparse
from copy import deepcopy
import logging
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
from typing import Optional

from graph import Graph, GraphError
from planaritytesting_utils import (
    g6_header,
    determine_input_filetype,
    is_path_to_executable,
    EDGE_DELETION_ANALYSIS_SPECIFIERS,
)


class EdgeDeletionAnalysisError(BaseException):
    """Signals issues encountered during edge deletion analysis

    For example:
        - Nonzero exit code from running various planarity commands
    """

    def __init__(self, message):
        super().__init__(message)
        self.message = message


class EdgeDeletionAnalyzer:
    """Performs edge-deletion analysis on graph(s) in a .g6 input file"""

    # Cap this at a much lower value, since EDA for N=10 takes days if this
    # threshold is high
    __MAX_NUM_INVALID_OKs = 500

    def __init__(
        self,
        planarity_path: Path,
        infile_path: Path,
        output_dir: Optional[Path] = None,
        extension_choice: str = "3",
    ) -> None:
        """Validate input and set up for edge-deletion analysis

        If output_dir was not None and doesn't correspond to a file,
        self.output_dir will be set to:
            {output_dir}/{infile_path.stem}/{extension_choice}
        If output_dir was None, self.output_dir will be set to
            TestSupport/results/edge_deletion_analysis/{infile_path.stem}/
                {extension_choice}/

        If the output_dir exists, all of its contents are wiped and the
        directory remade. Then, the input file is copied into this directory.

        Args:
            planarity_path: Path to planarity executable
            infile_path: Path to graph input file
            output_dir: Directory under which a new subdirectory will be
                created to which results will be written.
            extension_choice: Specifies the graph algorithm extension you wish
                to test, either 2  for K_{2, 3} search, 3 for K_{3, 3} search
                or 4 for K_4 search

        Raises:
            argparse.ArgumentTypeError: If the planarity_path doesn't
                correspond to an executable, if the infile_path doesn't
                correspond to a file, or if the output_dir corresponds to a
                file (rather than an existing directory, or to a directory that
                does not yet exist)
        """
        if not is_path_to_executable(planarity_path):
            raise argparse.ArgumentTypeError(
                f"Path for planarity executable '{planarity_path}' does not "
                "correspond to an executable."
            )

        try:
            file_type = determine_input_filetype(infile_path)
        except ValueError as input_filetype_error:
            raise argparse.ArgumentTypeError(
                "Failed to determine input filetype of " f"'{infile_path}'."
            ) from input_filetype_error

        if file_type != "G6":
            raise argparse.ArgumentTypeError(
                f"Determined '{infile_path}' has filetype '{file_type}', "
                "which is not supported; please supply a .g6 file."
            )

        if extension_choice not in EDGE_DELETION_ANALYSIS_SPECIFIERS():
            raise ValueError(
                f"'{extension_choice}' is not a valid graph algorithm "
                "extension command specifier; expecting either 2 (K_{2, 3}), "
                "3 (K_{3, 3}), or 4 (K_4)."
            )

        if not output_dir:
            test_support_dir = Path(sys.argv[0]).resolve().parent.parent
            output_dir = Path.joinpath(
                test_support_dir, "results", "edge_deletion_analysis"
            )

        if output_dir.is_file():
            raise argparse.ArgumentTypeError(
                f"Path '{output_dir}' corresponds to a file, and can't be "
                "used as the output directory."
            )

        output_dir = Path.joinpath(
            output_dir, f"{infile_path.stem}", f"{extension_choice}"
        )

        if Path.is_dir(output_dir):
            shutil.rmtree(output_dir)

        Path.mkdir(output_dir, parents=True, exist_ok=True)

        infile_copy_path = Path.joinpath(
            output_dir, infile_path.name
        ).resolve()

        shutil.copyfile(infile_path, infile_copy_path)

        self.planarity_path = planarity_path.resolve()
        self.orig_infile_path = infile_copy_path
        self.output_dir = output_dir
        self.extension_choice = extension_choice

        self._setup_logger()

    def _setup_logger(self) -> None:
        """Set up logger instance for EdgeDeletionAnalyzer
        Defaults to:
            {self.output_dir}/
                edge_deletion_analysis-{graph_input_name}.{command}.log
        """
        graph_input_name = self.orig_infile_path.stem

        log_path = Path.joinpath(
            self.output_dir,
            f"edge_deletion_analysis-{graph_input_name}"
            f".{self.extension_choice}.log",
        )

        # logging.getLogger() returns the *same instance* of a logger
        # when given the same name. In order to prevent this, must either give
        # a unique name, or must prevent adding additional handlers to the
        # logger
        self.logger = logging.getLogger(
            __name__ + f"{graph_input_name}_{self.extension_choice}"
        )
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

            stderr_handler = logging.StreamHandler()
            stderr_handler.setLevel(logging.ERROR)
            stderr_handler.setFormatter(logger_formatter)
            self.logger.addHandler(stderr_handler)

    def analyze_graphs(self) -> int:
        """Transform input graph(s) and perform edge-deletion analysis on each

        Iterates over contents of .g6 input file; for each line of the input
        file, write a new .g6 file containing only that graph. Then, run the
        transformation to adjacency list, and finally perform the edge-deletion
        analysis steps to determine if the graph contains the target
        homeomorph, either a graph homeomorphic to K_{2, 3} (extension choice
        is 2), a K_{3, 3} (extension choice is 3), or a K_4 (extension choice
        is 4) that was missed by the K_{2, 3} search (2), K_{3, 3} search (3)
        or K_4 search (4) graph algorithm extension.

        Returns:
            num_invalid_OKs: number of graphs in the infile for which
                contains_missed_homeomorph was true.

        Raises:
            EdgeDeletionAnalysisError: If an error occured when trying to
                determine the input file type, if the input file is anything
                other than a .g6 file, if transformation failed for the input
                graph(s), or if any of the analysis steps failed for the input
                graph(s)
        """
        num_invalid_OKs = 0
        with open(self.orig_infile_path, "r", encoding="utf-8") as orig_infile:
            line_num = 0
            for line in orig_infile:
                line_num += 1
                if line_num == 1:
                    line.replace(g6_header(), "")

                new_g6_name = f"{self.orig_infile_path.name}.{line_num}"
                new_parent_dir = Path.joinpath(self.output_dir, new_g6_name)
                Path.mkdir(new_parent_dir, parents=True, exist_ok=True)
                new_g6_path = Path.joinpath(
                    new_parent_dir, f"{new_g6_name}.g6"
                )
                with open(new_g6_path, "w", encoding="utf-8") as new_g6_file:
                    new_g6_file.write(line)

                try:
                    adj_list_path = self.transform_input(
                        new_g6_path, new_parent_dir
                    )
                except EdgeDeletionAnalysisError as input_transform_error:
                    raise EdgeDeletionAnalysisError(
                        f"Unable to transform graph on line {line_num} in "
                        f"'{self.orig_infile_path}'."
                    ) from input_transform_error

                try:
                    contains_missed_homeomorph = (
                        self.analyze_transformed_graph(
                            adj_list_path, new_parent_dir
                        )
                    )
                except EdgeDeletionAnalysisError as analysis_error:
                    raise EdgeDeletionAnalysisError(
                        "Error encountered analyzing graph on line "
                        f"{line_num} in '{self.orig_infile_path}'."
                    ) from analysis_error

                if not contains_missed_homeomorph:
                    self.logger.info(
                        "Cleaning up '%s' directory.", new_parent_dir
                    )
                    shutil.rmtree(new_parent_dir, ignore_errors=True)
                else:
                    num_invalid_OKs += 1
                    if (
                        num_invalid_OKs
                        >= EdgeDeletionAnalyzer.__MAX_NUM_INVALID_OKs
                    ):
                        self.logger.error(
                            "Encountered more invalid OKs than supported "
                            "(i.e. %d)",
                            EdgeDeletionAnalyzer.__MAX_NUM_INVALID_OKs,
                        )
                        break

        return num_invalid_OKs

    def transform_input(self, infile_path: Path, output_dir: Path) -> Path:
        """Transforms input graph to adjacency list

        Runs
            planarity -x -a {input_file} {infile_stem}.AdjList.out.txt
        to transform the graph to adjacency list

        Args:
            infile_path: Path to input file containing a single graph
            output_dir: Directory to which transformed graph is output

        Returns:
            Path to Adjacency List representation of input graph.

        Raises:
            EdgeDeletionAnalysisError: if calling planarity returned nonzero
                exit code
        """
        adj_list_path = Path.joinpath(
            output_dir, infile_path.stem + ".AdjList.out.txt"
        )

        planarity_transform_args = [
            f"{self.planarity_path}",
            "-x",
            "-a",
            f"{infile_path}",
            f"{adj_list_path}",
        ]

        # TestGraphFunctionality() returns either OK or NOTOK, which means
        # commandLine() will return 0 or -1.
        try:
            subprocess.run(planarity_transform_args, check=True)
        except subprocess.CalledProcessError as e:
            error_message = (
                f"Unable to transform '{infile_path}' " "to Adjacency list."
            )
            self.logger.error(error_message)
            raise EdgeDeletionAnalysisError(error_message) from e

        return adj_list_path

    def analyze_transformed_graph(
        self, adj_list_path: Path, output_dir: Path
    ) -> bool:
        """Perform steps of edge-deletion analysis
        
        First os.chdir() to the output_dir, since SpecificGraph() calls
        ConstructInputFilename(), which enforces a limit on the length of the
        infileName.

        Runs 
            planarity -s -{self.extension_to_run} \
                {infile_stem}.AdjList.out.txt \
                {infile_stem}.AdjList.s.{self.extension_to_run}.out.txt
        and report whether a subgraph homeomorphic to K_{2, 3} (extension
        choice is 2), K_{3, 3} (3) or K_4 (4) was found (NONEMBEDDABLE) or not
        (OK).
        If no subgraph homeomorphic to the target homeomorph was found (i.e. 
        previous test yielded OK), run
            planarity -s -[po] {infile_stem}.AdjList.out.txt \
                {infile_stem}.AdjList.s.[po].out.txt \
                {infile_stem}.AdjList.s.[po].obstruction.txt
        a. If the graph is reported as planar (3) or outerplanar (2, 4), then
        we can be sure there is no subgraph homeomorphic to the target
        homeomorph exists in the graph and execution continues without running
        the rest of the loop body.
        b. If the graph was reported as nonplanar (3) or nonouterplanar (2, 4),
        then examine the obstruction in the secondary output file
        {input_file}.AdjList.s.[po].obstruction.txt:
            i. If the obstruction is homeomorphic to the target homeomorph,
            then report that the original graph contains a
            subgraph homeomorphic to the target homeomorph that was not found
            by the respective search graph algorithm extension.
            ii. If the obstruction is homeomorphic to K_4 (2), K_5 (3), or
            K_{2, 3} (4), then perform the edge-deletion analysis to determine
            whether the graph doesn't contain a K_{2, 3} (2), K_{3, 3} (3), or
            K_4 (4) (with a high degree of confidence)

        Args:
            adj_list_path: Path to adjacency list representation of input graph
            output_dir: Path to output directory

        Return:
            bool indicating whether or not a K_{2, 3} (2), K_{3, 3} (3), or
                K_4 (4) was found by planarity (3) or by outerplanarity (2, 4)
                that was not found by the respective search graph algorithm
                extension.
        Raises:
            EdgeDeletionAnalysisError: re-raised from any step of the analysis
        """
        contains_missed_homeomorph = False
        orig_dir = os.getcwd()
        os.chdir(output_dir)
        try:
            contains_target_homeomorph = self._run_homeomorph_search(
                adj_list_path
            )
            if not contains_target_homeomorph:
                obstruction_name = self._run_alternate_check(
                    adj_list_path, output_dir
                )
                if obstruction_name:
                    obstruction_type = self.determine_obstruction_type(
                        obstruction_name, output_dir
                    )
                    obstruction_path = Path.joinpath(
                        output_dir, obstruction_name
                    )
                    target_obstruction_type, alternate_obstruction_type = (
                        self._get_forbidden_minor_pair(self.extension_choice)
                    )
                    _, description = (
                        self._get_specific_graph_alternate_check_names(
                            self.extension_choice
                        )
                    )
                    if obstruction_type == target_obstruction_type:
                        self.logger.error(
                            "In '%s', %sity found a  %s that was not "
                            "found by %s search; see '%s'.",
                            adj_list_path,
                            description,
                            target_obstruction_type,
                            target_obstruction_type,
                            obstruction_path,
                        )
                        contains_missed_homeomorph = True
                    elif obstruction_type == alternate_obstruction_type:
                        self.logger.info(
                            "'%s' contains a subgraph homeomorphic to %s; "
                            "proceeding with edge-deletion analysis."
                            "\n=======================\n",
                            adj_list_path,
                            alternate_obstruction_type,
                        )
                        contains_missed_homeomorph = (
                            self._edge_deletion_analysis(
                                adj_list_path, output_dir
                            )
                        )
                        self.logger.info("\n=======================\n")
                        if contains_missed_homeomorph:
                            self.logger.error(
                                "In '%s', edge-deletion analysis determined "
                                "that there is a %s that was not found by %s "
                                "search.",
                                adj_list_path,
                                target_obstruction_type,
                                target_obstruction_type,
                            )
                        else:
                            self.logger.info(
                                "'%s' likely doesn't contain a %s.",
                                adj_list_path,
                                target_obstruction_type,
                            )
        except EdgeDeletionAnalysisError as e:
            raise EdgeDeletionAnalysisError(
                f"Encountered error when processing '{adj_list_path}'."
            ) from e
        else:
            return contains_missed_homeomorph
        finally:
            os.chdir(orig_dir)

    def _run_homeomorph_search(
        self, graph_infile_path: Path
    ) -> Optional[bool]:
        """Run homeomorph search based on extension choice

        Runs K_{2, 3} search for extension choice 2, K_{3, 3} search for
        extension choice 3, or K_4 search for extension choice 4.

        Args:
            graph_infile_path: Path to graph on which you wish to run the
                homeomorph search algorithm

        Returns:
            bool: indicates whether or not the input graph contained the target
                homeomorph

        Raises:
            EdgeDeletionAnalysisError: If calling SpecificGraph returned
                anything other than 0 (OK) or 1 (NONEMBEDDABLE), or if messages
                emitted to stdout don't align with their respective exit codes.
        """
        homeomorph_search_output_name = Path(
            graph_infile_path.stem + f".s.{self.extension_choice}.out.txt"
        )

        homeomorph_search_args = [
            f"{self.planarity_path}",
            "-s",
            f"-{self.extension_choice}",
            f"{graph_infile_path.name}",
            f"{homeomorph_search_output_name}",
        ]

        # check=False since exit code will be nonzero if NONEMBEDDABLE, which
        # is not an error state.
        result = subprocess.run(
            homeomorph_search_args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            encoding="utf-8",
            check=False,
        )

        target_obstruction_type, _ = self._get_forbidden_minor_pair(
            self.extension_choice
        )

        _, descriptor = self._get_specific_graph_alternate_check_names(
            self.extension_choice
        )

        # SpecificGraph() will return OK, NONEMBEDDABLE, or NOTOK. This means
        # commandLine() will return 0, 1, or -1 for those three cases; since
        # subprocess.run() with check=True would raise a CalledProcessError for
        # nonzero exit codes, this logic is required to handle when we *truly*
        # encounter an error, i.e. NOTOK yielding exit code -1
        if result.returncode not in (0, 1):
            try:
                result.check_returncode()
            except (
                subprocess.CalledProcessError
            ) as homeomorph_search_subprocess_error:
                error_message = (
                    f"Encountered an error running {target_obstruction_type} "
                    f"search on '{graph_infile_path}':"
                    f"\n\tOutput to stdout:\n\t\t{result.stdout}"
                    f"\n\tOutput to stderr:\n\t\t{result.stderr}"
                )
                self.logger.error(error_message)
                raise EdgeDeletionAnalysisError(
                    error_message
                ) from homeomorph_search_subprocess_error

        if result.returncode == 1:
            if "has a subgraph homeomorphic to" not in result.stdout:
                error_message = (
                    f"{descriptor}ity SpecificGraph() exit code doesn't align "
                    f"with stdout result for '{graph_infile_path}':"
                    f"\n\tOutput to stdout:\n\t\t{result.stdout}"
                    f"\n\tOutput to stderr:\n\t\t{result.stderr}"
                )
                self.logger.error(error_message)
                raise EdgeDeletionAnalysisError(error_message)
            self.logger.info(
                "'%s' contains a subgraph homeomorphic to %s; see '%s'",
                graph_infile_path,
                target_obstruction_type,
                homeomorph_search_output_name,
            )
            return True

        if result.returncode == 0:
            if "has no subgraph homeomorphic to" not in result.stdout:
                error_message = (
                    f"{descriptor}ity SpecificGraph() exit code doesn't align "
                    f"with stdout result for '{graph_infile_path}':"
                    f"\n\tOutput to stdout:\n\t\t{result.stdout}"
                    f"\n\tOutput to stderr:\n\t\t{result.stderr}"
                )
                self.logger.error(error_message)
                raise EdgeDeletionAnalysisError(error_message)
            self.logger.info(
                "'%s' is reported as not containing a "
                "subgraph homeomorphic to %s.",
                graph_infile_path,
                target_obstruction_type,
            )
            return False

        return False

    def _run_alternate_check(
        self, graph_infile_path: Path, output_dir: Path
    ) -> Optional[Path]:
        """Invoke planarity (extension choice is 3) or outerplanarity (4)

        Args:
            graph_infile_path: Path to graph on which you wish to run
                SpecificGraph for planarity (3) or outerplanarity (4)
            output_dir: Path to which you wish to output results

        Returns:
            obstruction_name: Path object that only contains the stem and
                extension of the obstruction; expected to be a file within
                output_dir.

        Raises:
            EdgeDeletionAnalysisError: if calling planarity/outerplanarity
                returned anything other than 0 (OK) or 1 (NONEMBEDDABLE), or
                if messages emitted to stdout don't align with their respective
                exit codes
        """
        command_specifier, descriptor = (
            self._get_specific_graph_alternate_check_names(
                self.extension_choice
            )
        )

        output_name = Path(
            graph_infile_path.stem + f".s.{command_specifier}.out.txt"
        )
        obstruction_name = Path(
            graph_infile_path.stem + f".s.{command_specifier}.obstruction.txt"
        )

        core_planarity_args = [
            f"{self.planarity_path}",
            "-s",
            f"-{command_specifier}",
            f"{graph_infile_path.name}",
            f"{output_name}",
            f"{obstruction_name}",
        ]

        # check=False since we want to handle nonzero exit code appropriately
        result = subprocess.run(
            core_planarity_args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            encoding="utf-8",
            check=False,
        )

        # SpecificGraph() will return OK, NONEMBEDDABLE, or NOTOK. This means
        # commandLine() will return 0, 1, or -1 for those three cases; since
        # subprocess.run() with check=True would raise a CalledProcessError for
        # nonzero exit codes, this logic is required to handle when we *truly*
        # encounter an error, i.e. NOTOK yielding exit code -1
        if result.returncode not in (0, 1):
            try:
                result.check_returncode()
            except subprocess.CalledProcessError as e:
                error_message = (
                    "Encountered an error running "
                    f"{descriptor}rity on '{graph_infile_path}':"
                    f"\n\tOutput to stdout:\n\t\t{result.stdout}"
                    f"\n\tOutput to stderr:\n\t\t{result.stderr}"
                )
                self.logger.error(error_message)
                raise EdgeDeletionAnalysisError(error_message) from e

        if result.returncode == 1:
            if f"is not {descriptor}" not in result.stdout:
                error_message = (
                    f"{descriptor}ity SpecificGraph() exit code doesn't align "
                    f"with stdout result for '{graph_infile_path}':"
                    f"\n\tOutput to stdout:\n\t\t{result.stdout}"
                    f"\n\tOutput to stderr:\n\t\t{result.stderr}"
                )
                self.logger.error(error_message)
                raise EdgeDeletionAnalysisError(error_message)
            self.logger.info(
                "'%s' is non%s; see '%s'",
                graph_infile_path,
                descriptor,
                obstruction_name,
            )
        elif result.returncode == 0:
            if f"is {descriptor}" not in result.stdout:
                error_message = (
                    f"{descriptor}ity SpecificGraph() exit code doesn't align "
                    f"with stdout result for '{graph_infile_path}':"
                    f"\n\tOutput to stdout:\n\t\t{result.stdout}"
                    f"\n\tOutput to stderr:\n\t\t{result.stderr}"
                )
                self.logger.error(error_message)
                raise EdgeDeletionAnalysisError(error_message)
            output_path = Path.joinpath(output_dir, output_name)
            self.logger.info(
                "'%s' is reported as %s, as shown in '%s'.",
                graph_infile_path,
                descriptor,
                output_path,
            )
            obstruction_name = None

        return obstruction_name

    def determine_obstruction_type(
        self, obstruction_name: Path, output_dir: Path
    ) -> str:
        """Determine obstruction type based on vertex degree counts

        Args:
            obstruction_name: name of secondary output file produced by
                SpecificGraph invoking planarity (extension choice is 3) or
                outerplanarity (extension choice is 4)
            output_dir: Directory containing obstruction_name

        Returns:
            - 'K_{2, 3}' if there are two vertices of degree 3, and all other
                vertices have degree 2 or 0
            - 'K_{3, 3}' if there are six vertices of degree 3, and all other
                vertices have degree 2 or 0
            - 'K_4' if there are four vertices of degree 3, and all other
                vertices have degree 2 or 0
            - 'K_5' if there are 5 vertices of degree 4, and all other vertices
                have degree 2 or 0

        Raises:
            EdgeDeletionAnalysisError: If error encountered when trying to read
                obstruction graph from file, or if the obstruction found
                doesn't have the expected characteristics of any of K_5,
                K_{3, 3}, K_{2, 3}, or K_4
        """
        try:
            obstruction_graph = EdgeDeletionAnalyzer._read_adj_list_graph_repr(
                obstruction_name
            )
        except EdgeDeletionAnalysisError as read_adj_list_error:
            raise EdgeDeletionAnalysisError(
                "Encountered error when trying to read obstruction subgraph "
                "from "
                f"'{Path.joinpath(output_dir, obstruction_name)}'"
            ) from read_adj_list_error

        vertex_degree_counts = obstruction_graph.get_vertex_degree_counts()
        vertices_with_nonzero_degree = (
            obstruction_graph.order - vertex_degree_counts.get(0, 0)
        )
        num_vertices_of_deg_2 = vertex_degree_counts.get(2, 0)
        num_vertices_of_deg_3 = vertex_degree_counts.get(3, 0)
        num_vertices_of_deg_4 = vertex_degree_counts.get(4, 0)

        if (
            num_vertices_of_deg_3 == 2
            and num_vertices_of_deg_2 == (vertices_with_nonzero_degree - 2)
            and all(
                count == 0
                for deg, count in vertex_degree_counts.items()
                if deg != 0
                if deg != 2
                if deg != 3
            )
        ):
            return "K_{2, 3}"

        if (
            num_vertices_of_deg_3 == 6
            and num_vertices_of_deg_2 == (vertices_with_nonzero_degree - 6)
            and all(
                count == 0
                for deg, count in vertex_degree_counts.items()
                if deg != 0
                if deg != 2
                if deg != 3
            )
        ):
            return "K_{3, 3}"

        if (
            num_vertices_of_deg_3 == 4
            and num_vertices_of_deg_2 == (vertices_with_nonzero_degree - 4)
            and all(
                count == 0
                for deg, count in vertex_degree_counts.items()
                if deg != 0
                if deg != 2
                if deg != 3
            )
        ):
            return "K_4"

        if (
            num_vertices_of_deg_4 == 5
            and num_vertices_of_deg_2 == (vertices_with_nonzero_degree - 5)
            and all(
                count == 0
                for deg, count in vertex_degree_counts.items()
                if deg != 0
                if deg != 2
                if deg != 4
            )
        ):
            return "K_5"

        raise EdgeDeletionAnalysisError(
            "The obstruction found doesn't have the expected "
            "characteristics ofof any of K_5, K_{3, 3}, K_{2, 3}, or K_4; "
            f"see '{Path.joinpath(output_dir, obstruction_name)}'."
        )

    @staticmethod
    def _get_forbidden_minor_pair(
        extension_choice: str,
    ) -> tuple[str, str]:
        """Gets pair of "forbidden minors" for given extension choice

        Args:
            extension_choice: either 2 (K_{2, 3} search), 3 (K_{3, 3} search),
                or 4 (K_4 search)

        Returns:
            The pair of forbidden minors for the given extension choice
        """
        if extension_choice not in EDGE_DELETION_ANALYSIS_SPECIFIERS():
            raise EdgeDeletionAnalysisError(
                f"Invalid extension choice: '{extension_choice}'"
            )

        target_obstruction_correspondence = {
            "2": "K_{2, 3}",
            "3": "K_{3, 3}",
            "4": "K_4",
        }

        alternate_obstruction_correspondence = {
            "2": "K_4",
            "3": "K_5",
            "4": "K_{2, 3}",
        }

        target_obstruction_type = target_obstruction_correspondence[
            extension_choice
        ]
        alternate_obstruction_type = alternate_obstruction_correspondence[
            extension_choice
        ]

        return target_obstruction_type, alternate_obstruction_type

    @staticmethod
    def _get_specific_graph_alternate_check_names(
        extension_choice: str,
    ) -> tuple[str, str]:
        """
        Args:
            extension_choice: either 2 (K_{2, 3} search), 3 (K_{3, 3} search),
                or 4 (K_4 search)

        Returns:
            The pair of command_specifier and descriptor for the given
                extension choice
        """
        if extension_choice not in EDGE_DELETION_ANALYSIS_SPECIFIERS():
            raise EdgeDeletionAnalysisError(
                f"Invalid extension choice: '{extension_choice}'"
            )

        command_correspondence = {"2": "o", "3": "p", "4": "o"}

        descriptor_correspondence = {
            "2": "outerplanar",
            "3": "planar",
            "4": "outerplanar",
        }

        command_specifier = command_correspondence[extension_choice]
        descriptor = descriptor_correspondence[extension_choice]

        return command_specifier, descriptor

    @staticmethod
    def _read_adj_list_graph_repr(graph_path: Path) -> Graph:
        """Static method to read graph as adjacency list from file

        Args:
            graph_path: Path to 0-based adjacency-list representation of graph
                we wish to use to initialize a Graph object

        Returns:
            Graph with order and graph_adj_list_repr corresponding to file
            contents.

        Raises:
            EdgeDeletionAnalysisError: If file header is invalid, or if
                GraphError was encountered when we tried to add an edge based
                on file contents.
        """
        with open(graph_path, "r", encoding="utf-8") as graph_file:
            header = graph_file.readline()
            match = re.match(r"N=(?P<order>\d+)", header)
            if not match:
                raise EdgeDeletionAnalysisError(
                    f"Infile '{graph_path}' doesn't contain "
                    "an adjacency list: invalid header."
                )

            order = int(match.group("order"))
            graph = Graph(order)
            line_num = 0
            for line in graph_file:
                line_num += 1
                line_elements = line.split(":")
                u = int(line_elements[0])
                neighbours = [
                    int(v) for v in line_elements[1].split() if v if v != "-1"
                ]
                for v in neighbours:
                    try:
                        graph.add_arc(u, v)
                    except GraphError as e:
                        raise EdgeDeletionAnalysisError(
                            f"Unable to add edge ({u}, {v}) as specified on"
                            f"line {line_num} of '{graph_path}'."
                        ) from e

        return graph

    def _edge_deletion_analysis(  # pylint: disable=too-many-locals
        self, adj_list_path: Path, output_dir: Path
    ) -> bool:
        """Search for homeomorph by removing edges and running alternate check

        If the original graph was determined to not contain a subgraph
        homeomorphic to K_{2, 3} (extension choice is 2), K_{3, 3} (3), or
        K_4 (4), but was reported as nonplanar (3) or nonouterplanar (2, 4) and
        the obstruction found was homeomorphic to K_4 (2), K_5 (3) or
        K_{2, 3} (4), we want to see if there is no subgraph homeomorphic to
        K_{2, 3} (2), K_{3, 3} (3) or K_4 (4) with a high degree of confidence
        (not a guarantee).

        This is done by iterating over the graph_adj_list_repr of the original
        graph:
            - for each edge, if the head vertex label is greater than the
            tail vertex label, create a deepcopy of the original graph and
            remove that edge before running planarity/outerplanarity
            - if the graph-minus-one-edge is planar/outerplanar, we continue to
            the next loop iteration to see if removing a different edge will
            reveal the target obstruction
            - if the graph-minus-one-edge is nonplanar/nonouterplanar, we check
            the obstruction type:
              - if the obstruction is homeomorphic to the target homeomorph, we
              emit a message to indicate that we found a target homeomorph
              that was missed by their respective search
              - if the obstruction is homeomorphic to the K_4 (2), K_5 (3), or
              K_{2, 3} (4), run K_{2, 3} search (2), K_{3, 3} search (3), or
              K_4 search (4) on the graph-minus-one-edge; either:
                - we report that a subgraph homeomorphic to the target graph
                was missed by the original call to the graph search extension
                - we report that no subgraph homeomorphic to the target graph
                was found by the edge-deletion-analysis.
        It may be the case that the graph-minus-one-edge still has the same
        underlying structure that causes the issue with K_{2, 3} search (2),
        K_{3, 3} search (3), or K_4 search (4) on the original graph, so even
        this additional test is not a 100% guarantee of finding the target
        homeomorph that we should have found in the original graph.

        Args:
            adj_list_path: Path to adjacency list upon which to perform
                edge-deletion analysis
            output_dir: Directory to which you wish to output the results of
                edge-deletion analysis on the input graph

        Returns:
            bool indicating at least one K_{2, 3}/K_{3, 3}/K_4 was found as a
                result of the edge-deletion manipulation.

        Raises:
            EdgeDeletionAnalysisError is raised if:
                - the original adjacency list produced by the transform is
                1-based rather than the expected 0-based
                    - this could happen if rather than starting with a graph in
                    .g6 format, your input graph is an adjacency list produced
                    by planarity when NIL is set to 0 rather than -1, causing
                    gp_GetFirstVertex(theGraph) to return 1 and line
                    terminators to be set to 0 because
                    theGraph->internalFlags & FLAGS_ZEROBASEDIO is falsy
                - Deleting an edge from the copied graph fails
                - Running planarity on the original-graph-minus-one-edge fails
                - Determining the type of obstruction found fails
        """
        try:
            orig_graph = EdgeDeletionAnalyzer._read_adj_list_graph_repr(
                adj_list_path
            )
        except EdgeDeletionAnalysisError as e:
            raise EdgeDeletionAnalysisError(
                "Unable to read original graph adjacency list representation"
                f"from file '{adj_list_path}'."
            ) from e

        adj_list_stem = ".".join(adj_list_path.name.split(".")[:-3])
        adj_list_suffix = "".join(adj_list_path.suffixes[-3:])

        orig_graph_contains_homeomorph = False
        u = -1
        for adj_list in orig_graph.graph_adj_list_repr:
            u += 1
            adj_list_index = -1
            for v in adj_list:
                adj_list_index += 1
                if v < u:
                    continue

                orig_graph_minus_edge = deepcopy(orig_graph)
                try:
                    orig_graph_minus_edge.delete_edge(u, v)
                except EdgeDeletionAnalysisError as delete_edge_error:
                    raise EdgeDeletionAnalysisError(
                        f"Unable to delete edge {{{u}, {v}}} from copied graph"
                    ) from delete_edge_error

                orig_graph_minus_edge_path = Path.joinpath(
                    adj_list_path.parent,
                    f"{adj_list_stem}.rem{u}-{v}{adj_list_suffix}",
                )
                with open(
                    orig_graph_minus_edge_path, "w", encoding="utf-8"
                ) as outfile:
                    outfile.write(str(orig_graph_minus_edge))

                try:
                    obstruction_name = self._run_alternate_check(
                        orig_graph_minus_edge_path, output_dir
                    )
                except EdgeDeletionAnalysisError as e:
                    raise EdgeDeletionAnalysisError(
                        "Failed to run planarity on "
                        f"'{orig_graph_minus_edge_path}'."
                    ) from e

                if not obstruction_name:
                    continue

                try:
                    obstruction_type = self.determine_obstruction_type(
                        obstruction_name, output_dir
                    )
                except EdgeDeletionAnalysisError as e:
                    raise EdgeDeletionAnalysisError(
                        "Failed to determine obstruction type of graph "
                        f"produced by removing edge {{{u}, {v}}} from the "
                        "original graph."
                    ) from e
                planar_obstruction_path = Path.joinpath(
                    output_dir, obstruction_name
                )
                target_obstruction_type, alternate_obstruction_type = (
                    self._get_forbidden_minor_pair(self.extension_choice)
                )

                if obstruction_type == target_obstruction_type:
                    self.logger.info(
                        "'%s' contains a %s that was not found by %s search; "
                        "see '%s'.",
                        orig_graph_minus_edge_path,
                        target_obstruction_type,
                        target_obstruction_type,
                        planar_obstruction_path,
                    )
                    orig_graph_contains_homeomorph = True
                elif obstruction_type == alternate_obstruction_type:
                    self.logger.info(
                        "'%s' contains a subgraph homeomorphic to %s; see "
                        "'%s'. Attempting to see if edge-removal allows %s "
                        "search to find the target homeomorph.",
                        orig_graph_minus_edge_path,
                        alternate_obstruction_type,
                        planar_obstruction_path,
                        target_obstruction_type,
                    )
                    orig_graph_minus_edge_contains_homeomorph = (
                        self._run_homeomorph_search(orig_graph_minus_edge_path)
                    )
                    if orig_graph_minus_edge_contains_homeomorph:
                        self.logger.info(
                            "'%s' contains a %s that was not found by %s "
                            "search; see '%s'.",
                            orig_graph_minus_edge_path,
                            target_obstruction_type,
                            target_obstruction_type,
                            planar_obstruction_path,
                        )
                        orig_graph_contains_homeomorph = True
                    else:
                        self.logger.info(
                            "'%s' doesn't appear to contain a %s.",
                            orig_graph_minus_edge_path,
                            target_obstruction_type,
                        )

        return orig_graph_contains_homeomorph


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,
        usage="python %(prog)s [options]",
        description="Edge deletion analysis tool\n\n"
        "When given an input file, determine the type of input. If "
        "the file is a not a .g6 file, an error is raised. Otherwise, "
        "iterate over each line and create a separate .g6 file:\n"
        "\t{input_file.stem}.{line_num}.g6\n"
        "And perform the following steps on each graph:\n"
        "1. Runs\n"
        "\tplanarity -x -a {input_file} {infile_stem}.AdjList.out"
        ".txt\n"
        "to transform the graph to adjacency list\n"
        "2. Runs\n"
        "\tplanarity -s -{extension_choice} {infile_stem}.AdjList.out.txt "
        "{infile_stem}.AdjList.s.{extension_choice}.out.txt\n"
        "and report whether a subgraph homeomorphic to K_{2, 3} (extension "
        "choice is 2), K_{3, 3} (extension choice is 3), or K_4 (extension "
        "choice is 4) was found (NONEMBEDDABLE) or not (OK).\n"
        "3. If no subgraph homeomorphic to the target homeomorph was found "
        "(i.e. previous test yielded OK), run\n"
        "\tplanarity -s -p {infile_stem}.AdjList.out.txt "
        "{infile_stem}.AdjList.s.[po].out.txt {infile_stem}.AdjList.s.[po]."
        "obstruction.txt\n"
        "Where we run planarity if the extension choice is 3 or "
        "outerplanarity if the extension choice is 2 or 4.\n"
        "\ta. If the graph is reported as planar/outerplanar, then we can be "
        "sure the target homeomorph will not be present in the graph and "
        "execution terminates.\n"
        "\tb. If the graph was reported as nonplanar/nonouterplanar, examine "
        "the obstruction in \n"
        "\t\t{input_file}.AdjList.s.[po].obstruction.txt:\n"
        "\t\ti. If the obstruction is homeomorphic to K_{2, 3}/K_{3, 3}/K_4, "
        "then report that the original graph contains the target homeomorph "
        "that was not found by the respective graph search extension.\n"
        "\t\tii. If the obstruction is homeomorphic to the other forbidden "
        "minor (K_4 for K{2, 3}, K_5 for K_{3, 3}, or K_{2, 3} for K_4) then "
        "perform the edge-deletion analysis to determine if the original "
        "graph contains a subgraph homeomorphic to the target homeomorph that"
        "wasn't found by the corresponding graph search extension, or if the "
        "original graph doesn't contain the target homeomorph (with high "
        "confidence).",
    )
    parser.add_argument(
        "-p",
        "--planaritypath",
        type=Path,
        required=True,
        help="Path to planarity executable",
        metavar="PATH_TO_PLANARITY_EXECUTABLE",
    )
    parser.add_argument(
        "-i",
        "--inputfile",
        type=Path,
        required=True,
        help="Path to graph(s) to analyze",
        metavar="PATH_TO_GRAPH(s)",
    )
    parser.add_argument(
        "-o",
        "--outputdir",
        type=Path,
        default=None,
        metavar="OUTPUT_DIR_PATH",
        help="Parent directory under which subdirectory named after "
        "{infile_stem} will be created for output results. If none "
        "provided, defaults to:\n"
        "\tTestSupport/results/edge_deletion_analysis/{infile_stem}",
    )
    parser.add_argument(
        "-c",
        "--command",
        type=str,
        metavar="ALGORITHM_COMMAND",
        default="3",
        help="Graph algorithm command specifier, either 2 (K_{2, 3} search), "
        "3 (K_{3, 3} search), or 4 (K_4 search)",
    )

    args = parser.parse_args()

    eda = EdgeDeletionAnalyzer(
        planarity_path=args.planaritypath,
        infile_path=args.inputfile,
        output_dir=args.outputdir,
        extension_choice=args.command,
    )

    num_invalidOKs = eda.analyze_graphs()
    eda.logger.info("NUMBER OF INVALID OKs: %d", num_invalidOKs)
