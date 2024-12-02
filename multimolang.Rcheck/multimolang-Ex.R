pkgname <- "multimolang"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
base::assign(".ExTimings", "multimolang-Ex.timings", pos = 'CheckExEnv')
base::cat("name\tuser\tsystem\telapsed\n", file=base::get(".ExTimings", pos = 'CheckExEnv'))
base::assign(".format_ptime",
function(x) {
  if(!is.na(x[4L])) x[1L] <- x[1L] + x[4L]
  if(!is.na(x[5L])) x[2L] <- x[2L] + x[5L]
  options(OutDec = '.')
  format(x[1L:3L], digits = 7L)
},
pos = 'CheckExEnv')

### * </HEADER>
library('multimolang')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("dfMaker")
### * dfMaker

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: dfMaker
### Title: dfMaker Function
### Aliases: dfMaker

### ** Examples

# Example 1: Define paths to example data included with the package
input.folder <- system.file("extdata/ex_videos/o1",
                            package = "multimolang")
output.file <- file.path(tempdir(), "processed_data.csv")
output.path <- tempdir()  # Use a temporary directory for writing output

# Run dfMaker with example data
df <- dfMaker(
  input.folder = input.folder,
  output.file = output.file,
  output.path = output.path,
  no_save = FALSE,
  fast_scaling = TRUE,
  transformation_coords = c(1, 1, 5, 5)
)

# View the first few rows of the resulting data frame
head(df)

# Example 2: Using NewsScape data with a custom configuration file

# Define paths to example data
input.folder <- system.file("extdata/ex_videos/o1",
                            package = "multimolang")

# Define the configuration file path
config.path <- system.file("extdata/config_all_true.json",
                           package = "multimolang")

# Define output paths
output.file <- file.path(tempdir(), "processed_data.csv")
output.path <- tempdir()

# Run dfMaker with custom configuration
df <- dfMaker(
  input.folder = input.folder,
  config.path = config.path,
  output.file = output.file,
  output.path = output.path,
  no_save = FALSE,
  fast_scaling = TRUE,
  transformation_coords = c(1, 1, 5, 5)
)

# View the first few rows
head(df)




base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("dfMaker", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
