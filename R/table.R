create_mtcars_tbl <- function() {
  mtcars[1:10, 1:4] |>
    head() |>
    tibble::as_tibble(rownames = "car") |>
    gt::gt() |>
    # bold column headers
    gt::tab_style(
      style = gt::cell_text(weight = "bold"),
      locations = gt::cells_column_labels()
    ) |>
    gt::tab_options(
      table.font.names = "Roboto"
    )
}
