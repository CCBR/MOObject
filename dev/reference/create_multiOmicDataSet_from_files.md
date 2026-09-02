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

A
[multiOmicDataSet](https://ccbr.github.io/MOObject/dev/reference/multiOmicDataSet.md)
object.

## See also

Other moo:
[`create_multiOmicDataSet_from_dataframes()`](https://ccbr.github.io/MOObject/dev/reference/create_multiOmicDataSet_from_dataframes.md),
[`extract_counts()`](https://ccbr.github.io/MOObject/dev/reference/extract_counts.md),
[`multiOmicDataSet()`](https://ccbr.github.io/MOObject/dev/reference/multiOmicDataSet.md),
[`read_multiOmicDataSet()`](https://ccbr.github.io/MOObject/dev/reference/read_multiOmicDataSet.md),
[`read_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/dev/reference/read_multiOmicDataSet_properties.md),
[`write_multiOmicDataSet()`](https://ccbr.github.io/MOObject/dev/reference/write_multiOmicDataSet.md),
[`write_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/dev/reference/write_multiOmicDataSet_properties.md)

## Examples

``` r
sample_meta_dat <- data.frame(sample_id = c("s1", "s2"), group = c("A", "B"))
feature_counts_dat <- data.frame(
  feature_id = c("gene1", "gene2"),
  s1 = c(10, 20),
  s2 = c(15, 25)
)
sample_meta_filepath <- tempfile(fileext = ".csv")
feature_counts_filepath <- tempfile(fileext = ".csv")
readr::write_csv(sample_meta_dat, sample_meta_filepath)
readr::write_csv(feature_counts_dat, feature_counts_filepath)

moo <- create_multiOmicDataSet_from_files(
  sample_meta_filepath = sample_meta_filepath,
  feature_counts_filepath = feature_counts_filepath,
  delim = ","
)
#> Rows: 2 Columns: 3
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (1): feature_id
#> dbl (2): s1, s2
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
#> Rows: 2 Columns: 2
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> chr (2): sample_id, group
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
head(moo@sample_meta)
#> # A tibble: 2 × 2
#>   sample_id group
#>   <chr>     <chr>
#> 1 s1        A    
#> 2 s2        B    
head(moo@counts[['raw']])
#> # A tibble: 2 × 3
#>   feature_id    s1    s2
#>   <chr>      <dbl> <dbl>
#> 1 gene1         10    15
#> 2 gene2         20    25
```
