# Read a multiOmicDataSet from RDS

Read a multiOmicDataSet from RDS

## Usage

``` r
read_multiOmicDataSet(filepath)
```

## Arguments

- filepath:

  Path to an RDS file produced by
  [`write_multiOmicDataSet()`](https://ccbr.github.io/MOObject/dev/reference/write_multiOmicDataSet.md)

## Value

A
[multiOmicDataSet](https://ccbr.github.io/MOObject/dev/reference/multiOmicDataSet.md)
object.

## See also

Other moo:
[`create_multiOmicDataSet_from_dataframes()`](https://ccbr.github.io/MOObject/dev/reference/create_multiOmicDataSet_from_dataframes.md),
[`create_multiOmicDataSet_from_files()`](https://ccbr.github.io/MOObject/dev/reference/create_multiOmicDataSet_from_files.md),
[`extract_counts()`](https://ccbr.github.io/MOObject/dev/reference/extract_counts.md),
[`multiOmicDataSet()`](https://ccbr.github.io/MOObject/dev/reference/multiOmicDataSet.md),
[`read_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/dev/reference/read_multiOmicDataSet_properties.md),
[`write_multiOmicDataSet()`](https://ccbr.github.io/MOObject/dev/reference/write_multiOmicDataSet.md),
[`write_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/dev/reference/write_multiOmicDataSet_properties.md)

## Examples

``` r
sample_metadata <- data.frame(sample_id = c("s1", "s2"), group = c("A", "B"))
counts_dat <- data.frame(
  feature_id = c("gene1", "gene2"),
  s1 = c(10, 20),
  s2 = c(15, 25)
)
moo <- create_multiOmicDataSet_from_dataframes(sample_metadata, counts_dat)
filepath <- tempfile(fileext = ".rds")
write_multiOmicDataSet(moo, filepath)
moo2 <- read_multiOmicDataSet(filepath)
```
