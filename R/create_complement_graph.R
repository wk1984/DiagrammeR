#' Create a complement of a graph
#' @description Create a complement graph which
#' contains only edges not present in the input graph.
#' It's important to nodes that any edge attributes
#' in the input graph's edges will be lost. Node
#' attributes will be retained, since they are
#' not affected by this transformation.
#' @param graph a graph object of class
#' \code{dgr_graph} that is created using
#' \code{create_graph}.
#' @param loops an option for whether loops should
#' be generated in the complement graph.
#' @return a graph object of class \code{dgr_graph}.
#' @importFrom igraph complementer
#' @examples
#' # Create a simple graph with a single cycle
#' graph <-
#'   create_graph() %>%
#'   add_cycle(n = 4)
#'
#' # Get the graph's edge data frame
#' graph %>%
#'   get_edge_df()
#' #>   id from to  rel
#' #> 1  1    1  2 <NA>
#' #> 2  2    2  3 <NA>
#' #> 3  3    3  4 <NA>
#' #> 4  4    4  1 <NA>
#'
#' # Create the complement of the graph
#' graph_c <- create_complement_graph(graph)
#'
#' # Get the edge data frame for the
#' # complement graph
#' graph_c %>%
#'   get_edge_df()
#' #>   id from to  rel
#' #> 1  1    1  4 <NA>
#' #> 2  2    1  3 <NA>
#' #> 3  3    2  4 <NA>
#' #> 4  4    2  1 <NA>
#' #> 5  5    3  2 <NA>
#' #> 6  6    3  1 <NA>
#' #> 7  7    4  3 <NA>
#' #> 8  8    4  2 <NA>
#' @export create_complement_graph

create_complement_graph <- function(graph,
                                    loops = FALSE) {

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
      "The graph contains no nodes, so, no traversal can occur.",
      call. = FALSE)
  }

  # Get the number of nodes ever created for
  # this graph
  nodes_created <- graph$last_node

  # Get the number of nodes in the graph
  nodes_graph_1 <- graph %>% count_nodes()

  # Get the number of edges ever created for
  # this graph
  edges_created <- graph$last_edge

  # Get the number of edges in the graph
  edges_graph_1 <- graph %>% count_edges()

  # Convert the graph to an igraph object
  ig_graph <- to_igraph(graph)

  # Get the complement graph
  ig_graph <- igraph::complementer(ig_graph, loops = loops)

  # Get the edge data frame for the complement graph
  edf_new <- from_igraph(ig_graph) %>% get_edge_df()

  # Add edge ID values to the complement graph edf
  edf_new$id <- seq(1, nrow(edf_new), 1) %>% as.integer()

  # Replace the input graph's edf with its complement
  graph$edges_df <- edf_new

  # Manually update the graph's edge counter
  graph$last_edge <- nrow(edf_new) %>% as.integer()

  # Scavenge any invalid, linked data frames
  graph <-
    graph %>%
    remove_linked_dfs()

  # Get the updated number of nodes in the graph
  nodes_graph_2 <- graph %>% count_nodes()

  # Get the number of nodes added to
  # the graph
  nodes_added <- nodes_graph_2 - nodes_graph_1

  # Get the updated number of edges in the graph
  edges_graph_2 <- graph %>% count_edges()

  # Get the number of edges added to
  # the graph
  edges_added <- edges_graph_2 - edges_graph_1

  # Update the `graph_log` df with an action
  graph$graph_log <-
    add_action_to_log(
      graph_log = graph$graph_log,
      version_id = nrow(graph$graph_log) + 1,
      function_used = "create_complement_graph",
      time_modified = time_function_start,
      duration = graph_function_duration(time_function_start),
      nodes = nrow(graph$nodes_df),
      edges = nrow(graph$edges_df),
      d_n = nodes_added,
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
