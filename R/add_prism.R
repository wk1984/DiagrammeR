#' Add a prism of nodes to the graph
#' @description With a graph object of class
#' \code{dgr_graph}, add a node prism to the graph.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @param n the number of nodes describing the shape
#' of the prism. For example, the triagonal prism has
#' \code{n} equal to 3 and it is composed of 6 nodes
#' and 9 edges. For any n-gonal prism, the graph will
#' be generated with 2\code{n} nodes and 3\code{n}
#' edges.
#' @param type an optional string that describes the
#' entity type for the nodes to be added.
#' @param label either a vector object of length
#' \code{n} that provides optional labels for the new
#' nodes, or, a boolean value where setting to
#' \code{TRUE} ascribes node IDs to the label and
#' \code{FALSE} yields a blank label.
#' @param rel an optional string for providing a
#' relationship label to all new edges created in the
#' node prism.
#' @param node_aes an optional list of named vectors
#' comprising node aesthetic attributes. The helper
#' function \code{node_aes()} is strongly recommended
#' for use here as it contains arguments for each
#' of the accepted node aesthetic attributes (e.g.,
#' \code{shape}, \code{style}, \code{color},
#' \code{fillcolor}).
#' @param edge_aes an optional list of named vectors
#' comprising edge aesthetic attributes. The helper
#' function \code{edge_aes()} is strongly recommended
#' for use here as it contains arguments for each
#' of the accepted edge aesthetic attributes (e.g.,
#' \code{shape}, \code{style}, \code{penwidth},
#' \code{color}).
#' @param node_data an optional list of named vectors
#' comprising node data attributes. The helper
#' function \code{node_data()} is strongly recommended
#' for use here as it helps bind data specifically
#' to the created nodes.
#' @param edge_data an optional list of named vectors
#' comprising edge data attributes. The helper
#' function \code{edge_data()} is strongly recommended
#' for use here as it helps bind data specifically
#' to the created edges.
#' @return a graph object of class \code{dgr_graph}.
#' @examples
#' # Create a new graph and
#' # add 2 prisms
#' graph <-
#'   create_graph() %>%
#'   add_prism(
#'     n = 3,
#'     type = "prism",
#'     label = "a") %>%
#'   add_prism(
#'     n = 3,
#'     type = "prism",
#'     label = "b")
#'
#' # Get node information from this graph
#' node_info(graph)
#' #>    id  type label deg indeg outdeg loops
#' #> 1   1 prism     a   3     1      2     0
#' #> 2   2 prism     a   3     1      2     0
#' #> 3   3 prism     a   3     1      2     0
#' #> 4   4 prism     a   3     2      1     0
#' #> 5   5 prism     a   3     2      1     0
#' #> 6   6 prism     a   3     2      1     0
#' #> 7   7 prism     b   3     1      2     0
#' #> 8   8 prism     b   3     1      2     0
#' #> 9   9 prism     b   3     1      2     0
#' #> 10 10 prism     b   3     2      1     0
#' #> 11 11 prism     b   3     2      1     0
#' #> 12 12 prism     b   3     2      1     0
#'
#' # Node and edge aesthetic and data
#' # attributes can be specified in
#' # the `node_aes`, `edge_aes`,
#' # `node_data`, and `edge_data`
#' # arguments
#'
#' set.seed(23)
#'
#' graph_w_attrs <-
#'   create_graph() %>%
#'   add_prism(
#'     n = 3,
#'     label = c(
#'       "one", "two",
#'       "three", "four",
#'       "five", "six"),
#'     type = c(
#'       "a", "a",
#'       "b", "b",
#'       "c", "c"),
#'     rel = "A",
#'     node_aes = node_aes(
#'       fillcolor = "steelblue"),
#'     edge_aes = edge_aes(
#'       color = "red",
#'       penwidth = 1.2),
#'     node_data = node_data(
#'       value = c(
#'         1.6, 2.8, 3.4,
#'         3.2, 5.3, 6.2)),
#'     edge_data = edge_data(
#'       value =
#'         rnorm(
#'           n = 9,
#'           mean = 5.0,
#'           sd = 1.0)))
#'
#' # Get the graph's node data frame
#' graph_w_attrs %>%
#'   get_node_df()
#' #>   id type label fillcolor value
#' #> 1  1    a   one steelblue   1.6
#' #> 2  2    a   two steelblue   2.8
#' #> 3  3    b three steelblue   3.4
#' #> 4  4    b  four steelblue   3.2
#' #> 5  5    c  five steelblue   5.3
#' #> 6  6    c   six steelblue   6.2
#'
#' # Get the graph's edge data frame
#' graph_w_attrs %>%
#'   get_edge_df()
#' #>   id from to rel penwidth color    value
#' #> 1  1    1  2   A      1.2   red 5.996605
#' #> 2  2    2  3   A      1.2   red 6.107490
#' #> 3  3    3  1   A      1.2   red 4.721914
#' #> 4  4    4  5   A      1.2   red 6.019205
#' #> 5  5    5  6   A      1.2   red 5.045437
#' #> 6  6    6  4   A      1.2   red 6.575780
#' #> 7  7    1  4   A      1.2   red 5.218288
#' #> 8  8    2  5   A      1.2   red 3.953465
#' #> 9  9    3  6   A      1.2   red 4.711311
#' @importFrom dplyr select bind_cols as_tibble
#' @export add_prism

