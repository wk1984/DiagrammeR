#' Get the maximum graph eccentricity
#' @description Get the diameter of a graph, which is
#' the largest eccentricity in the graph. The graph
#' eccentricity of a node is its shortest path from
#' the farthest other node in the graph.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @return a single numeric value representing the
#' maximum eccentricity of the graph.
#' @examples
#' # Create a cycle graph
#' graph <-
#'   create_graph() %>%
#'   add_cycle(n = 5)
#'
#' # Determine the graph's maximum
#' # eccentricity
#' get_max_eccentricity(graph)
#' #> [1] 4
#'
#' # Create a full graph and then
#' # get the maximum eccentricity
#' # value for that
#' create_graph() %>%
#'   add_full_graph(n = 10) %>%
#'   get_max_eccentricity()
#' #> [1] 1
#' @importFrom igraph diameter
#' @export get_max_eccentricity

get_max_eccentricity <- function(graph) {

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {

    stop(
      "The graph object is not valid.",
      call. = FALSE)
  }

  # If the graph is empty, then return NA
  if (nrow(graph$nodes_df) == 0) {
    return(as.numeric(NA))
  }

  # Convert the graph to an igraph object
  ig_graph <- to_igraph(graph)

  # Get the maximum eccentricity of the graph
  igraph::diameter(ig_graph)
}
