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
