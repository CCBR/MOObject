## MOObject 0.5.0

This is the first release of MOObject! 🎉

- Add `multiOmicDataSet` S7 class, constructors, object IO helpers, and tests. (#1, @kelly-sovacool)
  - `create_multiOmicDataSet_from_files()`, `create_multiOmicDataSet_from_dataframes()`, `extract_counts()`, `read_multiOmicDataSet()`, `write_multiOmicDataSet`, `write_multiOmicDataSet_properties()`.
- Add `read_multiOmicDataSet_properties()` as inverse of `write_multiOmicDataSet_properties()`. (#2, @copilot)
- Ensure backward compatibility by coercing legacy MOSuite MOO objects when read/loaded. (#13, @kelly-sovacool)
- Add runnable `@examples` to all exported functions, using synthetic data instead of network calls so they run reliably. (#10, @kelly-sovacool)
- MOObject is archived in Zenodo with DOI [10.5281/zenodo.22239360)](https://doi.org/10.5281/zenodo.22239360). (#9, @kelly-sovacool)
