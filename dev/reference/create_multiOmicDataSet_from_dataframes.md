# Construct a multiOmicDataSet object from data frames

Construct a multiOmicDataSet object from data frames

## Usage

``` r
create_multiOmicDataSet_from_dataframes(
  sample_metadata,
  counts_dat,
  sample_id_colname = NULL,
  feature_id_colname = NULL,
  count_type = "raw"
)
```

## Arguments

- sample_metadata:

  sample metadata as a data frame or tibble. The first column is assumed
  to contain the sample IDs which must correspond to column names in the
  raw counts.

- counts_dat:

  data frame of feature counts (e.g. expected feature counts from RSEM).

- sample_id_colname:

  name of the column in `sample_metadata` that contains the sample IDs.
  (Default: `NULL` - first column in the sample metadata will be used.)

- feature_id_colname:

  name of the column in `counts_dat` that contains feature/gene IDs.
  (Default: `NULL` - first column in the count data will be used.)

- count_type:

  type to assign the values of `counts_dat` to in the `counts` slot

## Value

A `multiOmicDataSet` object.

## Examples

``` r
base_url <- paste0(
  "https://raw.githubusercontent.com/CCBR/MOSuite/",
  "refs/tags/v0.4.2/inst/extdata/nidap/"
)
sample_meta_dat <- readr::read_csv(paste0(
  base_url, "Sample_Metadata_Bulk_RNA-seq_Training_Dataset_CCBR.csv.gz"
))
#> Rows: 9 Columns: 5
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (3): Sample, Group, Label
#> dbl (2): Replicate, Batch
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
feature_counts_dat <- readr::read_csv(paste0(base_url, "Raw_Counts.csv.gz"))
#> Rows: 43280 Columns: 10
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (1): GeneName
#> dbl (9): A1, A2, A3, B1, B2, B3, C1, C2, C3
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
moo <- create_multiOmicDataSet_from_dataframes(
  sample_metadata = sample_meta_dat,
  counts_dat = feature_counts_dat
)
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
