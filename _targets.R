# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(gt)
library(ggplot2)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

# Replace the target list below with your own:
list(
  tar_target(
    name = mtcars_tbl,
    command = create_mtcars_tbl()
  ),
  tar_target(
    name = mtcars_plt,
    command = create_mtcars_plt()
  )
)
