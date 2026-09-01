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

  `multiOmicDataSet` object to write properties from

- output_dir:

  Directory where the properties will be saved (default: "moo")

## Value

Invisibly returns `output_dir`.
