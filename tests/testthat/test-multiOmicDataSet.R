test_that("constructing multiOmicDataSet from data frames works", {
  sample_meta <- data.frame(
    sample_id = c("S1", "S2"),
    condition = c("A", "B"),
    stringsAsFactors = FALSE
  )
  counts <- data.frame(
    gene_id = c("g1", "g2"),
    S1 = c(1, 3),
    S2 = c(2, 4),
    symbol = c("G1", "G2"),
    stringsAsFactors = FALSE
  )

  moo <- create_multiOmicDataSet_from_dataframes(
    sample_metadata = sample_meta,
    counts_dat = counts,
    sample_id_colname = "sample_id",
    feature_id_colname = "gene_id"
  )

  expect_true(S7::S7_inherits(moo, multiOmicDataSet))
  expect_equal(colnames(moo@counts$raw), c("gene_id", "S1", "S2"))
  expect_equal(colnames(moo@annotation), c("gene_id", "symbol"))
  expect_equal(length(moo@analyses), 0)
})

test_that("constructor validation errors are informative", {
  sample_meta <- data.frame(
    sample_id = c("S1", "S2"),
    stringsAsFactors = FALSE
  )
  counts <- data.frame(
    gene_id = c("g1", "g2"),
    S1 = c(1, 3),
    S2 = c(2, 4),
    stringsAsFactors = FALSE
  )

  expect_error(
    multiOmicDataSet(
      sample_metadata = sample_meta,
      anno_dat = data.frame(gene_id = c("g1", "g2")),
      counts_lst = list(clean = counts)
    ),
    "must contain at least 'raw' counts"
  )

  bad_counts <- counts
  colnames(bad_counts)[2] <- "X1"
  expect_error(
    multiOmicDataSet(
      sample_metadata = sample_meta,
      anno_dat = data.frame(gene_id = c("g1", "g2")),
      counts_lst = list(raw = bad_counts)
    ),
    "@sample_meta"
  )
})

test_that("extract_counts handles plain and nested counts", {
  sample_meta <- data.frame(sample_id = c("S1", "S2"), stringsAsFactors = FALSE)
  raw <- data.frame(gene_id = c("g1", "g2"), S1 = c(1, 2), S2 = c(3, 4))
  norm <- list(voom = raw)

  moo <- multiOmicDataSet(
    sample_metadata = sample_meta,
    anno_dat = data.frame(gene_id = c("g1", "g2"), stringsAsFactors = FALSE),
    counts_lst = list(raw = raw, norm = norm)
  )

  expect_equal(extract_counts(moo, "raw"), raw)
  expect_equal(extract_counts(moo, "norm", "voom"), raw)
  expect_error(extract_counts(moo, "norm"), "contains subtypes")
  expect_error(extract_counts(moo, "nope"), "not in moo@counts")
})

test_that("read and write rds round-trip", {
  sample_meta <- data.frame(sample_id = c("S1", "S2"), stringsAsFactors = FALSE)
  raw <- data.frame(gene_id = c("g1", "g2"), S1 = c(1, 2), S2 = c(3, 4))

  moo <- multiOmicDataSet(
    sample_metadata = sample_meta,
    anno_dat = data.frame(gene_id = c("g1", "g2"), stringsAsFactors = FALSE),
    counts_lst = list(raw = raw)
  )

  path <- withr::local_tempfile(fileext = ".rds")

  expect_equal(write_multiOmicDataSet(moo, path), path)
  restored <- read_multiOmicDataSet(path)
  expect_true(S7::S7_inherits(restored, multiOmicDataSet))
  expect_equal(restored@sample_meta, moo@sample_meta)
  expect_equal(restored@counts$raw, moo@counts$raw)
})

test_that("write_multiOmicDataSet_properties writes expected files", {
  sample_meta <- data.frame(sample_id = c("S1", "S2"), stringsAsFactors = FALSE)
  raw <- data.frame(gene_id = c("g1", "g2"), S1 = c(1, 2), S2 = c(3, 4))

  moo <- multiOmicDataSet(
    sample_metadata = sample_meta,
    anno_dat = data.frame(gene_id = c("g1", "g2"), stringsAsFactors = FALSE),
    counts_lst = list(raw = raw),
    analyses_lst = list(diff = data.frame(gene_id = c("g1"), p = 0.01))
  )

  out <- withr::local_tempdir(pattern = "moo-")

  expect_equal(write_multiOmicDataSet_properties(moo, out), out)
  expect_true(file.exists(file.path(out, "sample_metadata.csv")))
  expect_true(file.exists(file.path(out, "feature_annotation.csv")))
  expect_true(file.exists(file.path(out, "counts", "raw_counts.csv")))
  expect_true(file.exists(file.path(out, "analyses", "diff.csv")))
})

