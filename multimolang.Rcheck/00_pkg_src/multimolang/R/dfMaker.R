#' dfMaker Function
#'
#' @description
#' \code{dfMaker} processes and organizes keypoints data generated by 'OpenPose', compiling multiple JSON files into a structured data frame.
#' While the function can be used to load data into R for analysis, its primary purpose is integration into data processing pipelines for large-scale applications.
#'
#' The function supports datasets with pose_keypoints alone or datasets containing pose_keypoints along with face (\code{--face}) and hands (\code{--hand}) keypoints.
#' It does not support partial datasets where only face or hand keypoints are provided, or where pose_keypoints are combined with only face or only hands keypoints.
#'
#' The JSON files may indicate an older data schema version (e.g., 1.3), which refers to the output format and not the actual OpenPose software version.
#' This function has been tested with OpenPose version 1.7.0 and supports its output structure.
#'
#' @param input.folder Path to the folder containing OpenPose JSON files. The folder should contain only the JSON files to be processed; including other files may lead to unexpected behavior.
#' @param config.path Path to the configuration file used for extracting metadata from filenames when processing data from the UCLA NewsScape archive. This configuration file specifies which metadata fields to extract based on the standard NewsScape filename format. If not provided, default settings are used, which may not extract NewsScape-specific metadata.
#' @param output.file Name of the output file. If \code{NULL} and there is only one unique \code{id} in the data, an auto-generated name with a \code{.parquet} extension is used. If there are multiple unique \code{id} values and \code{output.file} is \code{NULL}, the function will return an error; you must provide an explicit output file name. If the specified \code{output.file} ends with \code{.csv}, the output will be saved in CSV format. Otherwise, the default format is \code{.parquet}.
#' @param output.path Path to save the output file. If \code{NULL}, the file is saved in a default directory called \code{df_outputs} in the current working directory.
#' @param no_save Logical. If \code{TRUE}, the output is not saved to a file.
#' @param fast_scaling Logical. If \code{TRUE}, uses fast scaling for transformation.
#'   \strong{Warning:} When \code{fast_scaling} is \code{TRUE}, scaling is performed only using pose keypoints (\code{t_typepoint = 1}), and the secondary vector \code{v.j} is not utilized.
#' @param transformation_coords Numeric vector of length 4 that specifies the transformation coordinates. Each element of the vector has a specific role:
#'   \enumerate{
#'     \item \strong{\code{t_typepoint}}: Type of keypoints to use. Possible values:
#'       \enumerate{
#'         \item \code{1}: Body keypoints (pose).
#'         \item \code{2}: Face keypoints.
#'         \item \code{3}: Left hand keypoints.
#'         \item \code{4}: Right hand keypoints.
#'       }
#'     \item \strong{\code{o_point}}: Index of the keypoint used as the \strong{origin} in the new coordinate system.
#'     \item \strong{\code{i_point}}: Index of the keypoint that defines the primary base vector \code{v.i}.
#'     \item \strong{\code{j_point}}: Index of the keypoint that defines the secondary base vector \code{v.j}.
#'       \itemize{
#'         \item If \code{i_point == j_point}, \code{v.j} is calculated as a \strong{perpendicular} vector to \code{v.i} (orthonormalization).
#'         \item If \code{fast_scaling = TRUE}, \code{v.j} is not utilized and should be set to \code{NA}.
#'       }
#'   }
#'
#' @details
#' This function depends on the \strong{arrow} package for reading and writing JSON and Parquet files. Please ensure that the \strong{arrow} package is installed.
#'
#' When processing data with multiple unique \code{id} values, ensure that you provide an explicit \code{output.file} name to avoid errors.
#'
#' The function expects JSON files generated by OpenPose with a specific structure. Variations in the OpenPose configuration or version may affect the format of these files. Ensure that the JSON files conform to the expected structure for accurate processing.
#'
#' Each row in the produced data frame represents a single keypoint detected in a specific frame and associated with a specific person. The columns \strong{nx} and \strong{ny} provide the transformed coordinates based on the selected origin and linear transformation parameters. The \strong{id} column links the keypoints to the corresponding input file from which they were extracted.
#'
#' The data frame may contain missing values (\code{NA}) for keypoints that could not be reliably detected.
#'
#' @section R Version Requirements:
#' This function uses the native pipe operator \code{|>} introduced in R version 4.1.0. Therefore, R version 4.1.0 or higher is required to use this function.
#'
#' @section Error Handling:
#' If the JSON files do not have the expected format or are empty, the function will skip these files and print a message indicating the issue. If \code{output.file} is \code{NULL} and multiple unique \code{id} values are found, the function will stop and return an error, prompting you to provide an explicit \code{output.file} name.
#'
#' @note
#' The \code{dfMaker} function processes all keypoints provided by OpenPose, including pose, face, and hand keypoints. For the specific indices and descriptions of these keypoints, please refer to the OpenPose documentation.
#'
#' @return
#' A data frame containing the processed keypoints data with the following structure:
#'
#' \describe{
#'   \item{\strong{id}}{Character. Identifier derived from the name of the file processed.}
#'   \item{\strong{frame}}{Numeric. Frame number from which the data is extracted.}
#'   \item{\strong{people_id}}{Integer. Identifier for each detected person in the frame.}
#'   \item{\strong{type_points}}{Character. Type of keypoints (e.g., \code{"pose_keypoints"}, \code{"face_keypoints"}, \code{"hand_left_keypoints"}, \code{"hand_right_keypoints"}).}
#'   \item{\strong{points}}{Integer. Index of the keypoints sequence.}
#'   \item{\strong{x}}{Numeric. X-coordinate of the keypoint.}
#'   \item{\strong{y}}{Numeric. Y-coordinate of the keypoint.}
#'   \item{\strong{c}}{Numeric. Confidence score for the detected keypoint, ranging from 0 to 1.}
#'   \item{\strong{nx}}{Numeric. Transformed X-coordinate in the new coordinate system.}
#'   \item{\strong{ny}}{Numeric. Transformed Y-coordinate in the new coordinate system.}
#' }
#'
#' Example of the returned data frame:
#'
#' \preformatted{
#' 'data.frame': 8220 obs. of 10 variables:
#'  $ id         : chr  "2006-01-14_0600_US_KTTV-FOX_Ten_OClock_News_273-275_back_then" ...
#'  $ frame      : num  0 0 0 0 0 0 0 0 0 0 ...
#'  $ people_id  : int  1 1 1 1 1 1 1 1 1 1 ...
#'  $ type_points: chr  "pose_keypoints" "pose_keypoints" "pose_keypoints" "pose_keypoints" ...
#'  $ points     : int  0 1 2 3 4 5 6 7 8 9 ...
#'  $ x          : num  223 209 131 113 NA ...
#'  $ y          : num  113 178 178 273 NA ...
#'  $ c          : num  0.892 0.7 0.522 0.273 0 ...
#'  $ nx         : num  0.165 0 -0.945 -1.165 NA ...
#'  $ ny         : num  0.791 0 -0.000446 -1.14343 NA ...
#' }
#'
#' @section Note on NewsScape Data:
#'
#' The \strong{UCLA NewsScape} archive is the largest TV news video archive globally, containing over 300,000 news programs from the United States and around the world, dating from 1979 to the present. The collection provides streaming of news content and includes time-stamped closed-caption texts of most broadcasts, along with various metadata generated by machine learning and computer vision classifiers. This offers advanced search functions and enables new possibilities for teaching, research, and scholarship.
#'
#' When processing data from NewsScape, the \code{config.path} parameter allows you to specify a configuration file that defines how to extract metadata from the filenames of the videos. The filenames in this archive have specific structures containing metadata such as date, time, country code, network code, program name, and time range.
#'
#' \strong{Example of Configuration File (\code{config.json}):}
#' \preformatted{
#' {
#'     "extract_datetime": true,
#'     "extract_time": true,
#'     "extract_exp_search": true,
#'     "extract_country_code": true,
#'     "extract_network_code": true,
#'     "extract_program_name": true,
#'     "extract_time_range": true,
#'     "timezone": "America/Los_Angeles"
#' }
#' }
#' This configuration allows you to control which metadata fields are extracted from the filenames. The \code{search_exp} variable is used in linguistic studies to analyze specific expressions within the content.
#'
#' \strong{Important:} Ensure that your data filenames follow the standard NewsScape naming convention for accurate metadata extraction. If your data does not conform to this naming convention, you may need to adjust your filenames or modify the configuration accordingly.
#'
#' \strong{Example of a NewsScape Filename and Its Components:}
#' \preformatted{
#' 2006-01-14_0600_US_KTTV-FOX_Ten_OClock_News_273-275_back_000000000000_keypoints.json
#' }
#'
#' \strong{Breakdown of Filename Components:}
#' \describe{
#'   \item{\strong{\code{2006-01-14}}}{Extracted by \code{extract_datetime}: The date of the broadcast (YYYY-MM-DD).}
#'   \item{\strong{\code{0600}}}{Extracted by \code{extract_time}: The time of the broadcast in 24-hour format (HHMM).}
#'   \item{\strong{\code{US}}}{Extracted by \code{extract_country_code}: The country code where the broadcast originated.}
#'   \item{\strong{\code{KTTV-FOX_Ten_OClock_News_273-275_back_then}}}{Extracted by \code{extract_network_code}, \code{extract_program_name}, and \code{extract_exp_search}:
#'     \describe{
#'       \item{\strong{\code{KTTV-FOX}}}{The network code and station identifier.}
#'       \item{\strong{\code{Ten_OClock_News}}}{The program name.}
#'       \item{\strong{\code{273-275}}}{The time range or segment identifier within the program.}
#'       \item{\strong{\code{back}}}{Extracted by \code{extract_exp_search}: A specific expression or keyword used in linguistic studies.}
#'     }
#'   }
#' }
#'
#'#' \strong{Nota:}
#' \describe{
#'   \item{\strong{\code{K}}}{Abreviatura de \emph{network_code}.}
#'   \item{\strong{\code{N}}}{Abreviatura de \emph{program_name}.}
#' }
#'
#' \strong{Note on Timezone:}
#' The \code{timezone} parameter in the configuration file is used to standardize the broadcast times and is not treated as a variable within the data extraction process.
#'
#' Example of how timezone is applied in R:
#' \preformatted{
#' datetime <- as.POSIXct(datetime_str, format = "\%Y-\%m-\%d \%H\%M", tz = timezone)
#' }
#'
#' @examples
#' # Example 1: Define paths to example data included with the package
#' input.folder <- system.file("extdata/eg/o1",
#'                             package = "multimolang")
#' output.file <- file.path(tempdir(), "processed_data.csv")
#' output.path <- tempdir()  # Use a temporary directory for writing output
#'
#' # Run dfMaker with example data
#' df <- dfMaker(
#'   input.folder = input.folder,
#'   output.file = output.file,
#'   output.path = output.path,
#'   no_save = FALSE,
#'   fast_scaling = TRUE,
#'   transformation_coords = c(1, 1, 5, 5)
#' )
#'
#' # View the first few rows of the resulting data frame
#' head(df)
#'
#' # Example 2: Using NewsScape data with a custom configuration file
#'
#' # Define paths to example data
#' input.folder <- system.file("extdata/eg/o1",
#'                             package = "multimolang")
#'
#' # Define the configuration file path
#' config.path <- system.file("extdata/config_all_true.json",
#'                            package = "multimolang")
#'
#' # Define output paths
#' output.file <- file.path(tempdir(), "processed_data.csv")
#' output.path <- tempdir()
#'
#' # Run dfMaker with custom configuration
#' df <- dfMaker(
#'   input.folder = input.folder,
#'   config.path = config.path,
#'   output.file = output.file,
#'   output.path = output.path,
#'   no_save = FALSE,
#'   fast_scaling = TRUE,
#'   transformation_coords = c(1, 1, 5, 5)
#' )
#'
#' # View the first few rows
#' head(df)
#'
#' @references
#' For more information about the UCLA NewsScape archive, visit the official website:
#' \url{https://bigdatasocialscience.ucla.edu/newsscape/}
#'
#' The \strong{arrow} R package is used for efficient reading and writing of JSON and Parquet files. For more information, visit:
#' \url{https://cran.r-project.org/package=arrow}
#'
#' OpenPose GitHub Repository:
#' \url{https://github.com/CMU-Perceptual-Computing-Lab/openpose}
#'
#' 'OpenPose' Academic Article:
#' Cao, Z., Hidalgo, G., Simon, T., Wei, S.-E., & Sheikh, Y. (2019). OpenPose: Realtime Multi-Person 2D Pose Estimation Using Part Affinity Fields. *IEEE Transactions on Pattern Analysis and Machine Intelligence*, 43(1), 172–186. \doi{10.1109/TPAMI.2019.2929257}
#'
#' Alternatively, explore the 'OpenPose' GitHub repository for implementation details:
#' \url{https://github.com/CMU-Perceptual-Computing-Lab/openpose}
#'
#' @import arrow
#' @importFrom utils capture.output write.csv
#' @export
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
                if (scaling_factor >= 0) {
                  transformed_coords[, 2] <- -transformed_coords[, 2]                   # Invert y-axis if scaling_factor is positive
                }
                # If scaling_factor is negative, do not invert y-axis
              }
            } else {
              # Cannot perform transformation, set transformed_coords to NA
              transformed_coords <- matrix(NA, nrow = nrow(relative_coords), ncol = 2)
            }
          }

          # Prepare the list of data for the data frame
          frame_data_list <- list(
            id = id,
            frame = frame,
            people_id = person_index,
            type_points = gsub("_2d", "", colnames(rawData[keypoint_type_index])),
            points = c(0:(nrow(matrix_data) - 1)),
            x = matrix_data[, 1],
            y = matrix_data[, 2],
            c = matrix_data[, 3],
            nx = transformed_coords[, 1],
            ny = transformed_coords[, 2]
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
