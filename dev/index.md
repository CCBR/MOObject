# MOObject 🐮

[![MOSuite
website](https://raw.githubusercontent.com/CCBR/MOSuite/refs/tags/v0.4.2/inst/extdata/logo/mosuite_logo_with_text.png)](https://ccbr.github.io/MOSuite/)

multiOmicDataSet object class for MOSuite

MOObject defines the multiOmicDataSet object class which is used in
MOSuite for differential RNA-seq and multi-omics analyses. Separating
the MOObject class definition from MOSuite allows for lightweight
installations in downstream workflows. See the [MOObject
website](https://ccbr.github.io/MOObject) for more information about the
class, and see the [MOSuite website](https://ccbr.github.io/MOSuite/)
for the most in-depth discussion about using these packages.

## Installation

You can install the development version of MOObject from
[GitHub](https://github.com/CCBR/MOObject) with:

``` r
# install.packages("remotes")
remotes::install_github("CCBR/MOObject")
```

## Usage

### MOObject

If you only need to read and write multiOmicDataSet objects, MOObject is
the package you should use to minimize dependencies for your project.

#### MOObject responsibilities:

- Define and export the S7 class `multiOmicDataSet`.
- Implement object-focused helpers only: constructors, validators,
  readers, and writers.
- Keep dependencies minimal (prefer base + S7 + lightweight IO packages
  only).

``` r
library(MOObject)

# create from csv files.
# example data are included in the MOSuite package.
base_url <- paste0(
  "https://raw.githubusercontent.com/CCBR/MOSuite/",
  "refs/tags/v0.4.2/inst/extdata/nidap/"
)
sample_meta_filepath <- paste0(
  base_url,
  "Sample_Metadata_Bulk_RNA-seq_Training_Dataset_CCBR.csv.gz"
)
feature_counts_filepath <- paste0(base_url, "Raw_Counts.csv.gz")

moo <- create_multiOmicDataSet_from_files(
  sample_meta_filepath,
  feature_counts_filepath
)

# write to Rds
moo |> write_multiOmicDataSet(filepath = 'moo.rds')
# write individual components to separate files in a directory
moo |> write_multiOmicDataSet_properties(output_dir = 'moo')

# read from Rds
moo <- read_multiOmicDataSet('moo.rds')
```

### MOSuite

MOSuite is the main package containing method implementations for
bulk-RNA-seq and multi-omics analysis. Please see the [introductory
vignette](https://ccbr.github.io/MOSuite/articles/intro.html) for a
quick start tutorial, or take a look at the [reference
documentation](https://ccbr.github.io/MOSuite/reference/index.html) for
detailed information on each function in the package.

MOSuite depends on MOObject and wraps its functions, so if you’re
already using MOSuite, there’s no need to load MOObject too.

``` r
library(MOSuite)
moo <- read_multiOmicDataSet('moo.rds')
```

#### MOSuite responsibilities:

- Define functions for analysis, modeling, plotting, normalization,
  filtering, and reporting.
- Import and operate on `multiOmicDataSet` from MOObject.

## Help & Contributing

Come across a **bug**? Open an
[issue](https://github.com/CCBR/MOObject/issues) and include a minimal
reproducible example.

Have a **question**? Ask it in
[discussions](https://github.com/CCBR/MOObject/discussions).

Want to **contribute** to this project? Check out the [contributing
guidelines](https://ccbr.github.io/MOObject/dev/CONTRIBUTING.md).
