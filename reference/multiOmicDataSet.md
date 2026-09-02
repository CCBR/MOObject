# multiOmicDataSet class

multiOmicDataSet class

## Usage

``` r
multiOmicDataSet(sample_metadata, anno_dat, counts_lst, analyses_lst = list())
```

## Arguments

- sample_metadata:

  sample metadata as a data frame or tibble. The first column is assumed
  to contain the sample IDs which must correspond to column names in the
  raw counts.

- anno_dat:

  data frame of feature annotations, such as gene symbols or any other
  information about the features in `counts_lst`.

- counts_lst:

  named list of data frames containing counts, e.g. expected feature
  counts from RSEM. Each data frame is expected to contain a
  `feature_id` column as the first column, and all remaining columns are
  sample IDs in the `sample_meta`.

- analyses_lst:

  named list of analysis results, e.g. DESeq results object

## Value

A multiOmicDataSet S7 object.

## See also

Other moo:
[`create_multiOmicDataSet_from_dataframes()`](https://ccbr.github.io/MOObject/reference/create_multiOmicDataSet_from_dataframes.md),
[`create_multiOmicDataSet_from_files()`](https://ccbr.github.io/MOObject/reference/create_multiOmicDataSet_from_files.md),
[`extract_counts()`](https://ccbr.github.io/MOObject/reference/extract_counts.md),
[`read_multiOmicDataSet()`](https://ccbr.github.io/MOObject/reference/read_multiOmicDataSet.md),
[`read_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/reference/read_multiOmicDataSet_properties.md),
[`write_multiOmicDataSet()`](https://ccbr.github.io/MOObject/reference/write_multiOmicDataSet.md),
[`write_multiOmicDataSet_properties()`](https://ccbr.github.io/MOObject/reference/write_multiOmicDataSet_properties.md)

## Additional properties

- `@sample_meta`:

  sample metadata as a data frame or tibble. The first column is assumed
  to contain the sample IDs which must correspond to column names in the
  raw counts.

- `@counts`:

  named list of counts data frames (e.g. `raw`, `clean`, `cpm`, `filt`,
  `norm`, `batch`). Each data frame is expected to contain a feature ID
  column as the first column, and all remaining columns are sample IDs.

- `@annotation`:

  data frame of feature annotations, such as gene symbols or any other
  information about the features in the counts list.

- `@analyses`:

  named list of analysis results (e.g. DESeq2 results, colors).

## Examples

``` r
# sample metadata (sample names, labels, groups, batches, etc.)
sample_metadata <- data.frame(sample_id = c("s1", "s2"), group = c("A", "B"))
# counts data such as from bulk RNA-seq
counts_dat <- data.frame(
  feature_id = c("gene1", "gene2"),
  s1 = c(10, 20),
  s2 = c(15, 25)
)
# annotations for the counts data such as alternative gene names, gene IDs, etc.
anno_dat <- data.frame(feature_id = c("gene1", "gene2"), ensembl_id = c('ENSG000001', 'ENSG000002'))

# construct a multiOmicDataSet object
moo <- multiOmicDataSet(
  sample_metadata = sample_metadata,
  counts_lst = list(raw = counts_dat),
  anno_dat = anno_dat
)
moo
#> <MOObject::multiOmicDataSet>
#>  @ sample_meta:'data.frame': 2 obs. of  2 variables:
#>  .. $ sample_id: chr  "s1" "s2"
#>  .. $ group    : chr  "A" "B"
#>  @ counts     :List of 1
#>  .. $ raw:'data.frame':  2 obs. of  3 variables:
#>  ..  ..$ feature_id: chr [1:2] "gene1" "gene2"
#>  ..  ..$ s1        : num [1:2] 10 20
#>  ..  ..$ s2        : num [1:2] 15 25
#>  @ annotation :'data.frame': 2 obs. of  2 variables:
#>  .. $ feature_id: chr  "gene1" "gene2"
#>  .. $ ensembl_id: chr  "ENSG000001" "ENSG000002"
#>  @ analyses   : list()
S7::S7_class(moo)
#> <MOObject::multiOmicDataSet> class
#> @ parent     : <S7_object>
#> @ constructor: function(sample_metadata, anno_dat, counts_lst, analyses_lst) {...}
#> @ validator  : function(self) {...}
#> @ properties :
#>  $ sample_meta: S3<data.frame>
#>  $ counts     : <list>        
#>  $ annotation : S3<data.frame>
#>  $ analyses   : <list>        

# validate the object
S7::validate(moo)

# Retrieve properties from the object
head(moo@sample_meta)
#>   sample_id group
#> 1        s1     A
#> 2        s2     B
# Set properties in the object
moo@sample_meta$batch <- c("C", "D")
```
