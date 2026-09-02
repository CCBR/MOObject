# Coerce legacy multiOmicDataSet objects to current class

Accepts both legacy serialized objects (for example, class labels
including `MOSuite::multiOmicDataSet`) and current MOObject-created
objects. Legacy objects are reconstructed as
[`MOObject::multiOmicDataSet`](https://ccbr.github.io/MOObject/reference/multiOmicDataSet.md)
so S7 method dispatch works consistently.

## Usage

``` r
coerce_to_multiOmicDataSet(moo, source_label = "input")
```

## Arguments

- moo:

  object expected to represent a multiOmicDataSet

- source_label:

  label used in error messages to identify the object source

## Value

a `multiOmicDataSet` object compatible with current S7 methods
