# Read multiOmicDataSet properties from individual files.

Reads a directory created by
[`write_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/reference/write_multiOmicDataSet_properties.md)
and reconstructs the `multiOmicDataSet` object. The `sample_meta` and
`annotation` properties are read from CSV files, the `counts` property
is read from the `counts/` subdirectory, and the `analyses` property is
read from the `analyses/` subdirectory.

## Usage

``` r
read_multiOmicDataSet_properties(input_dir)
```

## Arguments

- input_dir:

  Directory previously created by
  [`write_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/reference/write_multiOmicDataSet_properties.md).

## Value

A `multiOmicDataSet` object.
