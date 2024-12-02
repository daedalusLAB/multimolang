dfMaker <- function(
    input.folder,
    config.path,
    output.file = NULL,
    output.path = NULL,
    no_save = FALSE,
    fast_scaling = TRUE,
    transformation_coords = c(1, 1, 5, 5)
) {
  # Initialize variables to store metadata and final data
  all_data <- list()
  default_config <- list(
    extract_datetime = FALSE,
    extract_time = FALSE,
    extract_exp_search = FALSE,
    extract_country_code = FALSE,
    extract_network_code = FALSE,
    extract_program_name = FALSE,
    extract_time_range = FALSE,
    timezone = "America/Los_Angeles"
  )

  # Check if config path is provided and read the configuration; use default if not provided
  if (missing(config.path)) {
    config <- default_config
  } else {
    config <- arrow::read_json_arrow(config.path, as_data_frame = TRUE) |> as.list()
    # Ensure any missing config values are set to default
    for (name in names(default_config)) {
      if (is.null(config[[name]])) {
        config[[name]] <- default_config[[name]]
      }
    }
  }

  # List all JSON files in the input directory
  files <- list.files(input.folder, pattern = "*.json", full.names = TRUE)

  # Control variable to ensure message is printed only once
  message_printed <- FALSE

  # Loop through each file to process
  for (frame_file in files) {
    # Read the JSON file and extract the keypoints data
    rawData <- arrow::read_json_arrow(frame_file, as_data_frame = TRUE)[[2]][[1]][2:5]

    if (sum(capture.output(rawData) != "<unspecified> [4]") != 0) {
      total_points <- sum(sapply(rawData, function(x) length(unlist(x)) / 3))
      # Define the expected number of points for each type of keypoints
      model_type <- ifelse(total_points > 25, "137_points", "25_points")
      rawData <- if (model_type == "25_points") rawData[1] else rawData
      check_points <- if (model_type == "137_points") c(25, 70, 21, 21) else c(25)

      if (!message_printed) {
        if (model_type == "25_points") {
          message("Model: BODY_25")
        } else {
          message("Model: COCO_WholeBody")
        }
        message_printed <- TRUE
      }

      # Metadata extraction based on the configuration
      metadata <- gsub(".*[\\\\/]", "", frame_file)
      frame <- as.numeric(regmatches(metadata, regexec("[0-9]{12}", metadata)))
      id <- gsub("_\\d{12}_keypoints.json", "", metadata)

      # Extract additional metadata if enabled in configuration
      if (config$extract_datetime) {
        timezone <- ifelse(is.null(config$timezone), default_config$timezone, config$timezone)
        datetime_str <- sub("^(\\d{4}-\\d{2}-\\d{2})_(\\d{4})_.*$", "\\1 \\2", metadata)
        datetime <- as.POSIXct(datetime_str, format = "%Y-%m-%d %H%M", tz = timezone)
      } else {
        datetime <- NA
      }

      exp_search <- if (config$extract_exp_search) {
        gsub(".*[0-9]_(.*)_\\d{12}_keypoints\\.json$", "\\1", metadata)
      } else {
        NA
      }
      country_code <- if (config$extract_country_code) {
        sub(".*?_(\\w{2})_.*", "\\1", metadata)
      } else {
        NA
      }
      network_code <- if (config$extract_network_code) {
        sub("^.*_\\d{4}_\\w{2}_([^_]+)_.*$", "\\1", metadata)
      } else {
        NA
      }
      program_name <- if (config$extract_program_name) {
        sub("^.*_\\d{4}_\\w{2}_[^_]+_(.*?)_\\d+-\\d+.*$", "\\1", metadata)
      } else {
        NA
      }
      time_range <- if (config$extract_time_range) {
        sub("^.*_(\\d+-\\d+)_.*$", "\\1", metadata)
      } else {
        NA
      }

      for (person_index in 1:nrow(rawData)) {
        can_transform <- TRUE  # Initialize transformation flag

        if (fast_scaling == FALSE) {
          # Extract the keypoint type and point indices from transformation_coords
          keypoint_type <- transformation_coords[1]         # Keypoint type
          origin_point_index <- transformation_coords[2] + 1         # Index of the origin point
          i_point_index <- transformation_coords[3] + 1         # Index of the point defining vector_i
          j_point_index <- transformation_coords[4] + 1         # Index of the point defining vector_j

          # Extract and process the data matrix for the specified keypoint type
          matrix_data_t <- matrix(
            unlist(rawData[person_index, keypoint_type]),
            ncol = 3,
            nrow = check_points[keypoint_type],
            byrow = TRUE
          )
          matrix_data_t <- apply(matrix_data_t, 2, as.numeric)
          matrix_data_t[, 1:2][matrix_data_t[, 1:2] == 0] <- NA  # Replace zeros with NAs

          # Validate indices are within the allowed range
          if (max(origin_point_index, i_point_index, j_point_index) > nrow(matrix_data_t)) {
            can_transform <- FALSE
          } else {
            # Set up the vectors `origin`, `vector_i`, and `vector_j` based on `matrix_data_t`
            origin <- matrix_data_t[origin_point_index, 1:2]  # Extract the origin point
            vector_i <- matrix_data_t[i_point_index, 1:2] - origin  # Vector vector_i

            # Determine vector_j based on whether i_point_index equals j_point_index
            if (i_point_index == j_point_index) {
              # Compute vector_j as the orthogonal vector to vector_i
              vector_j <- c(vector_i[2], -vector_i[1])
            } else {
              # Use the provided j_point_index to compute vector_j
              vector_j <- matrix_data_t[j_point_index, 1:2] - origin
            }

            # Check if any of the keypoints are NA
            if (any(is.na(origin)) || any(is.na(vector_i)) || any(is.na(vector_j))) {
              can_transform <- FALSE
            }
          }
        }

        for (keypoint_type_index in 1:ncol(rawData)) {
          matrix_data <- matrix(
            unlist(rawData[person_index, keypoint_type_index]),
            ncol = 3,
            nrow = check_points[keypoint_type_index],
            byrow = TRUE
          )
          matrix_data <- apply(matrix_data, 2, as.numeric)
          matrix_data[, 1:2][matrix_data[, 1:2] == 0] <- NA  # Replace zeros with NAs

          # Create the origin vector when keypoint_type_index == 1 and fast_scaling is TRUE
          if (keypoint_type_index == 1 && fast_scaling == TRUE) {
            origin_point_index <- transformation_coords[2] + 1      # Index of the origin point
            i_point_index <- transformation_coords[3] + 1      # Index of the point defining vector_i

            origin <- matrix_data[origin_point_index, 1:2]          # Extract origin point
            vector_i <- matrix_data[i_point_index, 1:2] - origin    # Vector vector_i
            vector_j <- c(-vector_i[2], vector_i[1])                # Orthogonal vector to vector_i

            # Check for NA values
            if (any(is.na(origin)) || any(is.na(vector_i))) {
              can_transform <- FALSE
            }
          }

          relative_coords <- sweep(matrix_data[, 1:2], 2, origin, FUN = "-")  # Subtract origin from all points

          if (fast_scaling == FALSE) {
            if (can_transform) {
              # Transformation matrix
              transformation_matrix <- matrix(c(vector_i, vector_j), nrow = 2)

              # Compute determinant
              common_denominator <- det(transformation_matrix)

              # Check if determinant is NA or zero
              if (is.na(common_denominator) || common_denominator == 0) {
                transformed_coords <- matrix(NA, nrow = nrow(relative_coords), ncol = 2)
              } else {
                # Use Cramer's Rule to compute the transformed coordinates
                transformed_coords <- matrix(NA, nrow = nrow(relative_coords), ncol = 2)
                for (point_index in 1:nrow(relative_coords)) {
                  relative_point <- relative_coords[point_index, ]
                  # Compute numerator for x and y using Cramer's Rule
                  numerator_x <- det(matrix(c(relative_point, vector_j), nrow = 2))
                  numerator_y <- det(matrix(c(vector_i, relative_point), nrow = 2))
                  new_x <- numerator_x / common_denominator
                  new_y <- numerator_y / common_denominator
                  transformed_coords[point_index, ] <- c(new_x, new_y)
                }
              }
            } else {
              # Cannot perform transformation, set transformed_coords to NA
              transformed_coords <- matrix(NA, nrow = nrow(relative_coords), ncol = 2)
            }
          } else {
            # Fast scaling
            if (can_transform) {
              scaling_factor <- vector_i[1]
              if (is.na(scaling_factor) || scaling_factor == 0) {
                transformed_coords <- matrix(NA, nrow = nrow(relative_coords), ncol = 2)
              } else {
                transformed_coords <- relative_coords / scaling_factor                   # Scale
                transformed_coords[, 2] <- -transformed_coords[, 2]                      # Invert y-axis
              }
            } else {
              # Cannot perform transformation, set transformed_coords to NA
              transformed_coords <- matrix(NA, nrow = nrow(relative_coords), ncol = 2)
            }
          }

          # Prepare the list of data for the data frame
          frame_data_list <- list(
            x = matrix_data[, 1],
            y = matrix_data[, 2],
            c = matrix_data[, 3],
            nx = transformed_coords[, 1],
            ny = transformed_coords[, 2],
            type_points = gsub("_2d", "", colnames(rawData[keypoint_type_index])),
            people_id = person_index,
            points = c(0:(nrow(matrix_data) - 1)),
            id = id,
            frame = frame
          )

          # Aggregate dynamic only non-NA variables
          if (!is.na(exp_search)) frame_data_list$exp_search <- exp_search
          if (!is.na(datetime)) frame_data_list$datetime <- datetime
          if (!is.na(country_code)) frame_data_list$country_code <- country_code
          if (!is.na(network_code)) frame_data_list$network_code <- network_code
          if (!is.na(program_name)) frame_data_list$program_name <- program_name
          if (!is.na(time_range)) frame_data_list$time_range <- time_range

          df <- data.frame(frame_data_list, stringsAsFactors = FALSE)

          # Add the data frame to the list
          all_data[[length(all_data) + 1]] <- df
        }
      }

      cat("\n")  # File separator
      message("The frame ", frame, " has been read.")

    } else {
      # If rawData is empty, print a message indicating it
      message("File: ", basename(frame_file))
      message("File is empty.")
    }
  }

  # Combine all the individual frames into one data frame
  final_data <- do.call(rbind, all_data)

  if (!no_save) {
    # Use processed_id for auto-naming if output.file is NULL or empty
    if (is.null(output.file) || output.file == "") {
      if (length(unique(final_data$id)) != 1) {
        stop(paste("Error: Multiple unique IDs found:", paste(unique(final_data$id), collapse = ", ")))
      } else {
        if (!is.null(output.path)) {
          # Ensure output.path exists and is a valid path
          dir.create(output.path, recursive = TRUE, showWarnings = FALSE)
          # Construct the file name using file.path
          output.file <- file.path(output.path, paste0(unique(final_data$id), ".parquet"))
        } else {
          # Use a default folder in the current directory
          default_dir <- file.path(getwd(), "df_outputs")
          dir.create(default_dir, recursive = TRUE, showWarnings = FALSE)
          output.file <- file.path(default_dir, paste0(unique(final_data$id), ".parquet"))
        }
      }
    }

    # Determine the output format based on the file extension
    if (!is.null(output.file)) {
      file_ext <- tools::file_ext(output.file)
      if (tolower(file_ext) == "csv") {
        write.csv(final_data, output.file, row.names = FALSE)
      } else if (tolower(file_ext) == "parquet") {
        arrow::write_parquet(final_data, sink = output.file)
      } else {
        warning("Unsupported file extension. Returning data frame.")
      }
    }
  }

  return(final_data)
}
