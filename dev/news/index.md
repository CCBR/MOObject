# Changelog

## MOObject 0.5.0

This is the first release of MOObject! 🎉

- Add `multiOmicDataSet` S7 class, constructors, object IO helpers, and
  tests. ([\#1](https://github.com/CCBR/MOObject/issues/1),
  [@kelly-sovacool](https://github.com/kelly-sovacool))
  - [`create_multiOmicDataSet_from_files()`](https://ccbr.github.io/MOObject/dev/reference/create_multiOmicDataSet_from_files.md),
    [`create_multiOmicDataSet_from_dataframes()`](https://ccbr.github.io/MOObject/dev/reference/create_multiOmicDataSet_from_dataframes.md),
    [`extract_counts()`](https://ccbr.github.io/MOObject/dev/reference/extract_counts.md),
    [`read_multiOmicDataSet()`](https://ccbr.github.io/MOObject/dev/reference/read_multiOmicDataSet.md),
    `write_multiOmicDataSet`,
    [`write_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/dev/reference/write_multiOmicDataSet_properties.md).
- Add
  [`read_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/dev/reference/read_multiOmicDataSet_properties.md)
  as inverse of
  [`write_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/dev/reference/write_multiOmicDataSet_properties.md).
  ([\#2](https://github.com/CCBR/MOObject/issues/2),
  [@copilot](https://github.com/copilot))
- Ensure backward compatibility by coercing legacy MOSuite MOO objects
  when read/loaded. ([\#13](https://github.com/CCBR/MOObject/issues/13),
  [@kelly-sovacool](https://github.com/kelly-sovacool))
- Add runnable `@examples` to all exported functions, using synthetic
  data instead of network calls so they run reliably.
  ([\#10](https://github.com/CCBR/MOObject/issues/10),
  [@kelly-sovacool](https://github.com/kelly-sovacool))
- MOObject is archived in Zenodo with DOI
  [10.5281/zenodo.22239360)](https://doi.org/10.5281/zenodo.22239360).
  ([\#9](https://github.com/CCBR/MOObject/issues/9),
  [@kelly-sovacool](https://github.com/kelly-sovacool))
