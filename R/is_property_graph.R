#' Is the graph a property graph?
#' @description Provides a logical value on whether
#' the graph is property graph (i.e., all nodes have
#' an assigned \code{type} value and all edges have
#' an assigned \code{rel} value).
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @return a logical value.
#' # Create a graph with 2 nodes
#' # (with `type` values) and a
#' # single edge (with a `rel`)
#' simple_property_graph <-
#'   create_graph() %>%
#'   add_node(
#'     type = "a",
#'     label = "first") %>%
#'   add_node(
#'     type = "b",
#'     label = "second") %>%
#'   add_edge(
#'     from = "first",
#'     to = "second",
#'     rel = "rel_1")
#'
#' # This is indeed a property graph
#' # but to confirm this, use the
#' # `is_property_graph()` function
#' is_property_graph(simple_property_graph)
#' #> [1] TRUE
#'
#' # If a `type` attribute is
#' # removed, then this graph will
#' # no longer be a property graph
#' simple_property_graph %>%
#'   set_node_attrs(
#'     node_attr = type,
#'     values = NA,
#'     nodes = 1) %>%
#'   is_property_graph()
#' #> [1] FALSE
#'
#' # An empty graph will return FALSE
#' create_graph() %>%
#'   is_property_graph()
#' #> [1] FALSE
#' @export is_property_graph

is_property_graph <- function(graph) {

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {

    stop(
      "The graph object is not valid.",
      call. = FALSE)
  }

  if (is_graph_empty(graph)) {
    return(FALSE)
  } else if
  (all(
    !any(is.na(graph$nodes_df$type)), !any(graph$nodes_df$type == ""),
    !any(is.na(graph$edges_df$rel)), !any(graph$edges_df$rel == ""))) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}
