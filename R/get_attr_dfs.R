#' Get data frames bound to node attributes
#' @description From a graph object of class
#' \code{dgr_graph}, get one or more data frames
#' already bound as node and/or edge attribute
#' values given graph node and/or edges.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @param node_id a vector of node ID values in
#' which data frames are bound as node attrs.
#' @param edge_id a vector of edge ID values in
#' which data frames are bound as edge attrs.
#' @param return_format the format in which to
#' return the results of several data frames. These
#' can either be: (1) \code{single_tbl} (a tibble
#' object resulting from a `bind_rows` operation of
#' multiple data frames), and (2) \code{single_df}
#' (a single data frame which all of the data frame
#' data).
#' @return either a tibble, a data frame, or a list.
#' @examples
#' # Create a node data frame (ndf)
#' ndf <-
#'   create_node_df(
#'     n = 4,
#'     type = "basic",
#'     label = TRUE,
#'     value = c(3.5, 2.6, 9.4, 2.7))
#'
#' # Create an edge data frame (edf)
#' edf <-
#'   create_edge_df(
#'     from = c(1, 2, 3),
#'     to = c(4, 3, 1),
#'     rel = "leading_to")
#'
#' # Create a graph
#' graph <-
#'   create_graph(
#'     nodes_df = ndf,
#'     edges_df = edf)
#'
#' # Create 3 simple data frames to add as
#' # attributes to nodes/edges
#' df_1 <-
#'   data.frame(
#'     a = c("one", "two"),
#'     b = c(1, 2),
#'     stringsAsFactors = FALSE)
#'
#' df_2 <-
#'   data.frame(
#'     a = c("three", "four"),
#'     b = c(3, 4),
#'     stringsAsFactors = FALSE)
#'
#' df_for_edges <-
#'   data.frame(
#'     c = c("five", "six"),
#'     d = c(5, 6),
#'     stringsAsFactors = FALSE)
#'
#' # Bind data frames as node attributes
#' # for nodes `1` and `4`; bind a data
#' # frame as an edge attribute as well
#' graph <-
#'   graph %>%
#'   set_df_as_node_attr(
#'     node = 1,
#'     df = df_1) %>%
#'   set_df_as_node_attr(
#'     node = 4,
#'     df = df_2) %>%
#'   set_df_as_edge_attr(
#'     edge = 1,
#'     df = df_for_edges)
#'
#' # Get a single tibble by specifying the
#' # nodes from which there are data frames
#' # bound as node attributes
#' get_attr_dfs(
#'   graph,
#'   node_id = c(1, 4))
#' #> # A tibble: 4 x 6
#' #>   node_edge__    id  type label     a     b
#' #>         <chr> <int> <chr> <chr> <chr> <dbl>
#' #> 1        node     1 basic     1   one     1
#' #> 2        node     1 basic     1   two     2
#' #> 3        node     4 basic     4 three     3
#' #> 4        node     4 basic     4  four     4
#'
#' # You can also get data frames that are
#' # associated with edges by using the
#' # same function
#' get_attr_dfs(
#'   graph,
#'   edge_id = 1)
#' #> # A tibble: 2 x 7
#' #>   node_edge__    id        rel  from    to     c     d
#' #>         <chr> <int>      <chr> <int> <int> <chr> <dbl>
#' #> 1        edge     1 leading_to     1     4  five     5
#' #> 2        edge     1 leading_to     1     4   six     6
#'
#' # It's also possible to collect data frames
#' # associated with both nodes and edges
#' get_attr_dfs(
#'   graph,
#'   node_id = 4,
#'   edge_id = 1)
#' #> # A tibble: 4 x 11
#' #>   node_edge__    id  type label        rel  from    to
#' #>         <chr> <int> <chr> <chr>      <chr> <int> <int>
#' #> 1        node     4 basic     4       <NA>    NA    NA
#' #> 2        node     4 basic     4       <NA>    NA    NA
#' #> 3        edge     1  <NA>  <NA> leading_to     1     4
#' #> 4        edge     1  <NA>  <NA> leading_to     1     4
#' #> # ... with 4 more variables: a <chr>, b <dbl>, c <chr>,
#' #> #   d <dbl>
#'
#' # If a data frame is desired instead,
#' # set `return_format = "single_df"`
#' get_attr_dfs(
#'   graph,
#'   edge_id = 1,
#'   return_format = "single_df")
#' #>   node_edge__ id        rel from to    c d
#' #> 1        edge  1 leading_to    1  4 five 5
#' #> 2        edge  1 leading_to    1  4  six 6
#' @importFrom dplyr filter select bind_rows filter starts_with everything left_join
#' @importFrom tibble as_tibble tibble
#' @importFrom purrr flatten_chr
#' @export get_attr_dfs

