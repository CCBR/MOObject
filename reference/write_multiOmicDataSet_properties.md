# Write multiOmicDataSet properties to individual files.

The `sample_meta` and `annotation` properties are written to CSV files,
the `counts` property is written to a subdirectory of CSV files, and the
`analyses` property is written to a subdirectory of CSV or RDS files
depending on the type of each analysis result.

## Usage

``` r
write_multiOmicDataSet_properties(moo, output_dir = "moo")

## S7 method for class <MOObject::multiOmicDataSet>
write_multiOmicDataSet_properties(moo, output_dir = "moo")
```

## Arguments

- moo:

  [multiOmicDataSet](https://ccbr.github.io/MOObject/reference/multiOmicDataSet.md)
  object to write properties from

- output_dir:

  Directory where the properties will be saved (default: "moo")

## Value

Invisibly returns `output_dir`.

## See also

Other moo:
[`create_multiOmicDataSet_from_dataframes()`](https://ccbr.github.io/MOObject/reference/create_multiOmicDataSet_from_dataframes.md),
[`create_multiOmicDataSet_from_files()`](https://ccbr.github.io/MOObject/reference/create_multiOmicDataSet_from_files.md),
[`extract_counts()`](https://ccbr.github.io/MOObject/reference/extract_counts.md),
[`multiOmicDataSet()`](https://ccbr.github.io/MOObject/reference/multiOmicDataSet.md),
[`read_multiOmicDataSet()`](https://ccbr.github.io/MOObject/reference/read_multiOmicDataSet.md),
[`read_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/reference/read_multiOmicDataSet_properties.md),
[`write_multiOmicDataSet()`](https://ccbr.github.io/MOObject/reference/write_multiOmicDataSet.md)

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
```
