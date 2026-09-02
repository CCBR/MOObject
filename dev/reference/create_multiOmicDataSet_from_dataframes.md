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

A
[multiOmicDataSet](https://ccbr.github.io/MOObject/dev/reference/multiOmicDataSet.md)
object.

## See also

Other moo:
[`create_multiOmicDataSet_from_files()`](https://ccbr.github.io/MOObject/dev/reference/create_multiOmicDataSet_from_files.md),
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
moo <- create_multiOmicDataSet_from_dataframes(
  sample_metadata = sample_meta_dat,
  counts_dat = feature_counts_dat
)
head(moo@sample_meta)
#>   sample_id group
#> 1        s1     A
#> 2        s2     B
head(moo@counts[['raw']])
#>   feature_id s1 s2
#> 1      gene1 10 15
#> 2      gene2 20 25
```
