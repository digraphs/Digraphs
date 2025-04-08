"""Generate .g6 files, run planarity, identify discrepancies, and perform diffs

Classes:
    G6GenerationAndComparisonDriver

Functions:
    parse_range(value: str) -> tuple
"""  # pylint: disable=too-many-lines

#!/usr/bin/env python

__all__ = []

import sys
import os
import shutil
import argparse
from pathlib import Path
import subprocess
from typing import Optional
import json

from graph_generation_orchestrator import distribute_geng_workload
from planarity_testAllGraphs_orchestrator import (
    distribute_planarity_testAllGraphs_workload,
)
from g6_diff_finder import G6DiffFinder, G6DiffFinderException
from planaritytesting_utils import (
    PLANARITY_ALGORITHM_SPECIFIERS,
    max_num_edges_for_order,
    is_path_to_executable,
    parse_range,
)
from planarity_testAllGraphs_output_parsing import process_file_contents


class G6GenerationAndComparisonDriver:
    """Generates .g6 files, runs planarity, and identifies discrepancies"""

    def __init__(
        self,
        geng_path: Path,
        orders: tuple,
        planarity_path: Optional[Path] = None,
        planarity_backup_path: Optional[Path] = None,
        output_parent_dir: Optional[Path] = None,
    ):  # pylint: disable=too-many-arguments
        """Initializes G6GenerationAndComparisonDriver instance.

        Args:
            geng_path: The path to the nauty geng executable used to generate
                .g6 graph files for each order and edge-count
            orders: A tuple of ints corresponding to the graph orders for which
                we wish to perform the graph generation and comparison
            planarity_path: The path to the edge-addition-planarity-suite
                executable
            planarity_backup_path: The path to the planarity-backup executable
                (optional; used to generate the makeg .g6 files)
            output_parent_dir: Directory to which you wish to output results

        Raises:
            argparse.ArgumentError: Re-raises if any of the arguments were
                invalid
        """
        try:
            (
                geng_path,
                orders,
                planarity_path,
                planarity_backup_path,
                output_parent_dir,
            ) = self._validate_and_normalize_input(
                geng_path,
                orders,
                planarity_path,
                planarity_backup_path,
                output_parent_dir,
            )
        except argparse.ArgumentError as e:
            raise argparse.ArgumentError(
                argument=None,
                message="Invalid parameters; unable to proceed with "
                "generation and comparison.",
            ) from e

        self.geng_path = geng_path
        self.orders = orders
        self.planarity_path = planarity_path
        self.planarity_backup_path = planarity_backup_path
        self.output_parent_dir = output_parent_dir

        self.planarity_discrepancies = {}

    def _validate_and_normalize_input(  # pylint: disable=too-many-arguments
        self,
        geng_path: Path,
        orders: tuple,
        planarity_path: Optional[Path] = None,
        planarity_backup_path: Optional[Path] = None,
        output_parent_dir: Optional[Path] = None,
    ) -> tuple[Path, tuple[int, ...], Path, Optional[Path], Path]:
        """Validates G6GenerationAndComparisonDriver initialization values

        Args:
            geng_path: Path to geng executable
            orders: Tuple containing orders of graphs for which you wish to
                generate the .g6 files
            planarity_path: Path to planarity executable; defaults to:
                    Release/planarity
            planarity_backup_path: Path to planarity-backup executable, or None
            output_parent_dir: Path to directory to which you wish to output
                .g6 files and comparison results; defaults to:
                    TestSupport/results/g6_generation_and_comparison_driver/

        Returns:
            A tuple comprised of the valid and normalized input in their
                original order.
        Raises:
            argparse.ArgumentTypeError: If any of the arguments were invalid
        """
        if not is_path_to_executable(geng_path):
            raise argparse.ArgumentTypeError(
                f"Path for geng executable '{geng_path}' does not correspond "
                "to an executable."
            )

        if not orders:
            raise argparse.ArgumentTypeError("No graph orders given.")

        if any(
            order
            for order in orders
            if order < 2
            if order > 12
            if not isinstance(order, int)
        ):
            raise argparse.ArgumentTypeError(
                "Desired graph orders must be integers between 2 an 12 "
                "inclusive."
            )

        planarity_project_root = (
            Path(sys.argv[0]).resolve().parent.parent.parent
        )

        if not planarity_path:
            planarity_path = Path.joinpath(
                planarity_project_root, "Release", "planarity"
            )

        if not is_path_to_executable(planarity_path):
            raise argparse.ArgumentTypeError(
                f"Path for planarity executable '{planarity_path}' does not "
                "correspond to an executable."
            )

        if planarity_backup_path and not is_path_to_executable(
            planarity_backup_path
        ):
            raise argparse.ArgumentTypeError(
                "Path for planarity_backup executable "
                f"'{planarity_backup_path}' does not correspond to an "
                "executable."
            )

        if not output_parent_dir:
            output_parent_dir = Path.joinpath(
                planarity_project_root,
                "TestSupport",
                "results",
                "g6_generation_and_comparison_driver",
            )
            Path.mkdir(output_parent_dir, parents=True, exist_ok=True)
            for order in orders:
                candidate_output_dir = Path.joinpath(
                    output_parent_dir, f"{order}"
                )
                if Path.is_dir(candidate_output_dir):
                    shutil.rmtree(candidate_output_dir)

        if (
            not isinstance(output_parent_dir, Path)
            or not output_parent_dir.is_dir()
        ):
            raise argparse.ArgumentTypeError(
                "Output directory path is invalid."
            )

        return (
            geng_path,
            orders,
            planarity_path,
            planarity_backup_path,
            output_parent_dir,
        )

    def generate_g6_files(self):
        """Generate .g6 files using nauty geng and planarity-backup's makeg

        For each graph order in self.orders, uses the graph generation
        orchestrator to generate the geng .g6 and geng canonical .g6 files (all
        graphs of a single edge-count per file), then if the path to the
        planarity-backup executable was provided, calls this executable for
        each edge-count from 0 to (N * (N - 1)) / 2 to generate the makeg .g6
        and makeg canonical .g6 files.
        """
        for order in self.orders:
            g6_output_dir_for_order = Path.joinpath(
                self.output_parent_dir, f"{order}"
            )
            self._generate_geng_g6_files_for_order(
                order, g6_output_dir_for_order
            )

            if self.planarity_backup_path:
                for num_edges in range(max_num_edges_for_order(order) + 1):
                    self._generate_makeg_g6_files_for_order_and_num_edges(
                        order, num_edges
                    )

    def _generate_geng_g6_files_for_order(
        self, order: int, geng_g6_output_dir_for_order: Path
    ):
        """Parallelize geng calls

        Args:
            order: The graph order for which we wish to generate all graphs
                for each edge-count
            geng_g6_output_dir_for_order: Directory to which we wish to output
                the geng .g6 and geng canonical .g6 graph files
        """
        distribute_geng_workload(
            geng_path=self.geng_path,
            canonical_files=False,
            order=order,
            output_dir=geng_g6_output_dir_for_order,
        )

        distribute_geng_workload(
            geng_path=self.geng_path,
            canonical_files=True,
            order=order,
            output_dir=geng_g6_output_dir_for_order,
        )

    def _generate_makeg_g6_files_for_order_and_num_edges(
        self, order: int, num_edges: int, command: str = "3"
    ):
        """Generate makeg .g6 and makeg canonical .g6 files

        The makeg .g6 and makeg canonical .g6 files generated have paths:
            {self.output_parent_dir}/{order}/
                n{order}.m{num_edges}.makeg(.canonical)?.g6
        Which is an intermediate directory required for the use of the
        planarity_testAllGraphs_orchestrator (which runs on all .g6 files in
        the given root directory matching a specific pattern indicated by the
        canonical_files and makeg_g6 flags)

        The output files of planarity-backup's Test All Graphs for the
        given algorithm command specifier have paths:
            {self.output_parent_dir}/{order}/planarity_results/{command}/
                {num_edges}/planarity-backup-output_n{order}.m{num_edges}.makeg(.canonical)?.{command}.out.txt

        Args:
            order: Order of graphs to generate
            num_edges: Restricts .g6 output file to contain only graphs with
                the desired edge-count
            command: Algorithm command specifier to use when testing all graphs
                of the given order and edge-count (Defaults to '3'
                corresponding to K_{3, 3} search)
        """  # pylint: disable=line-too-long
        g6_output_dir_for_order_and_edgecount = Path.joinpath(
            self.output_parent_dir, f"{order}"
        )
        Path.mkdir(
            g6_output_dir_for_order_and_edgecount, parents=True, exist_ok=True
        )

        planarity_backup_outfile_dir = Path.joinpath(
            self.output_parent_dir,
            f"{order}",
            "planarity_results",
            f"{command}",
            f"{num_edges}",
        )
        Path.mkdir(planarity_backup_outfile_dir, parents=True, exist_ok=True)

        self._generate_makeg_g6_file_for_order_and_num_edges(
            g6_output_dir_for_order_and_edgecount,
            planarity_backup_outfile_dir,
            order,
            num_edges,
            False,
            command,
        )
        self._generate_makeg_g6_file_for_order_and_num_edges(
            g6_output_dir_for_order_and_edgecount,
            planarity_backup_outfile_dir,
            order,
            num_edges,
            True,
            command,
        )

    def _generate_makeg_g6_file_for_order_and_num_edges(  # pylint: disable=too-many-arguments
        self,
        g6_output_dir_for_order_and_edgecount: Path,
        planarity_backup_outfile_dir: Path,
        order: int,
        num_edges: int,
        canonical_files: bool,
        command: str = "3",
    ):
        """Run planarity-backup executable to generate makeg .g6 files

        Runs the old planarity-backup code with the given algorithm command
        specifier (defaults to K_{3, 3} search) to test all graphs of a given
        order and edge-count to determine the number of OKs (no K_{3, 3}) vs.
        number of NONEMBEDDABLEs (contains a K_{3, 3})

        The graphs generated by makeg are written to file:
            {g6_output_dir_for_order_and_edgecount}/
                n{order}.m{num_edges}.makeg(.canonical)?.g6

        Args:
            g6_output_dir_for_order_and_edgecount: (Intermediate) directory to
                which you wish to output makeg .g6 files for the given order
                and edge-count
            planarity_backup_outfile_dir: (Intermediate) directory to which you
                wish to output the results of running the planarity-backup
                executable for the given command specifier on all graphs of the
                given order and edge-count
            order: Order of graphs to generate
            num_edges: Restricts .g6 output file to contain only graphs with
                the desired edge-count
            canonical_files: Indicates whether or not makeg should generate
                canonical .g6 graphs
            command: Algorithm command specifier to use when testing all graphs
                of the given order and edge-count (Defaults to '3'
                corresponding to K_{3, 3} search)
        """
        canonical_ext = ".canonical" if canonical_files else ""
        planarity_backup_outfile_name = Path.joinpath(
            planarity_backup_outfile_dir,
            f"planarity-backup-output_n{order}.m{num_edges}."
            + f"makeg{canonical_ext}.{command}.out.txt",
        )
        with open(
            planarity_backup_outfile_name, "w", encoding="utf-8"
        ) as makeg_outfile:
            planarity_backup_args = [
                f"{self.planarity_backup_path}",
                "-gen",
                f"{g6_output_dir_for_order_and_edgecount}",
                f"-{command}",
                f"{order}",
                f"{num_edges}",
                f"{num_edges}",
            ]
            if canonical_files:
                planarity_backup_args.insert(4, "-l")
            subprocess.run(
                planarity_backup_args,
                stdout=makeg_outfile,
                stderr=subprocess.PIPE,
                check=False,
            )

    def run_planarity(self):
        """Runs planarity on all .g6 files

        For each graph order in self.orders, runs planarity Test All Graphs
        for every algorithm command specifier on all geng .g6 and geng
        canonical .g6 files:
            {self.output_parent_dir}/{order}/
                n{order}.m{num_edges}(.canonical)?.g6

        If a path to the planarity-backup executable was provided, runs
        planarity Test All Graphs for every algorithm command specifier on all
        makeg .g6 and makeg canonical .g6 files:
            {self.output_parent_dir}/{order}/
                n{order}.m{num_edges}(.makeg)?(.canonical)?.g6
        """
        for order in self.orders:
            geng_g6_output_dir_for_order = Path.joinpath(
                self.output_parent_dir, f"{order}"
            )
            planarity_output_dir_for_order = Path.joinpath(
                self.output_parent_dir, "results", f"{order}"
            )
            self._run_planarity_on_g6_files_for_order(
                order,
                geng_g6_output_dir_for_order,
                planarity_output_dir_for_order,
                makeg_g6=False,
            )

            if self.planarity_backup_path:
                self._run_planarity_on_g6_files_for_order(
                    order,
                    geng_g6_output_dir_for_order,
                    planarity_output_dir_for_order,
                    makeg_g6=True,
                )

    def _run_planarity_on_g6_files_for_order(
        self,
        order: int,
        g6_output_dir_for_order: Path,
        planarity_output_dir_for_order: Path,
        makeg_g6: bool,
    ):
        """Parallelize running planarity TestAllGraphs for all commands

        Args:
            order: Order of graphs in .g6 files on which planarity's Test All
                Graphs shall be run for the given command
            g6_output_dir_for_order: Directory containing the input .g6 files,
                one file per num_edges for a given graph order.
            planarity_output_dir_for_order: Directory to which results of
                running planarity on each .g6 file containing all graphs of a
                specific num_edges for the given graph order shall be output
            makeg_g6: Flag to indicate that the .g6 files taken as input were
                generated using planarity-backup's makeg
        """
        distribute_planarity_testAllGraphs_workload(
            planarity_path=self.planarity_path,
            canonical_files=False,
            makeg_g6=makeg_g6,
            order=order,
            input_dir=g6_output_dir_for_order,
            output_dir=planarity_output_dir_for_order,
        )

        distribute_planarity_testAllGraphs_workload(
            planarity_path=self.planarity_path,
            canonical_files=True,
            makeg_g6=makeg_g6,
            order=order,
            input_dir=g6_output_dir_for_order,
            output_dir=planarity_output_dir_for_order,
        )

    def reorganize_files(self):
        """Reorganize .g6 and planarity Test All Graphs output files

        After run_planarity(), the various .g6 files and planarity Test All
        Graphs output files must be reorganized to make subsequent processing
        easier.
        """
        for order in self.orders:
            orig_geng_g6_output_dir_for_order = Path.joinpath(
                self.output_parent_dir, f"{order}"
            )
            for num_edges in range(max_num_edges_for_order(order) + 1):
                self._move_g6_files(
                    order, num_edges, orig_geng_g6_output_dir_for_order
                )
                self._move_planarity_output_files(
                    order, num_edges, orig_geng_g6_output_dir_for_order
                )

        shutil.rmtree(Path.joinpath(self.output_parent_dir, "results"))

    def _move_g6_files(
        self, order: int, num_edges: int, g6_output_dir_for_order: Path
    ):
        """Sort generated .g6 files into sub-dirs by graph edge-count

        After moving, {self.output_parent_dir}/{order}/graphs/{num_edges}/
        contains:
            n{order}.m{num_edges}.g6
            n{order}.m{num_edges}.canonical.g6
        If planarity-backup path provided, also shall include:
            n{order}.m{num_edges}.makeg.g6
            n{order}.m{num_edges}.makeg.canonical.g6

        Args:
            order: Order of graphs contained in the .g6 files to move
            num_edges: Only move the .g6 files that contain all graphs of a
                specific edge-count
            g6_output_dir_for_order: Original directory containing the .g6
                files produced by generate_g6_files()
        """
        g6_output_dir_for_order_and_edgecount = Path.joinpath(
            g6_output_dir_for_order, "graphs", f"{num_edges}"
        )

        Path.mkdir(
            g6_output_dir_for_order_and_edgecount, parents=True, exist_ok=True
        )

        geng_g6_outfile_name = f"n{order}.m{num_edges}.g6"
        self._move_file(
            g6_output_dir_for_order,
            geng_g6_outfile_name,
            g6_output_dir_for_order_and_edgecount,
        )

        geng_canonical_g6_outfile_name = f"n{order}.m{num_edges}.canonical.g6"
        self._move_file(
            g6_output_dir_for_order,
            geng_canonical_g6_outfile_name,
            g6_output_dir_for_order_and_edgecount,
        )

        if self.planarity_backup_path:
            makeg_g6_outfile_name = f"n{order}.m{num_edges}.makeg.g6"
            self._move_file(
                g6_output_dir_for_order,
                makeg_g6_outfile_name,
                g6_output_dir_for_order_and_edgecount,
            )

            makeg_canonical_g6_outfile_name = (
                f"n{order}.m{num_edges}.makeg.canonical.g6"
            )
            self._move_file(
                g6_output_dir_for_order,
                makeg_canonical_g6_outfile_name,
                g6_output_dir_for_order_and_edgecount,
            )

    def _move_planarity_output_files(
        self, order: int, num_edges: int, new_output_dir_for_order: Path
    ):
        """Sort planarity output files into sub-dirs by command and edge-count

        After moving, {order}/planarity_results/{command}/{num_edges}/
        contains:
            n{order}.m{num_edges}.{command}.out.txt
            n{order}.m{num_edges}.canonical.{command}.out.txt
        If planarity-backup path provided, also shall include:
            n{order}.m{num_edges}.makeg.{command}.out.txt
            n{order}.m{num_edges}.makeg.canonical.{command}.out.txt

        Args:
            order: Order of graphs contained in the .g6 files taken as input to
                planarity Test All Graphs
            num_edges: Only move the planarity output files corresponding to
                specific edge-count
            new_output_dir_for_order: Directory under which new subdirectory,
                planarity_results/, should be created
        """
        for command in PLANARITY_ALGORITHM_SPECIFIERS():
            orig_planarity_output_dir = Path.joinpath(
                self.output_parent_dir, "results", f"{order}", f"{command}"
            )
            new_planarity_output_dir_for_order_and_edgecount = Path.joinpath(
                new_output_dir_for_order,
                "planarity_results",
                f"{command}",
                f"{num_edges}",
            )

            Path.mkdir(
                new_planarity_output_dir_for_order_and_edgecount,
                parents=True,
                exist_ok=True,
            )

            g6_planarity_outfile_name = (
                f"n{order}.m{num_edges}.{command}.out.txt"
            )
            self._move_file(
                orig_planarity_output_dir,
                g6_planarity_outfile_name,
                new_planarity_output_dir_for_order_and_edgecount,
            )

            canonical_g6_planarity_outfile_name = (
                f"n{order}.m{num_edges}.canonical.{command}.out.txt"
            )
            self._move_file(
                orig_planarity_output_dir,
                canonical_g6_planarity_outfile_name,
                new_planarity_output_dir_for_order_and_edgecount,
            )

            if self.planarity_backup_path:
                makeg_g6_planarity_outfile_name = (
                    f"n{order}.m{num_edges}.makeg.{command}.out.txt"
                )
                self._move_file(
                    orig_planarity_output_dir,
                    makeg_g6_planarity_outfile_name,
                    new_planarity_output_dir_for_order_and_edgecount,
                )

                canonical_makeg_g6_planarity_outfile_name = (
                    f"n{order}.m{num_edges}.makeg.canonical.{command}.out.txt"
                )
                self._move_file(
                    orig_planarity_output_dir,
                    canonical_makeg_g6_planarity_outfile_name,
                    new_planarity_output_dir_for_order_and_edgecount,
                )

    def _move_file(self, src_dir: Path, filename: str, dest_dir: Path):
        """Moves {src_dir}/{filename} to {dest_dir}/

        If a file with name {filename} occurs in {dest_dir}, we os.remove() it
        before we shutil.move() the file to the {dest_dir}.

        Args:
            src_dir: Directory containing the file to move
            filename: Name of the file to be moved
            dest_dir: Directory to which we wish to move the file
        """
        src_path = Path.joinpath(src_dir, filename)
        dest_path = Path.joinpath(dest_dir, filename)
        if Path.is_file(dest_path):
            os.remove(dest_path)

        shutil.move(src_path, dest_dir)

    def find_planarity_discrepancies(self):
        """Find graph order, edge-count, and command w/ planarity disagreements

        If the sub-dicts for geng_g6, makeg_g6, geng_canonical_g6, and
        makeg_canonical_g6 disagree for a given order, num_edges, and command,
        then the structure will be as follows:
        {
            f"{order}": {
                f"{num_edges}" : {
                    f"{command}: {
                        "geng_g6": {
                            'numGraphs': numGraphs_from_file,
                            'numOK': numOK_from_file,
                            'numNONEMBEDDABLE': numNONEMBEDDABLE_from_file,
                        },
                        "makeg_g6": {
                            'numGraphs': numGraphs_from_file,
                            'numOK': numOK_from_file,
                            'numNONEMBEDDABLE': numNONEMBEDDABLE_from_file,
                        },
                        "geng_canonical_g6": {
                            'numGraphs': numGraphs_from_file,
                            'numOK': numOK_from_file,
                            'numNONEMBEDDABLE': numNONEMBEDDABLE_from_file,
                        },
                        "makeg_canonical_g6": {
                            'numGraphs': numGraphs_from_file,
                            'numOK': numOK_from_file,
                            'numNONEMBEDDABLE': numNONEMBEDDABLE_from_file,
                        }
                    }
                    ...
                }
                ...
            }
            ...
        }
        """
        for order in self.orders:
            planarity_output_dir = Path.joinpath(
                self.output_parent_dir, f"{order}", "planarity_results"
            )
            self.planarity_discrepancies[order] = {}
            for num_edges in range(max_num_edges_for_order(order) + 1):
                self.planarity_discrepancies[order][num_edges] = {}
                for command in PLANARITY_ALGORITHM_SPECIFIERS():
                    self.planarity_discrepancies[order][num_edges][
                        command
                    ] = {}

                    planarity_output_dir_for_order_and_edgecount = (
                        Path.joinpath(
                            planarity_output_dir, f"{command}", f"{num_edges}"
                        )
                    )

                    geng_g6_output = Path.joinpath(
                        planarity_output_dir_for_order_and_edgecount,
                        f"n{order}.m{num_edges}.{command}.out.txt",
                    )
                    self._extract_planarity_results(
                        geng_g6_output, order, num_edges, command, "geng_g6"
                    )

                    geng_canonical_g6_output = Path.joinpath(
                        planarity_output_dir_for_order_and_edgecount,
                        f"n{order}.m{num_edges}.canonical.{command}.out.txt",
                    )
                    self._extract_planarity_results(
                        geng_canonical_g6_output,
                        order,
                        num_edges,
                        command,
                        "geng_canonical_g6",
                    )

                    if self.planarity_backup_path:
                        makeg_g6_output = Path.joinpath(
                            planarity_output_dir_for_order_and_edgecount,
                            f"n{order}.m{num_edges}.makeg.{command}.out.txt",
                        )
                        self._extract_planarity_results(
                            makeg_g6_output,
                            order,
                            num_edges,
                            command,
                            "makeg_g6",
                        )

                        makeg_canonical_g6_output = Path.joinpath(
                            planarity_output_dir_for_order_and_edgecount,
                            f"n{order}.m{num_edges}.makeg.canonical."
                            + f"{command}.out.txt",
                        )
                        self._extract_planarity_results(
                            makeg_canonical_g6_output,
                            order,
                            num_edges,
                            command,
                            "makeg_canonical_g6",
                        )

                        if (
                            self.planarity_discrepancies[order][num_edges][
                                command
                            ]["geng_g6"]
                            == self.planarity_discrepancies[order][num_edges][
                                command
                            ]["makeg_g6"]
                            == self.planarity_discrepancies[order][num_edges][
                                command
                            ]["geng_canonical_g6"]
                            == self.planarity_discrepancies[order][num_edges][
                                command
                            ]["makeg_canonical_g6"]
                        ):
                            del self.planarity_discrepancies[order][num_edges][
                                command
                            ]
                    else:
                        if (
                            self.planarity_discrepancies[order][num_edges][
                                command
                            ]["geng_g6"]
                            == self.planarity_discrepancies[order][num_edges][
                                command
                            ]["geng_canonical_g6"]
                        ):
                            del self.planarity_discrepancies[order][num_edges][
                                command
                            ]

                if not self.planarity_discrepancies[order][num_edges]:
                    del self.planarity_discrepancies[order][num_edges]
            planarity_discrepancies_for_order_outfile_path = Path.joinpath(
                planarity_output_dir, f"n{order}.planarity_discrepancies.txt"
            )
            with open(
                planarity_discrepancies_for_order_outfile_path,
                "w",
                encoding="utf-8",
            ) as planarity_discrepancies_for_order_outfile:
                planarity_discrepancies_for_order_outfile.write(
                    "Discrepancies in planarity output results for order "
                    f"{order} by edge-count and algorithm specifier:\n"
                    "======\n"
                )
                planarity_discrepancies_for_order_outfile.write(
                    json.dumps(self.planarity_discrepancies[order], indent=4)
                )

    def _extract_planarity_results(
        self,
        planarity_outfile: Path,
        order: int,
        num_edges: int,
        command: str,
        file_type: str,
    ):
        """Use planarity_testAllGraphs_output_parsing to parse planarity output

        Args:
            planarity_outfile: The output of having run planarity Test All
                Graphs for the given algorithm command specifier for all graphs
                of a specific order and num_edges
            order: Order of graphs in .g6 file on which planarity's Test All
                Graphs was run for the given command to produce the outfile
            num_edges: Number of edges for graphs in the .g6 file
            command: Algorithm command specifier
            file_type: One of geng_g6, makeg_g6, geng_canonical_g6, or
                makeg_canonical_g6, indicating the type of the original .g6
                input file
        """
        (
            _,
            _,
            numGraphs_from_file,
            numOK_from_file,
            numNONEMBEDDABLE_from_file,
            _,
        ) = process_file_contents(planarity_outfile, command)

        self.planarity_discrepancies[order][num_edges][command][file_type] = {
            "numGraphs": numGraphs_from_file,
            "numOK": numOK_from_file,
            "numNONEMBEDDABLE": numNONEMBEDDABLE_from_file,
        }

    def get_planarity_discrepancy_g6_diffs(
        self,
    ):  # pylint: disable=too-many-locals
        """Get .g6 file diffs only if discrepancies exist in planarity output

        Since discrepancies in planarity results for all graphs of a given
        order and edge-count must only occur on graphs that appear in one .g6
        file but not the other, it was useful to use the G6DiffFinder to narrow
        down the set of graphs for which there occurred more OKs vs.
        NONEMBEDDABLEs.

        The dictionary self.planarity_discrepancies is populated during the
        course of find_planarity_discrepancies().

        To avoid duplicating work, the dictionary diffs_performed maps graph
        orders to a set of edge-counts for which we have already
        performed the diffs between the various .g6 file combinations:
        {
            f"{order}": {
                e_0, e_1, ..., e_k
            }
            ...
        }

        The logs in
            {self.output_parent_dir}/{order}/g6_diff_finder_logs/
        contain log.info messages emitted by the G6DiffFinder when comparing:

        - geng .g6 vs. geng canonical .g6
            - G6DiffFinder.n{order}.geng_vs_geng-canonical.log
        - geng .g6 vs. makeg .g6
            - G6DiffFinder.n{order}.geng_vs_makeg.log
        - geng .g6 vs. makeg canonical .g6
            - G6DiffFinder.n{order}.geng_vs_makeg-canonical.log
        - geng canonical .g6 vs. makeg canonical .g6
            - G6DiffFinder.n{order}.geng-canonical_vs_makeg-canonical.log
        - makeg .g6 vs. makeg canonical .g6
            - G6DiffFinder.n{order}.makeg_vs_makeg-canonical.log

        Up to 10 diff files will be output to the directory
            {self.output_parent_dir}/{order}/{graphs}/{num_edges}/{results}/
        - geng .g6 vs. geng canonical .g6 corresponds to the files:
            - graphs_in_n{order}.m{num_edges}_not_in_n{order}.m{num_edges}.canonical.g6
            - graphs_in_n{order}.m{num_edges}.canonical_not_in_n{order}.m{num_edges}.g6
        - geng .g6 vs. makeg .g6 corresponds to the files:
            - graphs_in_n{order}.m{num_edges}_not_in_n{order}.m{num_edges}.makeg.g6
            - graphs_in_n{order}.m{num_edges}.makeg_not_in_n{order}.m{num_edges}.g6
        - geng .g6 vs. makeg canonical .g6 corresponds to the files:
            - graphs_in_n{order}.m{num_edges}_not_in_n{order}.m{num_edges}.makeg.canonical.g6
            - graphs_in_n{order}.m{num_edges}.makeg.canonical_not_in_n{order}.m{num_edges}.g6
        - geng canonical .g6 vs. makeg canonical .g6 corresponds to the files:
            - graphs_in_n{order}.m{num_edges}.canonical_not_in_n{order}.m{num_edges}.makeg.canonical.g6
            - graphs_in_n{order}.m{num_edges}.makeg.canonical_not_in_n{order}.m{num_edges}.canonical.g6
        - makeg .g6 vs. makeg canonical .g6 corresponds to the files:
            - graphs_in_n{order}.m{num_edges}.makeg_not_in_n{order}.m{num_edges}.makeg.canonical.g6
            - graphs_in_n{order}.m{num_edges}.makeg.canonical_not_in_n{order}.m{num_edges}.makeg.g6
        """  # pylint: disable=line-too-long
        diffs_performed = {}
        for (
            order,
            discrepancies_for_order,
        ) in self.planarity_discrepancies.items():
            if not diffs_performed.get(order):
                diffs_performed[order] = set()

            output_dir_for_order = Path.joinpath(
                self.output_parent_dir, f"{order}"
            )
            log_dir_for_order = Path.joinpath(
                output_dir_for_order,
                "g6_diff_finder_logs",
            )
            Path.mkdir(log_dir_for_order, parents=True, exist_ok=True)

            log_path_for_geng_g6_vs_geng_canonical_g6 = Path.joinpath(
                log_dir_for_order,
                f"G6DiffFinder.n{order}.geng_vs_geng-canonical.log",
            )
            log_path_for_makeg_g6_vs_makeg_canonical_g6 = Path.joinpath(
                log_dir_for_order,
                f"G6DiffFinder.n{order}.makeg_vs_makeg-canonical.log",
            )
            log_path_for_geng_g6_vs_makeg_g6 = Path.joinpath(
                log_dir_for_order, f"G6DiffFinder.n{order}.geng_vs_makeg.log"
            )
            log_path_for_geng_canonical_g6_vs_makeg_canonical_g6 = (
                Path.joinpath(
                    log_dir_for_order,
                    f"G6DiffFinder.n{order}."
                    + "geng-canonical_vs_makeg-canonical.log",
                )
            )
            log_path_for_geng_g6_vs_makeg_canonical_g6 = Path.joinpath(
                log_dir_for_order,
                f"G6DiffFinder.n{order}.geng_vs_makeg-canonical.log",
            )

            for num_edges in discrepancies_for_order.keys():
                if num_edges in diffs_performed[order]:
                    continue

                diffs_performed[order].add(num_edges)

                g6_files_for_order_and_edgecount = Path.joinpath(
                    output_dir_for_order, "graphs", f"{num_edges}"
                )
                geng_g6_path = Path.joinpath(
                    g6_files_for_order_and_edgecount,
                    f"n{order}.m{num_edges}.g6",
                )
                geng_canonical_g6_path = Path.joinpath(
                    g6_files_for_order_and_edgecount,
                    f"n{order}.m{num_edges}.canonical.g6",
                )
                makeg_g6_path = Path.joinpath(
                    g6_files_for_order_and_edgecount,
                    f"n{order}.m{num_edges}.makeg.g6",
                )
                makeg_canonical_g6_path = Path.joinpath(
                    g6_files_for_order_and_edgecount,
                    f"n{order}.m{num_edges}.makeg.canonical.g6",
                )

                self._get_diffs(
                    geng_g6_path,
                    geng_canonical_g6_path,
                    log_path_for_geng_g6_vs_geng_canonical_g6,
                )

                if self.planarity_backup_path:
                    self._get_diffs(
                        geng_g6_path,
                        makeg_g6_path,
                        log_path_for_geng_g6_vs_makeg_g6,
                    )
                    self._get_diffs(
                        geng_g6_path,
                        makeg_canonical_g6_path,
                        log_path_for_geng_g6_vs_makeg_canonical_g6,
                    )
                    # Don't bother with geng canonical vs. makeg, because makeg
                    # and geng are so similar; only do the other 4 possible
                    # pairings (4C2 - 1 = 5 cases, which each produce 2 files)
                    self._get_diffs(
                        geng_canonical_g6_path,
                        makeg_canonical_g6_path,
                        log_path_for_geng_canonical_g6_vs_makeg_canonical_g6,
                    )
                    self._get_diffs(
                        makeg_g6_path,
                        makeg_canonical_g6_path,
                        log_path_for_makeg_g6_vs_makeg_canonical_g6,
                    )

    def _get_diffs(
        self,
        first_comparand_infile: Path,
        second_comparand_infile: Path,
        log_path: Path,
    ):
        """Uses G6DiffFinder to output set differences of two .g6 infiles

        Args:
            first_comparand_infile: Path to first .g6 comparand infile
            second_comparand_infile: Path to second .g6 comparand infile
            log_path: Path to which logs should be written

        Raises:
            G6DiffFinderException: If an error occurred during the processing
                of the two .g6 comparand infiles
        """
        try:
            g6_diff_finder = G6DiffFinder(
                first_comparand_infile, second_comparand_infile, log_path
            )
        except Exception as g6_diff_finder_error:
            raise G6DiffFinderException(
                "Unable to initialize G6DiffFinder with given input files: "
                f"'{first_comparand_infile}', '{second_comparand_infile}'"
            ) from g6_diff_finder_error

        try:
            g6_diff_finder.graph_set_diff()
        except BaseException as e:
            raise G6DiffFinderException(
                "Failed to discern diff between two .g6 input files."
            ) from e


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,
        usage="python %(prog)s [options]",
        description="G6 File Generation and Comparison Tool\n\n"
        "For each graph order in the specified range, a child directory "
        "of the output directory will be created named 'n{order}'. This "
        "directory will contain subdirectories:\n"
        "- graphs/\n"
        "\t- For each edge-count from 0 to (N * (N - 1)) / 2, a "
        "directory is created to contain:\n"
        "\tn{order}.m{num_edges}.g6\n"
        "\tn{order}.m{num_edges}.canonical.g6\n"
        "\tn{order}.m{num_edges}.makeg.g6 (req. planarity-backup "
        "\tpath)\n"
        "\tn{order}.m{num_edges}.makeg.canonical.g6 (req. "
        "planarity-backup path)\n"
        "\t- results/ which will contain the diffs of these .g6 "
        " files, pairs of files:\n"
        "\t\t- graphs_in_{first_infile}_not_in_{second_infile}.g6\n"
        "\t\t- graphs_in_{second_infile}_not_in_{first_infile}.g6\n"
        "\tThese pairs should contain the same number of graphs\n"
        "- planarity_results/\n"
        "\t- For each graph algorithm command specifier, there will be "
        "a subdirectory containing one subdirectory for each edge-count "
        "(0 to (N * (N - 1)) / 2), which will contain files:\n"
        "\tn{order}.m{num_edges}.{command}.out.txt\n"
        "\tn{order}.m{num_edges}.canonical.{command}.out.txt\n"
        "\tn{order}.m{num_edges}.makeg.{command}.out.txt\n"
        "\tn{order}.m{num_edges}.makeg.canonical.{command}.out.txt\n"
        "- g6_diff_finder_logs/\n"
        "\t- Will contain logs for each of the following comparisons:\n"
        "\tG6DiffFinder.n{order}.geng_vs_geng-canonical.log\n"
        "\tG6DiffFinder.n{order}.geng_vs_makeg.log\n"
        "\tG6DiffFinder.n{order}.geng_vs_makeg-canonical.log\n"
        "\tG6DiffFinder.n{order}.geng-canonical_vs_makeg-canonical.log\n"
        "\tG6DiffFinder.n{order}.makeg_vs_makeg-canonical.log\n",
    )
    parser.add_argument(
        "-g",
        "--gengpath",
        type=Path,
        required=True,
        help="Path to nauty geng executable",
        metavar="PATH_TO_GENG_EXECUTABLE",
    )
    parser.add_argument(
        "-n",
        "--orders",
        type=parse_range,
        required=True,
        help="Order(s) of graphs for which you wish to generate .g6 files",
        metavar="X[,Y]",
    )
    parser.add_argument(
        "-p",
        "--planaritypath",
        type=Path,
        required=False,
        help="Path to planarity executable",
        metavar="PATH_TO_PLANARITY_EXECUTABLE",
    )
    parser.add_argument(
        "-b",
        "--planaritybackuppath",
        type=Path,
        required=False,
        help="Path to planarity-backup executable (optional; not public!)",
        metavar="PATH_TO_PLANARITY_BACKUP_EXECUTABLE",
    )
    parser.add_argument(
        "-o",
        "--outputdir",
        type=Path,
        default=None,
        metavar="OUTPUT_DIR_PATH",
        help="Parent directory under which subdirectories will be created "
        "for output results. If none provided, defaults to:\n"
        "\tTestSupport/results/g6_generation_and_comparison_driver/",
    )

    args = parser.parse_args()

    g6_generation_and_comparison_driver = G6GenerationAndComparisonDriver(
        geng_path=args.gengpath,
        orders=args.orders,
        planarity_path=args.planaritypath,
        planarity_backup_path=args.planaritybackuppath,
        output_parent_dir=args.outputdir,
    )

    g6_generation_and_comparison_driver.generate_g6_files()
    g6_generation_and_comparison_driver.run_planarity()
    g6_generation_and_comparison_driver.reorganize_files()
    g6_generation_and_comparison_driver.find_planarity_discrepancies()
    g6_generation_and_comparison_driver.get_planarity_discrepancy_g6_diffs()
