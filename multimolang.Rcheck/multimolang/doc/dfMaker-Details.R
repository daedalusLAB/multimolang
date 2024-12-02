## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, include = FALSE---------------------------------------------------
library(multimolang)

## ----example_usage, eval = FALSE----------------------------------------------
# # Define input parameters
# input_folder <- "path/to/json/files"
# config_path <- "path/to/config.json"  # Optional if using NewsScape data
# output_file <- "processed_data.csv"
# output_path <- "path/to/output"
# 
# # Call the dfMaker function
# df <- dfMaker(
#   input.folder = input_folder,
#   config.path = config_path,
#   output.file = output_file,
#   output.path = output_path,
#   no_save = FALSE,
#   fast_scaling = TRUE,
#   transformation_coords = c(1, 1, 5, 5)
# )
# 
# # View the first few rows of the resulting data frame
# head(df)

## ----install_arrow, eval = FALSE----------------------------------------------
# install.packages("arrow")

## ----full_example, eval = FALSE-----------------------------------------------
# # Define paths to example data included with the package
# input_folder <- system.file("extdata/example_videos/output1", package = "multimolang")
# output_file <- "processed_data.csv"
# output_path <- tempdir()  # Use a temporary directory for writing output during examples
# 
# # Run dfMaker
# df <- dfMaker(
#   input.folder = input_folder,
#   output.file = output_file,
#   output.path = output_path,
#   no_save = FALSE,
#   fast_scaling = TRUE,
#   transformation_coords = c(1, 1, 5, 5)
# )
# 
# # View the first few rows of the resulting data frame
# head(df)
# 

