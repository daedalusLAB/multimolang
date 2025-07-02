# **multimolang**: Multimodal Language Analysis Tools

[![](https://cranlogs.r-pkg.org/badges/multimolang)](https://cran.r-project.org/package=multimolang)

**multimolang** is a package designed to support multimodal data analysis for linguistic research. It serves as the main repository for the **MULTIFLOW** project and provides tools to process, analyze, and derive insights from multimodal datasets, starting with gesture trajectories extracted from video data.

The first implemented tool, `dfMaker`, processes raw OpenPose data into structured dataframes, optimized for large-scale, multimodal data science workflows. Future versions of **multimolang** will include additional tools for prosody analysis and multimodal language integration.

---
## Citation

If you use `multimolang` or any of its core functions (such as `dfMaker`) in your research, please cite:

> Herreño Jiménez, B. (2024). *multimolang: Multimodal Language Analysis* [R package version 0.1.1]. The R Foundation. https://doi.org/10.32614/cran.package.multimolang

You can also retrieve the BibTeX entry by running in R:

```r
citation("multimolang")
```

---

## **Installation**

```R
# Install from CRAN
install.packages("multimolang")

# Or install using devtools
devtools::install_github("daedalusLAB/multimolang")
```

For detailed installation instructions and usage examples, please refer to the package vignettes.

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
| **Package Name**                         | Defined and unique in CRAN.                                                                         |
| **DESCRIPTION File**                     | Complete with title, description, authors, maintainer, version, and dependencies.                   |
| **Documentation**                        | Complete for the `dfMaker` function, with examples.                                                 |
| **NEWS File**                            | Not included; optional for the first version.                                                       |
| **Tests**                                | Implemented to ensure proper functionality.                                                         |
| **README**                               | Included here.                                                                                      |
| **Cross-Platform Compatibility**         | Tested on Linux and Windows operating systems.                                                      |
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

- [dfMaker Details](https://cran.r-project.org/web/packages/multimolang/vignettes/dfMaker-Details.html)

---

## **Recent Changes**

### Version 0.1.1 (December 12, 2024)

- Updated file naming conventions to comply with CRAN requirements.
- Improved compatibility with CRAN by refining documentation and dependencies.
- Minor fixes to `dfMaker` for enhanced error handling and performance.
- Added package vignettes for detailed usage examples.

For a complete list of changes, refer to the CHANGELOG in the repository.