get_attr_dfs <- function(graph,
                         node_id = NULL,
                         edge_id = NULL,
                         return_format = "single_tbl") {

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {

    stop(
      "The graph object is not valid.",
      call. = FALSE)
  }

  # Validation: Graph contains nodes
  if (graph_contains_nodes(graph) == FALSE) {

    stop(
      "The graph contains no nodes, so, a df cannot be added.",
      call. = FALSE)
  }

  # Create bindings for specific variables
  id <- from <- to <- type <- rel <- label <- NULL
  df_id <- df_id__ <- id__ <- node_edge__ <-  NULL

  # Collect data frames that are attributes of graph nodes
  if (!is.null(node_id)) {

    # Get the `df_id` values for the provided nodes
    df_ids_nodes <-
      graph$nodes_df %>%
      dplyr::filter(id %in% node_id) %>%
      dplyr::select(id, type, label, dplyr::starts_with("df_id")) %>%
      tibble::as_tibble() %>%
      dplyr::select(df_id) %>%
      purrr::flatten_chr()

    if (any(df_ids_nodes %in% (graph$df_storage %>% names()))) {

      df_tbl_nodes <-
        df_ids_nodes %>%
        purrr::map_df(
          function(x){
            if (x %in% (graph$df_storage %>% names())) {
              graph$df_storage[[x]] %>%
                dplyr::left_join(
                  graph$nodes_df %>%
                    dplyr::select(id, type, label, df_id),
                  by = c("df_id__" = "df_id")) %>%
                dplyr::select(-df_id__) %>%
                dplyr::select(-id__) %>%
                dplyr::select(node_edge__, id, type, label, everything())
            } else {
              tibble::tibble()
            }})
    }
  }

  # Collect data frames that are attributes of graph edges
  if (!is.null(edge_id)) {

    # Get the `df_id` values for the provided edges
    df_ids_edges <-
      graph$edges_df %>%
      dplyr::filter(id %in% edge_id) %>%
      dplyr::select(id, from, to, rel, dplyr::starts_with("df_id")) %>%
      tibble::as_tibble() %>%
      dplyr::select(df_id) %>%
      purrr::flatten_chr()

    if (any(df_ids_edges %in% (graph$df_storage %>% names()))) {

      df_tbl_edges <-
        df_ids_edges %>%
        purrr::map_df(
          function(x){
            if (x %in% (graph$df_storage %>% names())) {
              graph$df_storage[[x]] %>%
                dplyr::left_join(
                  graph$edges_df %>%
                    dplyr::select(id, from, to, rel, df_id),
                  by = c("df_id__" = "df_id")) %>%
                dplyr::select(-df_id__) %>%
                dplyr::select(-id__) %>%
                dplyr::select(node_edge__, id, from, to, rel, everything())
            } else {
              tibble::tibble()
            }})
    }
  }

  if (exists("df_tbl_nodes") & exists("df_tbl_edges")) {

    df <-
      dplyr::bind_rows(df_tbl_nodes, df_tbl_edges) %>%
      dplyr::select(
        node_edge__, id, type, label,
        rel, from, to, dplyr::everything())
  }

  if (exists("df_tbl_nodes") & !exists("df_tbl_edges")) {

    df <- df_tbl_nodes %>%
      dplyr::select(node_edge__, id, type, label, dplyr::everything())
  }

  if (!exists("df_tbl_nodes") & exists("df_tbl_edges")) {

    df <- df_tbl_edges %>%
      dplyr::select(node_edge__, id, rel, from, to, dplyr::everything())
  }

  if (!exists("df_tbl_nodes") & !exists("df_tbl_edges")) {
    df <- NA
  }

  if (return_format == "single_df") {
    df <- as.data.frame(df, stringsAsFactors = FALSE)
  }

  df
}
