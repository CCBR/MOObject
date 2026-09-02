# Extract count data

Extract count data

## Usage

``` r
extract_counts(moo, count_type, sub_count_type = NULL)

## S7 method for class <MOObject::multiOmicDataSet>
extract_counts(moo, count_type, sub_count_type = NULL)
```

## Arguments

- moo:

  multiOmicDataSet containing `count_type` & `sub_count_type` in the
  counts slot

- count_type:

  the type of counts to use – must be a name in the counts slot
  (`moo@counts[[count_type]]`)

- sub_count_type:

  if `count_type` is a list, specify the sub count type within the list
  (`moo@counts[[count_type]][[sub_count_type]]`). (Default: `NULL`)

## Value

A data frame of counts.

## See also

Other moo:
[`create_multiOmicDataSet_from_dataframes()`](https://ccbr.github.io/MOObject/dev/reference/create_multiOmicDataSet_from_dataframes.md),
[`create_multiOmicDataSet_from_files()`](https://ccbr.github.io/MOObject/dev/reference/create_multiOmicDataSet_from_files.md),
[`multiOmicDataSet()`](https://ccbr.github.io/MOObject/dev/reference/multiOmicDataSet.md),
[`read_multiOmicDataSet()`](https://ccbr.github.io/MOObject/dev/reference/read_multiOmicDataSet.md),
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
extract_counts(moo, "raw")
#>   feature_id s1 s2
#> 1      gene1 10 15
#> 2      gene2 20 25
```
