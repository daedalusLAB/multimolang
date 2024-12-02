# tests/testthat/test-dfMaker.R

library(testthat)
library(multimolang) # Asegúrate de que el nombre del paquete es correcto

# Prueba general para dfMaker
test_that("dfMaker processes a folder and returns a data frame", {
  # Usar la ruta del paquete
  input_folder <- system.file("extdata", "example_videos", "output1", package = "multimolang")

  # Ejecutar dfMaker
  result <- dfMaker(input.folder = input_folder, no_save = TRUE)

  # Depuración: Mostrar información sobre el resultado
  message("¿Es un data.frame?: ", is.data.frame(result))
  if (is.data.frame(result)) {
    message("Número de filas: ", nrow(result))
    message("Columnas: ", paste(colnames(result), collapse = ", "))
  }

  # Comprobar que es un data.frame
  expect_true(is.data.frame(result), "El resultado no es un data.frame")

  # Comprobar que no está vacío
  expect_gt(nrow(result), 0, "El resultado está vacío")

  # Comprobar que contiene las columnas esperadas
  expected_columns <- c("x", "y", "c", "nx", "ny", "type_points", "people_id", "points", "id", "frame")
  expect_true(all(expected_columns %in% colnames(result)), "Faltan columnas esperadas")
})

# Prueba para fast_scaling = TRUE (solo pose_keypoints)
test_that("Origin and scaling points are correctly transformed with fast_scaling = TRUE for pose_keypoints", {
  # Definir la carpeta de entrada con los datos de ejemplo usando system.file()
  input_folder <- system.file("extdata", "example_videos", "output1", package = "multimolang")

  # Verificar que la carpeta de entrada existe
  expect_true(dir.exists(input_folder), "La carpeta de entrada no existe")

  # Definir los tipos de puntos y sus coordenadas de transformación
  keypoint_types <- list(
    "1" = c(1, 1, 5, 5) # pose_keypoints
  )

  # Iterar sobre cada tipo de punto y verificar las transformaciones
  for (type_code in names(keypoint_types)) {
    transformation_coords <- keypoint_types[[type_code]]
    verify_transformation(as.numeric(type_code), transformation_coords, input_folder, fast_scaling = TRUE)
  }
})

# Prueba para fast_scaling = FALSE (incluyendo pose_keypoints)
test_that("Origin and scaling points are correctly transformed with fast_scaling = FALSE for all keypoints", {
  # Definir la carpeta de entrada con los datos de ejemplo usando system.file()
  input_folder <- system.file("extdata", "example_videos", "output1", package = "multimolang")

  # Verificar que la carpeta de entrada existe
  expect_true(dir.exists(input_folder), "La carpeta de entrada no existe")

  # Definir los tipos de puntos y sus coordenadas de transformación
  keypoint_types <- list(
    "1" = c(1, 1, 5, 5), # pose_keypoints
    "2" = c(2, 1, 5, 5), # face_keypoints
    "3" = c(3, 1, 5, 5), # hand_left_keypoints
    "4" = c(4, 1, 5, 5)  # hand_right_keypoints
  )

  # Iterar sobre cada tipo de punto y verificar las transformaciones
  for (type_code in names(keypoint_types)) {
    transformation_coords <- keypoint_types[[type_code]]
    verify_transformation(as.numeric(type_code), transformation_coords, input_folder, fast_scaling = FALSE)
  }
})


test_that("dfMaker processes a folder using a custom configuration file with all true values", {
  # Usar la ruta del paquete para los datos de entrada
  input_folder <- system.file("extdata", "example_videos", "output1", package = "multimolang")
  expect_true(dir.exists(input_folder), "La carpeta de entrada no existe")

  # Ruta del archivo de configuración (config_all_true.json)
  config_file <- system.file("extdata", "config_all_true.json", package = "multimolang")
  expect_true(file.exists(config_file), "El archivo de configuración no existe")

  # Ejecutar dfMaker con el archivo de configuración
  result <- dfMaker(input.folder = input_folder, config.path = config_file, no_save = TRUE)

  # Comprobar que el resultado es un data.frame
  expect_true(is.data.frame(result), "El resultado no es un data.frame")

  # Comprobar que no está vacío
  expect_gt(nrow(result), 0, "El resultado está vacío")

  # Depuración: Mostrar información sobre la configuración utilizada
  message("Archivo de configuración utilizado: ", config_file)

  # Comprobar que se aplicaron todas las configuraciones (ejemplo: timezone)
  timezone_column <- "timezone"
  if (timezone_column %in% colnames(result)) {
    expect_equal(unique(result[[timezone_column]]), "America/Los_Angeles", "La zona horaria no coincide con el archivo de configuración")
  } else {
    warning("No se encontró la columna de zona horaria en el resultado")
    print(colnames(result))
    print(result[1,])
  }
})