test_that("validator rejects unapproved count names", {
  sample_meta <- data.frame(sample_id = c("S1", "S2"), stringsAsFactors = FALSE)
  raw <- data.frame(gene_id = c("g1", "g2"), S1 = c(1, 2), S2 = c(3, 4))

  expect_error(
    multiOmicDataSet(
      sample_metadata = sample_meta,
      anno_dat = data.frame(gene_id = c("g1", "g2")),
      counts_lst = list(raw = raw, bogus = raw)
    ),
    "@counts can only contain these names"
  )
})

test_that("create_multiOmicDataSet_from_files works for TSV and CSV", {
  sample_meta <- data.frame(
    sample_id = c("S1", "S2"),
    condition = c("A", "B"),
    stringsAsFactors = FALSE
  )
  counts <- data.frame(
    gene_id = c("g1", "g2"),
    S1 = c(1, 3),
    S2 = c(2, 4),
    symbol = c("G1", "G2"),
    stringsAsFactors = FALSE
  )

  meta_path <- withr::local_tempfile(fileext = ".tsv")
  counts_path <- withr::local_tempfile(fileext = ".tsv")
  readr::write_tsv(sample_meta, meta_path)
  readr::write_tsv(counts, counts_path)

  moo <- create_multiOmicDataSet_from_files(
    sample_meta_filepath = meta_path,
    feature_counts_filepath = counts_path,
    sample_id_colname = "sample_id",
    feature_id_colname = "gene_id",
    delim = "\t"
  )

  expect_true(S7::S7_inherits(moo, multiOmicDataSet))
  expect_equal(colnames(moo@counts$raw), c("gene_id", "S1", "S2"))
  expect_equal(colnames(moo@annotation), c("gene_id", "symbol"))

  meta_path_csv <- withr::local_tempfile(fileext = ".csv")
  counts_path_csv <- withr::local_tempfile(fileext = ".csv")
  readr::write_csv(sample_meta, meta_path_csv)
  readr::write_csv(counts, counts_path_csv)

  moo_csv <- create_multiOmicDataSet_from_files(
    sample_meta_filepath = meta_path_csv,
    feature_counts_filepath = counts_path_csv,
    delim = ","
  )
  expect_true(S7::S7_inherits(moo_csv, multiOmicDataSet))
  expect_equal(names(moo_csv@counts), "raw")
})

test_that("from_dataframes uses default id cols, errors on missing samples", {
  sample_meta <- data.frame(
    sample_id = c("S1", "S2"),
    condition = c("A", "B"),
    stringsAsFactors = FALSE
  )
  counts <- data.frame(
    gene_id = c("g1", "g2"),
    S1 = c(1, 3),
    S2 = c(2, 4),
    stringsAsFactors = FALSE
  )

  # defaults: sample_id_colname & feature_id_colname NULL -> use first column
  moo <- create_multiOmicDataSet_from_dataframes(
    sample_metadata = sample_meta,
    counts_dat = counts
  )
  expect_equal(colnames(moo@counts$raw), c("gene_id", "S1", "S2"))

  sample_meta_missing <- data.frame(
    sample_id = c("S1", "S3"),
    condition = c("A", "B"),
    stringsAsFactors = FALSE
  )
  expect_error(
    create_multiOmicDataSet_from_dataframes(
      sample_metadata = sample_meta_missing,
      counts_dat = counts
    ),
    "Not all sample IDs in the sample metadata are in the count data"
  )
})

test_that("extract_counts errors on invalid sub_count_type", {
  sample_meta <- data.frame(sample_id = c("S1", "S2"), stringsAsFactors = FALSE)
  raw <- data.frame(gene_id = c("g1", "g2"), S1 = c(1, 2), S2 = c(3, 4))
  norm <- list(voom = raw)

  moo <- multiOmicDataSet(
    sample_metadata = sample_meta,
    anno_dat = data.frame(gene_id = c("g1", "g2"), stringsAsFactors = FALSE),
    counts_lst = list(raw = raw, norm = norm)
  )

  expect_error(
    extract_counts(moo, "raw", "not_a_subtype"),
    "does not contain subtypes"
  )
  expect_error(
    extract_counts(moo, "norm", "not_a_subtype"),
    "is not in moo@counts"
  )
})

