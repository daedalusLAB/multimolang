# tests/testthat/helper-tests.R

# Función auxiliar para verificar puntos de transformación
verify_transformation <- function(type_code, transformation_coords, input_folder, fast_scaling = FALSE) {
  # Mapeo del código de tipo a la cadena type_points
  type_map <- list(
    '1' = "pose_keypoints",
    '2' = "face_keypoints",
    '3' = "hand_left_keypoints",
    '4' = "hand_right_keypoints"
  )

  type <- type_map[[as.character(type_code)]]

  if (is.null(type)) {
    stop(paste("Tipo de punto no reconocido:", type_code))
  }

  # Ejecutar dfMaker con los parámetros especificados
  result <- dfMaker(
    input.folder = input_folder,
    no_save = TRUE,
    transformation_coords = transformation_coords,
    fast_scaling = fast_scaling
  )

  # Verificar que el resultado no está vacío
  expect_gt(nrow(result), 0, paste("El resultado está vacío para", type))

  # Asegurarse de que contiene las columnas necesarias
  required_columns <- c("nx", "ny", "points", "type_points")
  expect_true(all(required_columns %in% colnames(result)), paste("Faltan columnas necesarias para", type))

  # Filtrar los datos para el tipo de punto actual
  keypoints <- result[result$type_points == type, ]

  # Verificar que existen puntos de origen y escalado
  origin_point_index <- transformation_coords[2]
  scaling_point_index <- transformation_coords[3]

  origin_point <- keypoints[keypoints$points == origin_point_index, ]
  scaling_point <- keypoints[keypoints$points == scaling_point_index, ]

  expect_gt(nrow(origin_point), 0, paste("El punto de origen no existe para", type))
  expect_gt(nrow(scaling_point), 0, paste("El punto de escalado no existe para", type))

  # Identificar el punto de origen
  sum_origin <- sum(origin_point$nx, na.rm = TRUE) + sum(origin_point$ny, na.rm = TRUE)
  expect_equal(
    round(sum_origin, 10), # Redondeo para evitar problemas numéricos
    0,
    info = paste("La suma de nx y ny del punto de origen no es 0 para", type)
  )

  # Identificar el punto utilizado para escalar
  valid_scaling_point <- scaling_point[!is.na(scaling_point$nx), ] # Excluir valores NA
  if (nrow(valid_scaling_point) > 0) {
    # Mostrar información de depuración si la validación falla
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
      info = paste("El punto de escalado no tiene nx = 1 para", type)
    )
  } else {
    warning(paste("Todos los valores de nx son NA para el punto de escalado en", type))
  }
}
