"""Tools to help investigate K_{3, 3} search graph algorithm extension bug"""

__all__ = [
    "planaritytesting_utils",
    "graph_generation_orchestrator",
    "planarity_testAllGraphs_orchestrator",
    "g6_diff_finder",
    "planarity_testAllGraphs_output_parsing",
    "graph",
    "edge_deletion_analysis",
    "test_table_generator",
]

import logging

from . import planaritytesting_utils
from . import graph_generation_orchestrator
from . import planarity_testAllGraphs_orchestrator
from . import g6_diff_finder
from . import planarity_testAllGraphs_output_parsing
from . import graph
from . import edge_deletion_analysis
from . import test_table_generator

# This ensures that no logging occurs by default unless a logger has been
# properly configured on a per-module basis
logging.getLogger(__name__).addHandler(logging.NullHandler())