test_that("write_multiOmicDataSet validates its input", {
  expect_error(
    write_multiOmicDataSet("not a moo"),
    "moo must be a multiOmicDataSet"
  )
})

test_that("read_multiOmicDataSet validates its input", {
  path <- withr::local_tempfile(fileext = ".rds")
  readr::write_rds(list(a = 1), path)

  expect_error(
    read_multiOmicDataSet(path),
    "RDS does not contain a multiOmicDataSet"
  )
})

test_that("read_multiOmicDataSet_properties round-trip (simple)", {
  sample_meta <- data.frame(sample_id = c("S1", "S2"), stringsAsFactors = FALSE)
  raw <- data.frame(gene_id = c("g1", "g2"), S1 = c(1, 2), S2 = c(3, 4))

  moo <- multiOmicDataSet(
    sample_metadata = sample_meta,
    anno_dat = data.frame(gene_id = c("g1", "g2"), stringsAsFactors = FALSE),
    counts_lst = list(raw = raw),
    analyses_lst = list(diff = data.frame(gene_id = c("g1"), p = 0.01))
  )

  out <- withr::local_tempdir(pattern = "moo-roundtrip-")
  write_multiOmicDataSet_properties(moo, out)
  restored <- read_multiOmicDataSet_properties(out)

  expect_true(S7::S7_inherits(restored, multiOmicDataSet))
  expect_equal(as.data.frame(restored@sample_meta), as.data.frame(moo@sample_meta))
  expect_equal(as.data.frame(restored@annotation), as.data.frame(moo@annotation))
  expect_equal(as.data.frame(restored@counts$raw), as.data.frame(moo@counts$raw))
  expect_equal(names(restored@analyses), names(moo@analyses))
})

test_that("read_multiOmicDataSet_properties round-trip (nested counts + analyses)", {
  sample_meta <- data.frame(sample_id = c("S1", "S2"), stringsAsFactors = FALSE)
  raw <- data.frame(gene_id = c("g1", "g2"), S1 = c(1, 2), S2 = c(3, 4))
  norm <- list(voom = raw)

  moo <- multiOmicDataSet(
    sample_metadata = sample_meta,
    anno_dat = data.frame(gene_id = c("g1", "g2"), stringsAsFactors = FALSE),
    counts_lst = list(raw = raw, norm = norm),
    analyses_lst = list(
      diff = data.frame(gene_id = c("g1"), p = 0.01),
      model = structure(list(x = 1), class = "some_model")
    )
  )

  out <- withr::local_tempdir(pattern = "moo-nested-rt-")
  write_multiOmicDataSet_properties(moo, out)
  restored <- read_multiOmicDataSet_properties(out)

  expect_true(S7::S7_inherits(restored, multiOmicDataSet))
  expect_equal(as.data.frame(restored@counts$raw), as.data.frame(moo@counts$raw))
  expect_true(is.list(restored@counts$norm))
  expect_equal(as.data.frame(restored@counts$norm$voom), as.data.frame(moo@counts$norm$voom))
  expect_equal(names(restored@analyses), names(moo@analyses))
  expect_equal(class(restored@analyses$model), class(moo@analyses$model))
})

test_that("write_multiOmicDataSet_properties writes nested counts + analyses", {
  sample_meta <- data.frame(sample_id = c("S1", "S2"), stringsAsFactors = FALSE)
  raw <- data.frame(gene_id = c("g1", "g2"), S1 = c(1, 2), S2 = c(3, 4))
  norm <- list(voom = raw)

  moo <- multiOmicDataSet(
    sample_metadata = sample_meta,
    anno_dat = data.frame(gene_id = c("g1", "g2"), stringsAsFactors = FALSE),
    counts_lst = list(raw = raw, norm = norm),
    analyses_lst = list(
      diff = data.frame(gene_id = c("g1"), p = 0.01),
      colors = list(condition = c(A = "red", B = "blue")),
      model = structure(list(x = 1), class = "some_model")
    )
  )

  out <- withr::local_tempdir(pattern = "moo-nested-")

  expect_equal(write_multiOmicDataSet_properties(moo, out), out)

  expect_true(file.exists(file.path(
    out,
    "counts",
    "norm",
    "voom_counts.csv"
  )))
  expect_true(file.exists(file.path(out, "analyses", "diff.csv")))
  expect_true(file.exists(file.path(
    out,
    "analyses",
    "colors",
    "colors_condition.rds"
  )))
  expect_true(file.exists(file.path(out, "analyses", "model.rds")))
})