add_prism <- function(graph,
                      n,
                      type = NULL,
                      label = TRUE,
                      rel = NULL,
                      node_aes = NULL,
                      edge_aes = NULL,
                      node_data = NULL,
                      edge_data = NULL) {

  # Get the time of function start
  time_function_start <- Sys.time()

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {

    stop(
      "The graph object is not valid.",
      call. = FALSE)
  }

  # Stop if n is too small
  if (n <= 2) {

    stop(
      "The value for `n` must be at least 3.",
      call. = FALSE)
  }

  # Create bindings for specific variables
  id <- index__ <- NULL

  # Get the number of nodes ever created for
  # this graph
  nodes_created <- graph$last_node

  # Get the number of edges ever created for
  # this graph
  edges_created <- graph$last_edge

  # Get the graph's global attributes
  global_attrs <- graph$global_attrs

  # Get the graph's log
  graph_log <- graph$graph_log

  # Get the graph's info
  graph_info <- graph$graph_info

  # Get the graph's state of being directed
  # or undirected
  graph_directed <- graph$directed

  # Get the sequence of nodes required
  nodes <- seq(1, 2 * n)

  # Collect node aesthetic attributes
  if (!is.null(node_aes)) {

    node_aes_tbl <- dplyr::as_tibble(node_aes)

    if (nrow(node_aes_tbl) < (2 * n) ) {

      node_aes$index__ <- 1:(2 * n)

      node_aes_tbl <-
        dplyr::as_tibble(node_aes) %>%
        dplyr::select(-index__)
    }

    if ("id" %in% colnames(node_aes_tbl)) {
      node_aes_tbl <-
        node_aes_tbl %>%
        dplyr::select(-id)
    }
  }

  # Collect edge aesthetic attributes
  if (!is.null(edge_aes)) {

    edge_aes_tbl <- dplyr::as_tibble(edge_aes)

    if (nrow(edge_aes_tbl) < (3 * n)) {

      edge_aes$index__ <- 1:(3 * n)

      edge_aes_tbl <-
        dplyr::as_tibble(edge_aes) %>%
        dplyr::select(-index__)
    }

    if ("id" %in% colnames(edge_aes_tbl)) {
      edge_aes_tbl <-
        edge_aes_tbl %>%
        dplyr::select(-id)
    }
  }

  # Collect node data attributes
  if (!is.null(node_data)) {

    node_data_tbl <- dplyr::as_tibble(node_data)

    if (nrow(node_data_tbl) < (2 * n)) {

      node_data$index__ <- 1:(2 * n)

      node_data_tbl <-
        dplyr::as_tibble(node_data) %>%
        dplyr::select(-index__)
    }

    if ("id" %in% colnames(node_data_tbl)) {
      node_data_tbl <-
        node_data_tbl %>%
        dplyr::select(-id)
    }
  }

  # Collect edge data attributes
  if (!is.null(edge_data)) {

    edge_data_tbl <- dplyr::as_tibble(edge_data)

    if (nrow(edge_data_tbl) < (3 * n)) {

      edge_data$index__ <- 1:(3 * n)

      edge_data_tbl <-
        dplyr::as_tibble(edge_data) %>%
        dplyr::select(-index__)
    }

    if ("id" %in% colnames(edge_data_tbl)) {
      edge_data_tbl <-
        edge_data_tbl %>%
        dplyr::select(-id)
    }
  }

  # Create a node data frame for the prism graph
  prism_nodes <-
    create_node_df(
      n = length(nodes),
      type = type,
      label = label)

  # Add node aesthetics if available
  if (exists("node_aes_tbl")) {

    prism_nodes <-
      prism_nodes %>%
      dplyr::bind_cols(node_aes_tbl)
  }

  # Add node data if available
  if (exists("node_data_tbl")) {

    prism_nodes <-
      prism_nodes %>%
      dplyr::bind_cols(node_data_tbl)
  }

  # Create an edge data frame for the prism graph
  prism_edges <-
    create_edge_df(
      from = c(nodes[1:(length(nodes)/2)],
               nodes[((length(nodes)/2) + 1):length(nodes)],
               nodes[1:(length(nodes)/2)]),
      to = c(nodes[2:(length(nodes)/2)],
             nodes[1],
             nodes[((length(nodes)/2) + 2):length(nodes)],
             nodes[((length(nodes)/2) + 1)],
             nodes[1:(length(nodes)/2)] + n),
      rel = rel)

  n_nodes = nrow(prism_nodes)

  n_edges = nrow(prism_edges)

  # Add edge aesthetics if available
  if (exists("edge_aes_tbl")) {

    prism_edges <-
      prism_edges %>%
      dplyr::bind_cols(edge_aes_tbl)
  }

  # Add edge data if available
  if (exists("edge_data_tbl")) {

    prism_edges <-
      prism_edges %>%
      dplyr::bind_cols(edge_data_tbl)
  }

  # Create the prism graph
  prism_graph <-
    create_graph(
      directed = graph_directed,
      nodes_df = prism_nodes,
      edges_df = prism_edges)

  # If the input graph is not empty, combine graphs
  # using the `combine_graphs()` function
  if (!is_graph_empty(graph)) {

    combined_graph <- combine_graphs(graph, prism_graph)

    # Update the `last_node` counter
    combined_graph$last_node <- nodes_created + n_nodes

    # Update the `last_edge` counter
    combined_graph$last_edge <- edges_created + n_edges

    # Update the `graph_log` df with an action
    graph_log <-
      add_action_to_log(
        graph_log = graph_log,
        version_id = nrow(graph_log) + 1,
        function_used = "add_prism",
        time_modified = time_function_start,
        duration = graph_function_duration(time_function_start),
        nodes = nrow(combined_graph$nodes_df),
        edges = nrow(combined_graph$edges_df),
        d_n = n_nodes,
        d_e = n_edges)

    combined_graph$global_attrs <- global_attrs
    combined_graph$graph_log <- graph_log
    combined_graph$graph_info <- graph_info

    # Perform graph actions, if any are available
    if (nrow(combined_graph$graph_actions) > 0) {
      combined_graph <-
        combined_graph %>%
        trigger_graph_actions()
    }

    # Write graph backup if the option is set
    if (combined_graph$graph_info$write_backups) {
      save_graph_as_rds(graph = combined_graph)
    }

    return(combined_graph)
  } else {

    # Update the `graph_log` df with an action
    graph_log <-
      add_action_to_log(
        graph_log = graph_log,
        version_id = nrow(graph_log) + 1,
        function_used = "add_prism",
        time_modified = time_function_start,
        duration = graph_function_duration(time_function_start),
        nodes = nrow(prism_graph$nodes_df),
        edges = nrow(prism_graph$edges_df),
        d_n = n_nodes,
        d_e = n_edges)

    prism_graph$global_attrs <- global_attrs
    prism_graph$graph_log <- graph_log
    prism_graph$graph_info <- graph_info

    # Perform graph actions, if any are available
    if (nrow(prism_graph$graph_actions) > 0) {
      prism_graph <-
        prism_graph %>%
        trigger_graph_actions()
    }

    # Write graph backup if the option is set
    if (prism_graph$graph_info$write_backups) {
      save_graph_as_rds(graph = prism_graph)
    }

    return(prism_graph)
  }
}
