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

  path <- tempfile(fileext = ".rds")
  on.exit(unlink(path), add = TRUE)

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

  out <- tempfile(pattern = "moo-")
  on.exit(unlink(out, recursive = TRUE), add = TRUE)

  expect_equal(write_multiOmicDataSet_properties(moo, out), out)
  expect_true(file.exists(file.path(out, "sample_metadata.csv")))
  expect_true(file.exists(file.path(out, "feature_annotation.csv")))
  expect_true(file.exists(file.path(out, "counts", "raw_counts.csv")))
  expect_true(file.exists(file.path(out, "analyses", "diff.csv")))
})
