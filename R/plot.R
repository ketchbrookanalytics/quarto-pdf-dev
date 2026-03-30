create_mtcars_plt <- function() {
  df <- mtcars[1:10, 1:4]

  ggplot2::ggplot(
    df,
    ggplot2::aes(
      x = row.names(df),
      y = mpg
    )
  ) +
    ggplot2::geom_bar(
      stat = "identity",
      fill = "lightblue",
      color = "black"
    ) +
    ggplot2::labs(
      title = "Miles per Gallon by Car",
      x = "Car (Make & Model)",
      y = "Miles per Gallon"
    ) +
    ggplot2::coord_flip() +
    ggplot2::theme_minimal()
}
