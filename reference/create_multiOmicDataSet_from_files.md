# Construct a multiOmicDataSet object from text files (e.g. TSV, CSV).

Construct a multiOmicDataSet object from text files (e.g. TSV, CSV).

## Usage

``` r
create_multiOmicDataSet_from_files(
  sample_meta_filepath,
  feature_counts_filepath,
  count_type = "raw",
  sample_id_colname = NULL,
  feature_id_colname = NULL,
  delim = NULL,
  ...
)
```

## Arguments

- sample_meta_filepath:

  path to text file with sample IDs and metadata for differential
  analysis.

- feature_counts_filepath:

  path to text file of expected feature counts (e.g. gene counts from
  RSEM).

- count_type:

  type to assign the values of `counts_dat` to in the `counts` slot

- sample_id_colname:

  name of the column in `sample_metadata` that contains the sample IDs.
  (Default: `NULL` - first column in the sample metadata will be used.)

- feature_id_colname:

  name of the column in `counts_dat` that contains feature/gene IDs.
  (Default: `NULL` - first column in the count data will be used.)

- delim:

  Delimiter used in the input files. Any delimiter accepted by
  [`readr::read_delim()`](https://readr.tidyverse.org/reference/read_delim.html)
  can be used. If the files are in CSV format, set `delim = ','`; for
  TSV format, set `delim = '\t'`.

- ...:

  additional arguments forwarded to
  [`readr::read_delim()`](https://readr.tidyverse.org/reference/read_delim.html).

## Value

A `multiOmicDataSet` object.

## Examples

``` r
base_url <- paste0(
  "https://raw.githubusercontent.com/CCBR/MOSuite/",
  "refs/tags/v0.4.2/inst/extdata/nidap/"
)
moo <- create_multiOmicDataSet_from_files(
  sample_meta_filepath = paste0(
    base_url, "Sample_Metadata_Bulk_RNA-seq_Training_Dataset_CCBR.csv.gz"
  ),
  feature_counts_filepath = paste0(base_url, "Raw_Counts.csv.gz")
)
#> Rows: 43280 Columns: 10
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (1): GeneName
#> dbl (9): A1, A2, A3, B1, B2, B3, C1, C2, C3
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> Rows: 9 Columns: 5
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (3): Sample, Group, Label
#> dbl (2): Replicate, Batch
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
head(moo@sample_meta)
#> # A tibble: 6 × 5
#>   Sample Group Replicate Batch Label
#>   <chr>  <chr>     <dbl> <dbl> <chr>
#> 1 A1     A             1     1 A1   
#> 2 A2     A             2     2 A2   
#> 3 A3     A             3     2 A3   
#> 4 B1     B             1     1 B1   
#> 5 B2     B             2     1 B2   
#> 6 B3     B             3     2 B3   
head(moo@counts[['raw']])
#> # A tibble: 6 × 10
#>   GeneName         A1    A2    A3    B1    B2    B3    C1    C2    C3
#>   <chr>         <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 RP23-271O17.1     0     0     0     0     0     0     0     0     0
#> 2 Gm26206           0     0     0     0     0     0     0     0     0
#> 3 Xkr4              0     0     0     0     0     0     0     0     0
#> 4 RP23-317L18.1     0     0     0     0     0     0     0     0     0
#> 5 RP23-317L18.4     0     0     0     0     0     0     0     0     0
#> 6 RP23-317L18.3     0     0     0     0     0     0     0     0     0
```
