#' Add edges from an edge data frame
#' to an existing graph object
#' @description With a graph object
#' of class \code{dgr_graph}, add
#' edges from an edge data frame to
#' that graph.
#' @param graph a graph object of
#' class \code{dgr_graph}.
#' @param edge_df an edge data frame
#' that is created using
#' \code{create_edge_df}.
#' @return a graph object of class
#' \code{dgr_graph}.
#' @examples
#' # Create a node data frame (ndf)
#' ndf <-
#'   create_node_df(
#'     n = 4,
#'     type = "letter",
#'     color = c(
#'       "red", "green",
#'       "grey", "blue"),
#'     value = c(
#'       3.5, 2.6, 9.4, 2.7))
#'
#' # Create a graph with nodes
#' # and no edges
#' graph <-
#'   create_graph(
#'     nodes_df = ndf)
#'
#' # Create an edge data frame (edf)
#' edf <-
#'   create_edge_df(
#'     from = c(1, 2, 3),
#'       to = c(4, 3, 1),
#'      rel = "leading_to")
#'
#' # Add the edge data frame to
#' # the graph object to create
#' # a graph with both nodes
#' # and edges
#' graph <-
#'   graph %>%
#'   add_edge_df(
#'     edge_df = edf)
#'
#' # Get the graph's edges to verify that the edge
#' # data frame had been added
#' graph %>%
#'   get_edges(
#'     return_type = "vector")
#' #> [1] "1->4" "2->3" "3->1"
#' @export add_edge_df

add_edge_df <- function(graph,
                        edge_df) {

  # Get the time of function start
  time_function_start <- Sys.time()

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {

    stop(
      "The graph object is not valid.",
      call. = FALSE)
  }

  # Validation: Graph contains nodes
  if (graph_contains_nodes(graph) == FALSE) {

    stop(
      "The graph contains no nodes, so, edges cannot be added.",
      call. = FALSE)
  }

  # Get the number of edges ever created for
  # this graph
  edges_created <- graph$last_edge

  # Get the number of edges in the graph
  edges_graph_1 <- graph %>% count_edges()

  # Combine the incoming edge data frame
  # with those in the graph
  combined_edges <-
    combine_edfs(
      graph$edges_df,
      edge_df)

  # Replace the graph's internal edge
  # data frame with the `combined_edges`
  # edge data frame
  graph$edges_df <- combined_edges

  # Get the updated number of edges in the graph
  edges_graph_2 <- graph %>% count_edges()

  # Get the number of edges added to
  # the graph
  edges_added <- edges_graph_2 - edges_graph_1

  # Update the `last_edge` counter
  graph$last_edge <- edges_created + nrow(combined_edges)

  # Update the `graph_log` df with an action
  graph$graph_log <-
    add_action_to_log(
      graph_log = graph$graph_log,
      version_id = nrow(graph$graph_log) + 1,
      function_used = "add_edge_df",
      time_modified = time_function_start,
      duration = graph_function_duration(time_function_start),
      nodes = nrow(graph$nodes_df),
      edges = nrow(graph$edges_df),
      d_e = edges_added)

  # Perform graph actions, if any are available
  if (nrow(graph$graph_actions) > 0) {
    graph <-
      graph %>%
      trigger_graph_actions()
  }

  # Write graph backup if the option is set
  if (graph$graph_info$write_backups) {
    save_graph_as_rds(graph = graph)
  }

  graph
}
