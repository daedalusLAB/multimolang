# tests/testthat/helper-tests.R

# Auxiliary function to verify transformation points
verify_transformation <- function(type_code, transformation_coords, input_folder, fast_scaling = FALSE) {
  # Mapping type code to the type_points string
  type_map <- list(
    '1' = "pose_keypoints",
    '2' = "face_keypoints",
    '3' = "hand_left_keypoints",
    '4' = "hand_right_keypoints"
  )

  type <- type_map[[as.character(type_code)]]

  if (is.null(type)) {
    stop(paste("Unrecognized point type:", type_code))
  }

  # Execute dfMaker with the specified parameters
  result <- dfMaker(
    input.folder = input_folder,
    no_save = TRUE,
    transformation_coords = transformation_coords,
    fast_scaling = fast_scaling
  )

  # Check that the result is not empty
  expect_gt(nrow(result), 0, paste("The result is empty for", type))

  # Ensure that it contains the required columns
  required_columns <- c("nx", "ny", "points", "type_points")
  expect_true(all(required_columns %in% colnames(result)), paste("Missing required columns for", type))

  # Filter data for the current point type
  keypoints <- result[result$type_points == type, ]

  # Check that origin and scaling points exist
  origin_point_index <- transformation_coords[2]
  scaling_point_index <- transformation_coords[3]

  origin_point <- keypoints[keypoints$points == origin_point_index, ]
  scaling_point <- keypoints[keypoints$points == scaling_point_index, ]

  expect_gt(nrow(origin_point), 0, paste("The origin point does not exist for", type))
  expect_gt(nrow(scaling_point), 0, paste("The scaling point does not exist for", type))

  # Validate the origin point
  sum_origin <- sum(origin_point$nx, na.rm = TRUE) + sum(origin_point$ny, na.rm = TRUE)
  expect_equal(
    round(sum_origin, 10), # Rounded to avoid numerical issues
    0,
    info = paste("The sum of nx and ny for the origin point is not 0 for", type)
  )

  # Validate the scaling point
  valid_scaling_point <- scaling_point[!is.na(scaling_point$nx), ] # Exclude NA values
  if (nrow(valid_scaling_point) > 0) {
    # Provide debugging information if validation fails
    if (sum(valid_scaling_point$nx) != nrow(valid_scaling_point)) {
      message("Debugging scaling point for type: ", type)
      message("Length of scaling point: ", nrow(valid_scaling_point))
      message("Sum of scaling_point$nx: ", sum(valid_scaling_point$nx))
      message("Values of scaling_point$nx: ", paste(valid_scaling_point$nx, collapse = ", "))
      message("Values of scaling_point$ny: ", paste(valid_scaling_point$ny, collapse = ", "))
    }
    expect_equal(
      sum(valid_scaling_point$nx),
      nrow(valid_scaling_point),
      info = paste("The scaling point does not have nx = 1 for", type)
    )
  } else {
    warning(paste("All nx values are NA for the scaling point in", type))
  }
}
