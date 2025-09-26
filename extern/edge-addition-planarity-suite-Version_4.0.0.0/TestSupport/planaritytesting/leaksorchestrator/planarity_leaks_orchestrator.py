"""Run leaks on MacOS to test for memory issues, e.g. leaks or overruns"""

#!/usr/bin/env python

__all__ = []

import argparse
from datetime import datetime
import configparser
import multiprocessing
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
from typing import Optional

# This is required to import from modules in the parent package
sys.path.append(str(Path(sys.argv[0]).resolve().parent.parent))

# pylint: disable=wrong-import-position

from planaritytesting_utils import (
    PLANARITY_ALGORITHM_SPECIFIERS,
    GRAPH_FORMAT_SPECIFIERS,
    determine_input_filetype,
    is_path_to_executable,
)

# pylint: enable=wrong-import-position


class PlanarityLeaksOrchestratorError(Exception):
    """
    Custom exception for representing errors that arise when performing memory
    checks on a planarity executable.
    """

    def __init__(self, message):
        super().__init__(message)
        self.message = message


class PlanarityLeaksOrchestrator:
    """Driver for planarity memory leak analysis on MacOS using leaks util"""

    def __init__(
        self,
        planarity_path: Optional[Path] = None,
        output_dir: Optional[Path] = None,
    ) -> None:
        """Initialize PlanarityLeaksOrchestrator instance

        Args:
            planarity_path: Path to planarity executable
            output_dir: Directory under which subdirectories will be created
                for each of the jobs specified in planarity_leaks_config.ini
        Raises:
            argparse.ArgumentTypeError: If the planarity_path doesn't
                correspond to an executable, if the output_dir corresponds to
                a file,
            OSError: If run on any platform other than MacOS, or if the leaks
                utility is not found
        """
        if platform.system() != "Darwin":
            raise OSError("This utility is only for use on MacOS.")

        if not shutil.which("leaks"):
            raise OSError(
                "leaks is not installed; please install leaks and ensure your "
                "path variable contains the directory to which it is "
                "installed."
            )

        planarity_project_root = (
            Path(sys.argv[0]).resolve().parent.parent.parent.parent
        )
        if not planarity_path:
            planarity_path = Path.joinpath(
                planarity_project_root, "Release", "planarity"
            )
        else:
            planarity_path = planarity_path.resolve()

        if not is_path_to_executable(planarity_path):
            raise argparse.ArgumentTypeError(
                f"'Path for planarity executable {planarity_path}' doesn't "
                "correspond to an executable."
            )

        self.curr_timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

        if not output_dir:
            output_dir = Path.joinpath(
                planarity_project_root,
                "TestSupport",
                "results",
                "planarity_leaks_orchestrator",
            )

        if output_dir.is_file():
            raise argparse.ArgumentTypeError(
                f"Path '{output_dir}' corresponds to a file, and can't be "
                "used as the output directory."
            )

        output_dir = Path.joinpath(output_dir, f"{self.curr_timestamp}")

        if Path.is_dir(output_dir):
            shutil.rmtree(output_dir)

        Path.mkdir(output_dir, parents=True, exist_ok=True)

        self.planarity_path = planarity_path
        self.output_dir = output_dir

    @staticmethod
    def setup_leaks_environment_variables(
        perform_full_analysis: bool = False,
    ) -> dict[str, str]:
        """Sets up environment variables to configure granularity of leaks runs

        Args:
            perform_full_analysis: bool to indicate whether additional
                environment variables should be set for the leaks run; if True,
                sets the following additional environment variables:

                MallocStackLoggingNoCompact - This option is similar to
                    MallocStackLogging but makes sure that all allocations are
                    logged, no matter how small or how short lived the buffer
                    may be.
                MallocScribble - If set, free sets each byte of every released
                    block to the value 0x55.
                MallocPreScribble - If set, malloc sets each byte of a newly
                    allocated block to the value 0xAA. This increases the
                    likelihood that a program making assumptions about freshly
                    allocated memory fails.
                MallocGuardEdges - If set, malloc adds guard pages before and
                    after large allocations.
                MallocCheckHeapStart = <s> - If set, specifies the number of
                    allocations <s> to wait before begining periodic heap
                    checks every <n> as specified by MallocCheckHeapEach. If
                    MallocCheckHeapStart is set but MallocCheckHeapEach is not
                    specified, the default check repetition is 1000.
                MallocCheckHeapEach = <n> - If set, run a consistency check on
                    the heap every <n> operations.  MallocCheckHeapEach is only
                    meaningful if MallocCheckHeapStart is also set.
        """
        leaks_environment_variables = os.environ.copy()
        leaks_environment_variables["MallocStackLogging"] = "1"
        if perform_full_analysis:
            leaks_environment_variables = dict(
                leaks_environment_variables,
                **{
                    "MallocStackLoggingNoCompact": "1",
                    "MallocScribble": "1",
                    "MallocPreScribble": "1",
                    "MallocGuardEdges": "1",
                    "MallocCheckHeapStart": "1",
                    "MallocCheckHeapEach": "6",
                    # "MallocErrorAbort": "1",
                    # "MallocCheckHeapAbort": "1",
                },
            )
        return leaks_environment_variables

    def _run_leaks(
        self,
        command_args: list[str],
        leaks_outfile_basename: Path,
        leaks_env: dict,
        cwd: Optional[Path] = None,
    ) -> None:
        """Run leaks utility for given args

        Args:
            command_args: List of strings comprised of executable name and
                command line arguments
            leaks_outfile_name: name of file to which you wish to write leaks
                output
            leaks_env: dictionary containing all relevant environment variables
                for leaks execution (e.g. os.environ() + MallocStackLogging=1)
            cwd: If not None, indicates to subprocess.run() that we wish to
                change the working directory to cwd before executing the child
        """
        outfile_path = leaks_outfile_basename.with_suffix(
            leaks_outfile_basename.suffix + ".log"
        )
        if cwd:
            outfile_path = Path.joinpath(cwd, outfile_path)

        full_args = [
            # Use script utility to wrap leaks because there is some issue
            # capturing *all* terminal output when you invoke leaks directly
            # and redirect stdout and stderr to file
            "script",
            f"{outfile_path}",
            "leaks",
            "-atExit",
            "--",
        ] + command_args
        subprocess.run(
            full_args,
            # Must default to None for stdout and stdin so that script utility
            # will capture *all* leaks output from running planarity; see #59
            # for investigation
            env=leaks_env,
            check=False,
            cwd=cwd,
        )

    @staticmethod
    def _valid_commands_to_run(commands_to_run: tuple[str, ...]) -> bool:
        """Ensures all algorithm command specifiers in tuple are valid

        Args:
            commands_to_run: tuple of strings which we wish to ensure are valid
                algorithm command specifiers

        Returns:
            bool indicating whether or not the commands_to_run are valid
        """
        return set(commands_to_run) <= set(PLANARITY_ALGORITHM_SPECIFIERS())

    @staticmethod
    def _valid_graph_output_formats(
        output_formats_to_run: tuple[str, ...]
    ) -> bool:
        """Ensures all graph output format specifiers in tuple are valid

        Args:
            output_formats_to_run: tuple of strings which we wish to ensure are
                valid graph output format specifiers

        Returns:
            bool indicating whether or not the output_formats_to_run are valid
        """
        return set(output_formats_to_run) <= set(GRAPH_FORMAT_SPECIFIERS())

    def test_random_graphs(
        self,
        num_graphs_to_generate: int,
        order: int,
        commands_to_run: tuple[str, ...] = (),
        perform_full_analysis: bool = False,
    ) -> None:
        """Check RandomGraphs() for memory issues
        'planarity -r [-q] C K N': Random graphs

        Args:
            num_graphs_to_generate: Number of graphs to randomly generate
            order: Number of vertices in each randomly generated graph
            commands_to_run: Tuple containing algorithm command specifiers
                which we wish to use to test random graphs.
            perform_full_analysis: bool to determine what environment variables
                leaks_env will hold (to be sent to subprocess.run())

        Raises:
            PlanarityLeaksOrchestratorError: If commands_to_run contains [an]
                invalid algorithm command specifier(s)
        """
        if not commands_to_run:
            commands_to_run = PLANARITY_ALGORITHM_SPECIFIERS()
        elif not self._valid_commands_to_run(commands_to_run):
            raise PlanarityLeaksOrchestratorError(
                "commands_to_run param contains invalid command specifiers: "
                f"'{commands_to_run}'."
            )

        leaks_env = self.setup_leaks_environment_variables(
            perform_full_analysis
        )

        test_random_graphs_args = [
            (command, num_graphs_to_generate, order, leaks_env)
            for command in commands_to_run
        ]
        with multiprocessing.Pool(
            processes=multiprocessing.cpu_count()
        ) as pool:
            _ = pool.starmap_async(
                self._test_random_graphs, test_random_graphs_args
            )
            pool.close()
            pool.join()

    def _test_random_graphs(
        self,
        command: str,
        num_graphs_to_generate: int,
        order: int,
        leaks_env: dict,
    ) -> None:
        """Runs RandomGraphs() for a given algorithm command specifier

        Args:
            command: algorithm command specifier
            num_graphs_to_generate: Number of graphs to randomly generate
            order: Number of vertices in each randomly generated graph
            leaks_env: dictionary containing all relevant environment variables
                for leaks execution (e.g. os.environ() + MallocStackLogging=1)
        """
        random_graphs_args = [
            f"{self.planarity_path}",
            "-r",
            f"-{command}",
            f"{num_graphs_to_generate}",
            f"{order}",
        ]
        random_graphs_outfile_parent_dir = Path.joinpath(
            self.output_dir,
            "RandomGraphs",
        )
        Path.mkdir(
            random_graphs_outfile_parent_dir, parents=True, exist_ok=True
        )
        random_graphs_leaks_outfile_basename = Path.joinpath(
            random_graphs_outfile_parent_dir,
            f"RandomGraphs.{command}.{num_graphs_to_generate}.{order}",
        )
        self._run_leaks(
            random_graphs_args, random_graphs_leaks_outfile_basename, leaks_env
        )

    def test_random_max_planar_graph_generator(
        self,
        order: int,
        perform_full_analysis: bool = False,
    ) -> None:
        """Check callRandomMaxPlanarGraph for memory issues

        'planarity -rm [-q] N O [O2]': Maximal planar random graph

        Args:
            order: Desired number of vertices for randomly generated maximal
                planar graph
            perform_full_analysis: bool to determine what environment variables
                leaks_env will hold (to be sent to subprocess.run())
        """
        leaks_env = (
            PlanarityLeaksOrchestrator.setup_leaks_environment_variables(
                perform_full_analysis
            )
        )
        max_planar_graph_generator_outfile_parent_dir = Path.joinpath(
            self.output_dir,
            "RandomMaxPlanarGraphGenerator",
        )
        Path.mkdir(
            max_planar_graph_generator_outfile_parent_dir,
            parents=True,
            exist_ok=True,
        )
        leaks_outfile_basename = Path.joinpath(
            max_planar_graph_generator_outfile_parent_dir,
            f"RandomMaxPlanarGraphGenerator.{order}",
        )
        adjlist_before_processing = leaks_outfile_basename.with_suffix(
            leaks_outfile_basename.suffix + ".AdjList.BEFORE.out.txt"
        )
        adjlist_after_processing = leaks_outfile_basename.with_suffix(
            leaks_outfile_basename.suffix + ".AdjList.AFTER.out.txt"
        )

        random_max_planar_graph_args = [
            f"{self.planarity_path}",
            "-rm",
            # planarityRandomGraphs.c line 432 - we don't want to
            # saveEdgeListFormat, since we're only testing what's available
            # from command line
            "-q",
            f"{order}",
            f"{adjlist_after_processing}",
            f"{adjlist_before_processing}",
        ]
        self._run_leaks(
            random_max_planar_graph_args,
            leaks_outfile_basename,
            leaks_env,
        )

    def test_random_nonplanar_graph_generator(
        self,
        order: int,
        perform_full_analysis: bool = False,
    ) -> None:
        """Check callRandomNonplanarGraph for memory issues

        'planarity -rn [-q] N O [O2]': Non-planar random graph (maximal planar
            plus edge)

        Args:
            order: Desired number of vertices for randomly generated nonplanar
                graph
            perform_full_analysis: bool to determine what environment variables
                leaks_env will hold (to be sent to subprocess.run())
        """
        leaks_env = (
            PlanarityLeaksOrchestrator.setup_leaks_environment_variables(
                perform_full_analysis
            )
        )
        random_nonplanar_graph_generator_outfile_parent_dir = Path.joinpath(
            self.output_dir,
            "RandomNonplanarGraphGenerator",
        )
        Path.mkdir(
            random_nonplanar_graph_generator_outfile_parent_dir,
            parents=True,
            exist_ok=True,
        )
        leaks_outfile_basename = Path.joinpath(
            random_nonplanar_graph_generator_outfile_parent_dir,
            f"RandomNonplanarGraphGenerator.{order}",
        )
        adjlist_before_processing = leaks_outfile_basename.with_suffix(
            leaks_outfile_basename.suffix + ".AdjList.BEFORE.out.txt"
        )
        adjlist_after_processing = leaks_outfile_basename.with_suffix(
            leaks_outfile_basename.suffix + ".AdjList.AFTER.out.txt"
        )

        random_nonplanar_graph_generator_args = [
            f"{self.planarity_path}",
            "-rn",
            "-q",
            f"{order}",
            f"{adjlist_after_processing}",
            f"{adjlist_before_processing}",
        ]
        self._run_leaks(
            random_nonplanar_graph_generator_args,
            leaks_outfile_basename,
            leaks_env,
        )

    def test_specific_graph(
        self,
        infile_path: Path,
        commands_to_run: tuple[str, ...] = (),
        perform_full_analysis: bool = False,
    ) -> None:
        """Check SpecificGraph() for memory issues for given commands

        Args:
            infile_path: Path to .g6 infile containing single graph on which we
                wish to run the algorithms specified in commands_to_run
            commands_to_run: Tuple containing algorithm command specifiers
                which we wish to use to test specific graph.
            perform_full_analysis: bool to determine what environment variables
                leaks_env will hold (to be sent to subprocess.run())

        Raises:
            PlanarityLeaksOrchestratorError: If input_file is not a valid .g6
                file, or if commands_to_run contains at least one invalid
                algorithm command specifier.
        """
        try:
            file_type = determine_input_filetype(infile_path)
        except ValueError as input_filetype_error:
            raise PlanarityLeaksOrchestratorError(
                "Failed to determine input filetype of " f"'{infile_path}'."
            ) from input_filetype_error

        if file_type != "G6":
            raise PlanarityLeaksOrchestratorError(
                f"Determined '{infile_path}' has filetype '{file_type}', "
                "which is not supported; please supply a .g6 file."
            )
        if not commands_to_run:
            commands_to_run = PLANARITY_ALGORITHM_SPECIFIERS()
        elif not self._valid_commands_to_run(commands_to_run):
            raise PlanarityLeaksOrchestratorError(
                "commands_to_run param contains invalid contains at least one "
                f"invalid algorithm command specifier: '{commands_to_run}'."
            )

        specific_graph_outfile_parent_dir = Path.joinpath(
            self.output_dir,
            "SpecificGraph",
        )
        Path.mkdir(
            specific_graph_outfile_parent_dir,
            parents=True,
            exist_ok=True,
        )

        infile_copy_path = Path.joinpath(
            specific_graph_outfile_parent_dir, infile_path.name
        ).resolve()

        shutil.copyfile(infile_path, infile_copy_path)

        infile_path = infile_copy_path

        leaks_env = (
            PlanarityLeaksOrchestrator.setup_leaks_environment_variables(
                perform_full_analysis
            )
        )

        test_specific_graph_args = [
            (
                specific_graph_outfile_parent_dir,
                infile_path,
                command,
                leaks_env,
            )
            for command in commands_to_run
        ]
        with multiprocessing.Pool(
            processes=multiprocessing.cpu_count()
        ) as pool:
            _ = pool.starmap_async(
                self._test_specific_graph, test_specific_graph_args
            )
            pool.close()
            pool.join()

    def _test_specific_graph(
        self,
        specific_graph_outfile_parent_dir: Path,
        infile_path: Path,
        command: str,
        leaks_env: dict,
    ) -> None:
        """Check SpecificGraph() for memory issues for given command

        'planarity -s [-q] C I O [O2]': Specific graph

        Args:
            specific_graph_outfile_parent_dir: Directory to which results for
                testing SpecificGraph() will be output
            infile_path: Path to .g6 infile containing single graph on which we
                wish to run the algorithm specified by command
            command: Algorithm command specifier to indicate what
                algorithm you wish to run SpecificGraph() with
            leaks_env: dictionary containing all relevant environment variables
                for leaks execution (e.g. os.environ() + MallocStackLogging=1)
        """
        specific_graph_leaks_outfile_basename = Path(
            f"SpecificGraph.{infile_path.with_suffix('').name}.{command}",
        )
        specific_graph_primary_output = (
            specific_graph_leaks_outfile_basename.with_suffix(
                specific_graph_leaks_outfile_basename.suffix
                + ".PRIMARY.out.txt"
            )
        )
        specific_graph_secondary_output = (
            specific_graph_leaks_outfile_basename.with_suffix(
                specific_graph_leaks_outfile_basename.suffix
                + ".SECONDARY.out.txt"
            )
        )
        specific_graph_args = [
            f"{self.planarity_path}",
            "-s",
            f"-{command}",
            f"{infile_path.name}",
            f"{specific_graph_primary_output}",
            f"{specific_graph_secondary_output}",
        ]
        self._run_leaks(
            command_args=specific_graph_args,
            leaks_outfile_basename=specific_graph_leaks_outfile_basename,
            leaks_env=leaks_env,
            cwd=specific_graph_outfile_parent_dir,
        )

    def test_transform_graph(
        self,
        infile_path: Path,
        output_formats_to_test: tuple[str, ...] = (),
        perform_full_analysis: bool = False,
    ) -> None:
        """Check Graph Transformation for memory issues for given formats

        Args:
            infile_path: Path to graph input file containing single graph to be
                transformed to each of the desired output_formats_to_test
            output_formats_to_test: Tuple containing graph output formats to
                to test.
            perform_full_analysis: bool to determine what environment variables
                leaks_env will hold (to be sent to subprocess.run())

        Raises:
            PlanarityLeaksOrchestratorError: If input_file is not a valid graph
                input file, or if output_formats_to_test contains at least one
                invalid graph output format specifier.
        """
        try:
            _ = determine_input_filetype(infile_path)
        except ValueError as input_filetype_error:
            raise PlanarityLeaksOrchestratorError(
                "Failed to determine input filetype of " f"'{infile_path}'."
            ) from input_filetype_error

        if not output_formats_to_test:
            output_formats_to_test = tuple(GRAPH_FORMAT_SPECIFIERS().keys())
        elif not self._valid_graph_output_formats(output_formats_to_test):
            raise PlanarityLeaksOrchestratorError(
                "output_formats_to_test param contains at least one invalid "
                f"graph output format specifier: '{output_formats_to_test}'."
            )

        transform_graph_outfile_parent_dir = Path.joinpath(
            self.output_dir,
            "TransformGraph",
        )
        Path.mkdir(
            transform_graph_outfile_parent_dir,
            parents=True,
            exist_ok=True,
        )

        infile_copy_path = Path.joinpath(
            transform_graph_outfile_parent_dir, infile_path.name
        ).resolve()

        shutil.copyfile(infile_path, infile_copy_path)

        infile_path = infile_copy_path

        leaks_env = self.setup_leaks_environment_variables(
            perform_full_analysis
        )

        test_transform_graph_args = [
            (
                transform_graph_outfile_parent_dir,
                infile_path,
                output_format,
                leaks_env,
            )
            for output_format in output_formats_to_test
        ]
        with multiprocessing.Pool(
            processes=multiprocessing.cpu_count()
        ) as pool:
            _ = pool.starmap_async(
                self._test_transform_graph, test_transform_graph_args
            )
            pool.close()
            pool.join()

    def _test_transform_graph(
        self,
        transform_graph_outfile_parent_dir: Path,
        infile_path: Path,
        output_format: str,
        leaks_env: dict,
    ) -> None:
        """Check Graph Transformation for memory issues for given output format

        'planarity -t [-q] -t(gam) I O ': Transform graph

        Args:
            transform_graph_outfile_parent_dir: Directory to which results for
                testing graph transformation to desired format will be output
            infile_path: Path to graph input file containing single graph to be
                transformed to the desired output_format
            output_format: Graph output format specifier to indicate the
                target graph output format for which you wish to test graph
                transform
            leaks_env: dictionary containing all relevant environment variables
                for leaks execution (e.g. os.environ() + MallocStackLogging=1)
        """
        graph_format_specifiers = GRAPH_FORMAT_SPECIFIERS()
        transform_graph_leaks_outfile_basename = Path(
            f"{infile_path.with_suffix('').name}"
            f".{graph_format_specifiers[output_format]}",
        )
        transformed_graph_output = (
            transform_graph_leaks_outfile_basename.with_suffix(
                transform_graph_leaks_outfile_basename.suffix + ".out.txt"
            )
        )
        transform_graph_leaks_outfile_basename = Path(
            "TransformGraph" + f".{transform_graph_leaks_outfile_basename}"
        )
        specific_graph_args = [
            f"{self.planarity_path}",
            "-t",
            f"-t{output_format}",
            f"{infile_path.name}",
            f"{transformed_graph_output}",
        ]
        self._run_leaks(
            command_args=specific_graph_args,
            leaks_outfile_basename=transform_graph_leaks_outfile_basename,
            leaks_env=leaks_env,
            cwd=transform_graph_outfile_parent_dir,
        )

    def test_test_all_graphs(
        self,
        infile_path: Path,
        commands_to_run: tuple[str, ...] = (),
        perform_full_analysis: bool = False,
    ) -> None:
        """Check Test All Graphs for memory issues for given commands

        Args:
            infile_path: Path to .g6 infile containing at least one graph on
                which we wish to run the algorithms specified in
                commands_to_run
            commands_to_run: Tuple containing algorithm command specifiers
                which we wish to use to test test all graphs.
            perform_full_analysis: bool to determine what environment variables
                leaks_env will hold (to be sent to subprocess.run())

        Raises:
            PlanarityLeaksOrchestratorError: If input_file is not a valid .g6
                file, or if commands_to_run contains at least one invalid
                algorithm command specifier.
        """
        try:
            file_type = determine_input_filetype(infile_path)
        except ValueError as input_filetype_error:
            raise PlanarityLeaksOrchestratorError(
                "Failed to determine input filetype of " f"'{infile_path}'."
            ) from input_filetype_error

        if file_type != "G6":
            raise PlanarityLeaksOrchestratorError(
                f"Determined '{infile_path}' has filetype '{file_type}', "
                "which is not supported; please supply a .g6 file."
            )
        if not commands_to_run:
            commands_to_run = PLANARITY_ALGORITHM_SPECIFIERS()
        elif not self._valid_commands_to_run(commands_to_run):
            raise PlanarityLeaksOrchestratorError(
                "commands_to_run param contains invalid contains at least one "
                f"invalid algorithm command specifier: '{commands_to_run}'."
            )

        test_all_graphs_outfile_parent_dir = Path.joinpath(
            self.output_dir,
            "TestAllGraphs",
        )
        Path.mkdir(
            test_all_graphs_outfile_parent_dir,
            parents=True,
            exist_ok=True,
        )

        infile_copy_path = Path.joinpath(
            test_all_graphs_outfile_parent_dir, infile_path.name
        ).resolve()

        shutil.copyfile(infile_path, infile_copy_path)

        infile_path = infile_copy_path

        leaks_env = (
            PlanarityLeaksOrchestrator.setup_leaks_environment_variables(
                perform_full_analysis
            )
        )

        test_specific_graph_args = [
            (
                test_all_graphs_outfile_parent_dir,
                infile_path,
                command,
                leaks_env,
            )
            for command in commands_to_run
        ]
        with multiprocessing.Pool(
            processes=multiprocessing.cpu_count()
        ) as pool:
            _ = pool.starmap_async(
                self._test_test_all_graphs, test_specific_graph_args
            )
            pool.close()
            pool.join()

    def _test_test_all_graphs(
        self,
        test_all_graphs_outfile_parent_dir: Path,
        infile_path: Path,
        command: str,
        leaks_env: dict,
    ) -> None:
        """Check Test All Graphs for memory issues for given command

        'planarity -t [-q] C I O': Test All Graphs

        Args:
            test_all_graphs_outfile_parent_dir: Directory to which results for
                testing Test All Graphs functionality will be output
            infile_path: Path to .g6 infile containing single graph on which we
                wish to run the algorithm specified by command
            command: Algorithm command specifier to indicate what
                algorithm you wish to run Test All Graphs with
            leaks_env: dictionary containing all relevant environment variables
                for leaks execution (e.g. os.environ() + MallocStackLogging=1)
        """
        test_all_graphs_leaks_outfile_basename = Path(
            f"TestAllGraphs.{infile_path.with_suffix('').name}.{command}",
        )
        test_all_graphs_output = (
            test_all_graphs_leaks_outfile_basename.with_suffix(
                test_all_graphs_leaks_outfile_basename.suffix + ".out.txt"
            )
        )

        test_all_graphs_args = [
            f"{self.planarity_path}",
            "-t",
            f"-{command}",
            f"{infile_path.name}",
            f"{test_all_graphs_output}",
        ]
        self._run_leaks(
            command_args=test_all_graphs_args,
            leaks_outfile_basename=test_all_graphs_leaks_outfile_basename,
            leaks_env=leaks_env,
            cwd=test_all_graphs_outfile_parent_dir,
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,
        usage="python %(prog)s [options] > /dev/null 2>&1",
        description="Planarity leaks analysis\n"
        "Automates runs of leaks on MacOS to identify memory issues for the "
        "following:\n"
        "- Random graphs with one small graph,\n"
        "- Random max planar graph generator,\n"
        "- Random nonplanar graph generator,\n"
        "- Specific Graph (will only run on first graph in input file)\n"
        "- Graph Transformation tool\n"
        "- Test All Graphs\n"
        "\n\tN.B. One must run the planarity_leaks_config_manager.py script, "
        "and update default configuration values. For example, you must "
        "provide an infile_name for the SpecificGraph job, and any jobs you "
        "wish to run must have 'enabled' set to True.\n\n"
        "If an output directory is specified, a subdirectory will be created "
        "to contain the results:\n"
        "\t{output_dir}/{test_timestamp}/\n"
        "If an output directory is not specified, defaults to:\n"
        "\tTestSupport/results/planarity_leaks_orchestrator/"
        "{test_timestamp}/\n",
    )
    parser.add_argument(
        "-p",
        "--planaritypath",
        type=Path,
        default=None,
        help="Must be a path to a planarity executable that was compiled "
        "with -g; defaults to:\n"
        "\t{planarity_project_root}/Release/planarity",
        metavar="PATH_TO_PLANARITY_EXECUTABLE",
    )
    parser.add_argument(
        "-c",
        "--configfile",
        type=Path,
        default=None,
        metavar="PATH_TO_CONFIG_FILE",
        help="Optional path to planarity leaks orchestrator config file;"
        "defaults to:\n"
        "\t{planarity_project_root}/TestSupport/planaritytesting/"
        "leaksorchestrator/planarity_leaks_config.ini",
    )
    parser.add_argument(
        "-o",
        "--outputdir",
        type=Path,
        default=None,
        metavar="DIR_FOR_RESULTS",
        help="If no output directory provided, defaults to\n"
        "\t{planarity_project_root}/TestSupport/results/"
        "planarity_leaks_orchestrator/",
    )

    args = parser.parse_args()

    leaks_orchestrator_root = Path(sys.argv[0]).resolve().parent
    config_file = args.configfile
    if not config_file:
        config_file = Path.joinpath(
            leaks_orchestrator_root,
            "planarity_leaks_config.ini",
        )
    config = configparser.ConfigParser(
        converters={
            "list": lambda x: (
                [i.strip() for i in x.split(",") if i] if len(x) > 0 else []
            )
        }
    )
    config.read(config_file)
    if not config.sections():
        raise argparse.ArgumentTypeError(
            f"'{config_file}' doesn't correspond to a planarity leaks config "
            "file. Please run planarity leaks config manager to generate "
            "default config and modify values as necessary for the jobs you "
            "wish to run."
        )

    planarity_leaks_orchestrator = PlanarityLeaksOrchestrator(
        planarity_path=args.planaritypath,
        output_dir=args.outputdir,
    )
    for section in config:
        if not config[section].getboolean("enabled"):
            continue

        if section == "RandomGraphs":
            num_graphs_from_config = int(config[section]["num_graphs"])
            order_from_config = int(config[section]["order"])
            commands_to_run_from_config = config.getlist(  # type: ignore
                section, "commands_to_run"
            )
            perform_full_analysis_from_config = config[section].getboolean(
                "perform_full_analysis"
            )

            planarity_leaks_orchestrator.test_random_graphs(
                num_graphs_to_generate=num_graphs_from_config,
                order=order_from_config,
                commands_to_run=commands_to_run_from_config,
                perform_full_analysis=perform_full_analysis_from_config,
            )
        elif section == "RandomMaxPlanarGraphGenerator":
            order_from_config = int(config[section]["order"])
            perform_full_analysis_from_config = config[section].getboolean(
                "perform_full_analysis"
            )
            planarity_leaks_orchestrator.test_random_max_planar_graph_generator(
                order=order_from_config,
                perform_full_analysis=perform_full_analysis_from_config,
            )
        elif section == "RandomNonplanarGraphGenerator":
            order_from_config = int(config[section]["order"])
            perform_full_analysis_from_config = config[section].getboolean(
                "perform_full_analysis"
            )
            planarity_leaks_orchestrator.test_random_nonplanar_graph_generator(
                order=order_from_config,
                perform_full_analysis=perform_full_analysis_from_config,
            )
        elif section == "SpecificGraph":
            infile_path_from_config = Path(config[section]["infile_path"])
            perform_full_analysis_from_config = config[section].getboolean(
                "perform_full_analysis"
            )
            commands_to_run_from_config = config.getlist(  # type: ignore
                section, "commands_to_run"
            )
            planarity_leaks_orchestrator.test_specific_graph(
                infile_path=infile_path_from_config,
                commands_to_run=commands_to_run_from_config,
                perform_full_analysis=perform_full_analysis_from_config,
            )
        elif section == "TransformGraph":
            infile_path_from_config = Path(config[section]["infile_path"])
            perform_full_analysis_from_config = config[section].getboolean(
                "perform_full_analysis"
            )
            output_formats_to_test_from_config = config.getlist(  # type: ignore
                section, "output_formats_to_test"
            )
            planarity_leaks_orchestrator.test_transform_graph(
                infile_path=infile_path_from_config,
                output_formats_to_test=output_formats_to_test_from_config,
                perform_full_analysis=perform_full_analysis_from_config,
            )
        elif section == "TestAllGraphs":
            infile_path_from_config = Path(config[section]["infile_path"])
            perform_full_analysis_from_config = config[section].getboolean(
                "perform_full_analysis"
            )
            commands_to_run_from_config = config.getlist(  # type: ignore
                section, "commands_to_run"
            )
            planarity_leaks_orchestrator.test_test_all_graphs(
                infile_path=infile_path_from_config,
                commands_to_run=commands_to_run_from_config,
                perform_full_analysis=perform_full_analysis_from_config,
            )
