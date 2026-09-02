# Read multiOmicDataSet properties from individual files.

Reads a directory created by
[`write_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/reference/write_multiOmicDataSet_properties.md)
and reconstructs the
[multiOmicDataSet](https://ccbr.github.io/MOObject/reference/multiOmicDataSet.md)
object. The `sample_meta` and `annotation` properties are read from CSV
files, the `counts` property is read from the `counts/` subdirectory,
and the `analyses` property is read from the `analyses/` subdirectory.

## Usage

``` r
read_multiOmicDataSet_properties(input_dir)
```

## Arguments

- input_dir:

  Directory previously created by
  [`write_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/reference/write_multiOmicDataSet_properties.md).

## Value

A
[multiOmicDataSet](https://ccbr.github.io/MOObject/reference/multiOmicDataSet.md)
object.

## See also

Other moo:
[`create_multiOmicDataSet_from_dataframes()`](https://ccbr.github.io/MOObject/reference/create_multiOmicDataSet_from_dataframes.md),
[`create_multiOmicDataSet_from_files()`](https://ccbr.github.io/MOObject/reference/create_multiOmicDataSet_from_files.md),
[`extract_counts()`](https://ccbr.github.io/MOObject/reference/extract_counts.md),
[`multiOmicDataSet()`](https://ccbr.github.io/MOObject/reference/multiOmicDataSet.md),
[`read_multiOmicDataSet()`](https://ccbr.github.io/MOObject/reference/read_multiOmicDataSet.md),
[`write_multiOmicDataSet()`](https://ccbr.github.io/MOObject/reference/write_multiOmicDataSet.md),
[`write_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/reference/write_multiOmicDataSet_properties.md)

## Examples

``` r
sample_metadata <- data.frame(sample_id = c("s1", "s2"), group = c("A", "B"))
counts_dat <- data.frame(
  feature_id = c("gene1", "gene2"),
  s1 = c(10, 20),
  s2 = c(15, 25)
)
moo <- create_multiOmicDataSet_from_dataframes(sample_metadata, counts_dat)
output_dir <- tempfile()
write_multiOmicDataSet_properties(moo, output_dir)
moo2 <- read_multiOmicDataSet_properties(output_dir)
```
