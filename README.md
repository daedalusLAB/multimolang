# **multimolang**: Multimodal Language Analysis Tools
  
  **multimolang** is a package designed to support multimodal data analysis for linguistic research. It serves as the main repository for the **MULTIFLOW** project and provides tools to process, analyze, and derive insights from multimodal datasets, starting with gesture trajectories extracted from video data.

The first implemented tool, `dfMaker`, processes raw OpenPose data into structured dataframes, optimized for large-scale, multimodal data science workflows. Future versions of **multimolang** will include additional tools for prosody analysis and multimodal language integration.

---
  
  ## **Installation**
  
  ```R
# Install from the local tar.gz file
install.packages("multimolang_0.1.1.tar.gz", repos = NULL, type = "source")

# Or install using devtools
devtools::install_github("daedalusLAB/multimolang")
```

---
  
  ## **Functions**
  
  Currently, the main function in the package is `dfMaker`, which provides:
  
  - **Flexible Input Configuration:** Accepts JSON files from OpenPose as input.
- **Transformation Capabilities:** Scales and normalizes body keypoints for gesture trajectory analysis.
- **Big Data Optimization:** Designed to handle large-scale multimodal datasets efficiently.

---
  
  ## **Example Usage**
  
  ### Process OpenPose Data
  
  ```R
# Define paths to example data included with the package
input.folder <- system.file("extdata", "ex_videos", "o1", package = "multimolang")
output.file <- file.path(tempdir(), "processed_data.csv")
output.path <- tempdir()

# Run dfMaker with example data
df <- dfMaker(
  input.folder = input.folder,
  output.file = output.file,
  output.path = output.path,
  no_save = FALSE,
  fast_scaling = TRUE,
  transformation_coords = c(1, 1, 5, 5)
)

# View the resulting data
head(df)
```

---
  
  ## **Development Status**
  
  Below is the current progress and pending tasks for **multimolang**:
  
  | **Element**                             | **Status**                                                                                          |
  |------------------------------------------|-----------------------------------------------------------------------------------------------------|
  | **Package Name**                         | Defined and unique in CRAN (planned for submission).                                                |
  | **DESCRIPTION File**                     | Complete with title, description, authors, maintainer, version, and dependencies.                   |
  | **License**                              | LGPL-3                                                                                             |
  | **Documentation**                        | Complete for the `dfMaker` function, with examples.                                                 |
  | **NEWS File**                            | Not included; optional for the first version.                                                       |
  | **Tests**                                | Implemented to ensure proper functionality.                                                         |
  | **README**                               | Included here.                                                                                      |
  | **Cross-Platform Compatibility**         |  Tested on Linux and Windows OS operating systems.                                                      |
  | **Included Functions**                   | Includes `dfMaker`; additional tools planned for multimodal analysis in future updates.              |
  
  **Note:** Future updates will incorporate tools for prosody and voice analysis, as well as co-speech gesture processing.

---
  
  ## **About MULTIFLOW**
  
  The **MULTIFLOW** project investigates the interplay between gesture, prosody, and language to uncover multimodal signatures in communication. Learn more about our research and goals.

### Publications in Preparation

- **R functions for creating dataframes from OpenPose raw data.**
  - **Analyzing gesture trajectories from normalized body keypoint detection.**
  - **Building Massive Co-Speech Gesture Datasets for Specific Linguistic Patterns.**
  - **Gestural behavior is systematically attuned to language: Novel data analysis of co-speech gesture and its implications for multimodal interfaces.**
  
  ---
  
  ## **Contributing**
  
  We welcome contributions to **multimolang**! For bug reports, feature requests, or collaboration inquiries, open an issue on [GitHub](https://github.com/daedalusLAB/multimolang).

---
  
  ## **See Also**
  
  - [dfMaker GitHub Repository](https://github.com/daedalusLAB/dfMaker)


--- 
  
  ## **License**
  
  The license for this package is pending. For further inquiries, contact the project maintainer.


  
