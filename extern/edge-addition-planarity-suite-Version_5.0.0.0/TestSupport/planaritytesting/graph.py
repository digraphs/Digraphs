"""Pure Python module containing classes to represent graphs as adjacency lists

Classes:
    GraphError
    Graph
"""

__all__ = ["Graph", "GraphError"]

from copy import deepcopy
from typing import Optional


class GraphError(BaseException):
    """Signals issues encountered while managing a Graph object"""

    def __init__(self, message):
        super().__init__(message)
        self.message = message


class Graph:
    """A simple graph datastructure containing the order graph adjacency list"""

    def __init__(
        self,
        order: int = 0,
        graph_adj_list_repr: Optional[list[list[int]]] = None,
    ) -> None:
        """Constructor for Graph class

        Had to do some fancy footwork to support deepcopy() machinery: if you
        try to create an instance with only the graph_adj_list_repr and don't
        supply the order, the order is inferred from the number of elements of
        the outer list, and then the graph adjacency-list representation is
        validated. If you supply both the order and adjacency list, then we
        ensure the order and graph adjacency list representation make sense.
        If only the graph order is supplied, then a list of lists is
        initialized, which will be subsequently populated by repeated calls to
        self.add_edge().

        Args:
            order: The order of the graph
            graph_adj_list_repr: A list of lists of integers comprising the
                graph's adjacency list representation
        Raises:
            GraphError: If supplied order and graph_adj_list_repr do not agree,
                re-raises from Graph._validate_adj_list(), or if graph order
                is not in closed interval [2, 12].
        """
        if order == 0:
            if graph_adj_list_repr:
                order_implied_by_adj_list = len(graph_adj_list_repr)
                try:
                    Graph._validate_adj_list(
                        order_implied_by_adj_list, graph_adj_list_repr
                    )
                except GraphError as e:
                    raise GraphError(
                        "Unable to initialize graph from given adjacency list."
                    ) from e

                self.order = order_implied_by_adj_list
                self.graph_adj_list_repr = graph_adj_list_repr
        else:
            if order < 2 or order > 12:
                raise GraphError(
                    f"Graph order '{order}' is not in closed interval [2, 12]."
                )
            if graph_adj_list_repr:
                try:
                    Graph._validate_adj_list(order, graph_adj_list_repr)
                except GraphError as e:
                    raise GraphError(
                        "Unable to initialize Graph with given order and "
                        "adjacency list"
                    ) from e

                self.order = order
                self.graph_adj_list_repr = graph_adj_list_repr
            else:
                self.graph_adj_list_repr = [[] for _ in range(order)]
                self.order = order

    @staticmethod
    def _validate_adj_list(
        order: int, graph_adj_list_repr: list[list[int]]
    ) -> None:
        """Static method to ensure constructor arguments make sense

        Args:
            order: The order of the graph
            graph_adj_list_repr: A list of lists of integers comprising the
                graph's adjacency list representation

        Raises:
            GraphError: If the number of vertices in the adjacency list doesn't
                correspond to the given graph order, if the adjacency list
                is not a list of lists of integers, if any of the vertex labels
                in the list of lists of integers are outside the expected
                range, or if there are duplicates within a vertex's adjacency
                list.
        """
        if len(graph_adj_list_repr) != order:
            raise GraphError(
                "Number of vertices in adjacency list, "
                f"{len(graph_adj_list_repr)}, doesn't correspond to "
                f"desired graph order {order}."
            )
        acceptable_vertex_labels = range(order)
        u = -1
        for adj_list in graph_adj_list_repr:
            u += 1
            adj_list_index = -1
            neighbours_seen = set()
            for v in adj_list:
                adj_list_index += 1
                if not isinstance(v, int):
                    raise GraphError(
                        "Adjacency list representation must be a list of "
                        f"lists of integers; list for vertex {u} contains "
                        f"{v}, which is not an integer."
                    )

                if v == -1:
                    if len(graph_adj_list_repr[adj_list_index + 1]) > 0:
                        raise GraphError(
                            f"Adjacency list for vertex {u} is malformed: "
                            "there must be no elements after -1, since this "
                            "is used to terminate the 0-based adjacency list."
                        )
                elif v not in acceptable_vertex_labels:
                    raise GraphError(
                        f"Adjacency list for vertex {u} includes vertex {v}, "
                        "which is outside the range "
                        f"[{acceptable_vertex_labels[0]}, "
                        f"{acceptable_vertex_labels[-1]}]."
                    )

                if v in neighbours_seen:
                    raise GraphError(
                        "Duplicate neighbours present in adjacency list for "
                        f"vertex {u}."
                    )
                neighbours_seen.add(v)

    def __copy__(self):
        raise NotImplementedError(
            "Shallow copy is not supported for Graph objects, since the "
            "adjacency list is a list of a mutable type, lists of integers."
        )

    def __deepcopy__(self, memo):
        """Deepcopy Graph object
        The Graph class has a mutable member, graph_adj_list_repr, which is a
        list of lists of integers. Therefore, it's necessary to implement
        deepcopy so that when we delete_edge() from a copy of a graph, it
        doesn't change the original graph's graph_adj_list_repr.
        """
        if id(self) in memo:
            return memo[id(self)]

        graph_deepcopy = Graph(
            self.order, deepcopy(self.graph_adj_list_repr, memo)
        )

        memo[id(self)] = graph_deepcopy

        return graph_deepcopy

    def __eq__(self, other) -> bool:
        """Graph equality

        Implementing the simplest form of equality from a representational
        standpoint.

        There are other definitions of equality of graphs that are relevant in
        other applications, but originally this was here to help debugging
        __deepcopy__: after creating a deepcopy of a graph, they were equal,
        but then after changing one of the adjacency lists, they were no longer
        equal.

        Returns:
            If you're comparing any other object to the Graph, if the orders of
            two graphs don't agree, if the number of elements in the outer list
            disagree (i.e. two different vertex sets), or if the corresponding
            adjacency lists disagree for any of the vertices, then return False
        """
        if (
            isinstance(other, Graph)
            and self.order == other.order
            and len(self.graph_adj_list_repr) == len(other.graph_adj_list_repr)
            and all(
                u_list == v_list
                for (u_list, v_list) in zip(
                    self.graph_adj_list_repr, other.graph_adj_list_repr
                )
            )
        ):
            return True
        return False

    def __str__(self) -> str:
        """Get Graph's string representation

        Returns:
            Returns str of graph's adjacency list representation that matches
            what's produced by _WriteAdjList() in edge-addition-planarity-suite
            e.g.
                N={order}
                0: X Y Z -1
                ...
        """
        adj_list_str = f"N={self.order}\n"
        u = -1
        for adj_list in self.graph_adj_list_repr:
            u += 1

            line = f"{u}: "
            for v in adj_list:
                line += f"{v} "
            line += "-1\n"

            adj_list_str += line
        return adj_list_str

    def _vertex_validation(self, u: int):
        """Ensure vertex has label in range for 0-based graphs

        Args:
            u: Vertex index

        Raises:
            GraphError: If endpoints are out of bounds for 0-based labelling
        """
        if u >= self.order or u < 0:
            raise GraphError(
                "Invalid vertex label; must be in closed interval "
                f"[0, {self.order - 1}]."
            )

    def add_arc(self, u: int, v: int):
        """Add arc to graph's adjacency list representation

        Args:
            u: Index of tail vertex of arc to add
            v: Index head vertex of arc to add
        Raises:
            GraphError: If arc endpoints are invalid
        """
        try:
            self._vertex_validation(u)
            self._vertex_validation(v)
        except GraphError as e:
            raise GraphError(f"Unable to add arc ({u}, {v}).") from e

        self.graph_adj_list_repr[u].append(v)

    def get_max_degree(self) -> int:
        """Infer max degree from graph adjacency list representation
        Returns:
            The length of the longest adjacency list in the graph adjacency
                list representation (i.e. the list of lists of integers)
        """
        return max(len(x) for x in self.graph_adj_list_repr)

    def get_vertex_degree_counts(self) -> dict[int, int]:
        """Determine number of vertices of each degree in graph

        Returns:
            Dict mapping integers (degree) to integers (number of vertices of
                of that degree in graph)
        """
        vertex_degree_counts = {}
        for adj_list in self.graph_adj_list_repr:
            deg_of_u = len(adj_list)
            try:
                vertex_degree_counts[deg_of_u] += 1
            except KeyError:
                vertex_degree_counts[deg_of_u] = 1

        return vertex_degree_counts

    def delete_edge(self, u: int, v: int):
        """Delete edge

        Removes both arcs from the respective vertex adjacency lists

        Args:
            u: Index of first vertex incident on edge to delete
            v: Index of second vertex incident on edge to delete

        Raises:
            GraphError: If edge endpoints are invalid
        """
        try:
            self._vertex_validation(u)
            self._vertex_validation(v)
        except GraphError as e:
            raise GraphError(f"Unable to delete edge {{{u}, {v}}}.") from e

        self.graph_adj_list_repr[u].remove(v)
        self.graph_adj_list_repr[v].remove(u)
