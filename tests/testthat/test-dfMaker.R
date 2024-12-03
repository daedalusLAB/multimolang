# tests/testthat/test-dfMaker.R

library(testthat)
library(multimolang) # Ensure the package name is correct

# General test for dfMaker
test_that("dfMaker processes a folder and returns a data frame", {
  # Use the package path
  input_folder <- system.file("extdata", "eg", "o2", package = "multimolang")

  # Run dfMaker
  result <- dfMaker(input.folder = input_folder, no_save = TRUE)

  # Debugging: Display information about the result
  message("Is it a data.frame?: ", is.data.frame(result))
  if (is.data.frame(result)) {
    message("Number of rows: ", nrow(result))
    message("Columns: ", paste(colnames(result), collapse = ", "))
  }

  # Check that the result is a data frame
  expect_true(is.data.frame(result), "The result is not a data.frame")

  # Check that it is not empty
  expect_gt(nrow(result), 0, "The result is empty")

  # Check that it contains the expected columns
  expected_columns <- c("x", "y", "c", "nx", "ny", "type_points", "people_id", "points", "id", "frame")
  expect_true(all(expected_columns %in% colnames(result)), "Missing expected columns")
})

# Test for fast_scaling = TRUE (pose_keypoints only)
test_that("Origin and scaling points are correctly transformed with fast_scaling = TRUE for pose_keypoints", {
  # Define the input folder with example data using system.file()
  input_folder <- system.file("extdata", "eg", "o2", package = "multimolang")

  # Verify that the input folder exists
  expect_true(dir.exists(input_folder), "The input folder does not exist")

  # Define the keypoint types and their transformation coordinates
  keypoint_types <- list(
    "1" = c(1, 1, 5, 5) # pose_keypoints
  )

  # Iterate over each keypoint type and verify transformations
  for (type_code in names(keypoint_types)) {
    transformation_coords <- keypoint_types[[type_code]]
    verify_transformation(as.numeric(type_code), transformation_coords, input_folder, fast_scaling = TRUE)
  }
})

# Test for fast_scaling = FALSE (including pose_keypoints)
test_that("Origin and scaling points are correctly transformed with fast_scaling = FALSE for all keypoints", {
  # Define the input folder with example data using system.file()
  input_folder <- system.file("extdata", "eg", "o2", package = "multimolang")

  # Verify that the input folder exists
  expect_true(dir.exists(input_folder), "The input folder does not exist")

  # Define the keypoint types and their transformation coordinates
  keypoint_types <- list(
    "1" = c(1, 1, 5, 5), # pose_keypoints
    "2" = c(2, 1, 5, 5), # face_keypoints
    "3" = c(3, 1, 5, 5), # hand_left_keypoints
    "4" = c(4, 1, 5, 5)  # hand_right_keypoints
  )

  # Iterate over each keypoint type and verify transformations
  for (type_code in names(keypoint_types)) {
    transformation_coords <- keypoint_types[[type_code]]
    verify_transformation(as.numeric(type_code), transformation_coords, input_folder, fast_scaling = FALSE)
  }
})

# Test with a custom configuration file where all values are set to true
test_that("dfMaker processes a folder using a custom configuration file with all true values", {
  # Use the package path for the input data
  input_folder <- system.file("extdata", "eg", "o2", package = "multimolang")
  expect_true(dir.exists(input_folder), "The input folder does not exist")

  # Path to the configuration file (config_all_true.json)
  config_file <- system.file("extdata", "config_all_true.json", package = "multimolang")
  expect_true(file.exists(config_file), "The configuration file does not exist")

  # Run dfMaker with the configuration file
  result <- dfMaker(input.folder = input_folder, config.path = config_file, no_save = TRUE)

  # Check that the result is a data frame
  expect_true(is.data.frame(result), "The result is not a data.frame")

  # Check that it is not empty
  expect_gt(nrow(result), 0, "The result is empty")

  # Debugging: Display information about the configuration used
  message("Configuration file used: ", config_file)

  # List of columns to check
  required_columns <- c("exp_search", "datetime", "country_code",
                        "network_code", "program_name", "time_range")

  # Iterate over each column to ensure it exists
  for (col in required_columns) {
    if (col %in% colnames(result)) {
      expect_true(!any(is.na(result[[col]])), paste0("The column ", col, " contains NA values"))
    } else {
      warning(paste0("The column ", col, " was not found in the result"))
    }
  }

  # Print column names and the first row if any required column is missing
  if (col %in% colnames(result)) {
    expect_true(!any(is.na(result[[col]])), paste0("The column ", col, " contains NA values"))
  } else {
    warning(paste0("The column ", col, " was not found in the result"))
    print(colnames(result))
    print(result[1, ])
  }
})
