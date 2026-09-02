#' multiOmicDataSet class
#'
#' @param sample_metadata sample metadata as a data frame or tibble. The first column is assumed to contain the sample
#'   IDs which must correspond to column names in the raw counts.
#' @param anno_dat data frame of feature annotations, such as gene symbols or any other information about the features
#'   in `counts_lst`.
#' @param counts_lst named list of data frames containing counts, e.g. expected feature counts from RSEM. Each data
#'   frame is expected to contain a `feature_id` column as the first column, and all remaining columns are sample IDs in
#'   the `sample_meta`.
#' @param analyses_lst named list of analysis results, e.g. DESeq results object
#'
#' @prop sample_meta sample metadata as a data frame or tibble. The first column is assumed to contain the sample
#'   IDs which must correspond to column names in the raw counts.
#' @prop annotation data frame of feature annotations, such as gene symbols or any other information about the
#'   features in the counts list.
#' @prop counts named list of counts data frames (e.g. `raw`, `clean`, `cpm`, `filt`, `norm`, `batch`). Each data
#'   frame is expected to contain a feature ID column as the first column, and all remaining columns are sample IDs.
#' @prop analyses named list of analysis results (e.g. DESeq2 results, colors).
#'
#' @returns A [multiOmicDataSet] S7 object.
#' @export
#' @family moo
#' @examples
#' sample_metadata <- data.frame(sample_id = c("s1", "s2"), group = c("A", "B"))
#' anno_dat <- data.frame(feature_id = c("gene1", "gene2"))
#' counts_dat <- data.frame(
#'   feature_id = c("gene1", "gene2"),
#'   s1 = c(10, 20),
#'   s2 = c(15, 25)
#' )
#' moo <- multiOmicDataSet(
#'   sample_metadata = sample_metadata,
#'   anno_dat = anno_dat,
#'   counts_lst = list(raw = counts_dat)
#' )
#' moo
multiOmicDataSet <- S7::new_class(
  name = "multiOmicDataSet",
  package = "MOObject",
  properties = list(
    sample_meta = S7::class_data.frame,
    annotation = S7::class_data.frame,
    counts = S7::class_list,
    analyses = S7::class_list
  ),
  constructor = function(
    sample_metadata,
    anno_dat,
    counts_lst,
    analyses_lst = list()
  ) {
    S7::new_object(
      S7::S7_object(),
      sample_meta = sample_metadata,
      annotation = anno_dat,
      counts = counts_lst,
      analyses = analyses_lst
    )
  },
  validator = function(self) {
    errors <- character(0)
    approved_counts <- c("raw", "clean", "cpm", "filt", "norm", "batch")

    if (!all(names(self@counts) %in% approved_counts)) {
      errors <- c(
        errors,
        glue::glue(
          "@counts can only contain these names:\n\t{paste(approved_counts, collapse = ', ')}"
        )
      )
    }

    if (!("raw" %in% names(self@counts))) {
      errors <- c(errors, "@counts must contain at least 'raw' counts")
    } else {
      meta_sample_ids <- as.character(self@sample_meta[[1]])
      feature_sample_ids <- colnames(self@counts$raw)[-1]

      in_meta_not_in_counts <- setdiff(meta_sample_ids, feature_sample_ids)
      if (length(in_meta_not_in_counts) > 0) {
        errors <- c(
          errors,
          glue::glue(
            "Not all sample IDs in the @sample_meta are in the @counts$raw data:\n\t",
            "{glue::glue_collapse(in_meta_not_in_counts, sep = ', ')}"
          )
        )
      }

      in_counts_not_in_meta <- setdiff(feature_sample_ids, meta_sample_ids)
      if (length(in_counts_not_in_meta) > 0) {
        errors <- c(
          errors,
          glue::glue(
            "Not all columns after the first column in @counts$raw are sample IDs in @sample_meta:\n\t",
            "{glue::glue_collapse(in_counts_not_in_meta, sep = ', ')}"
          )
        )
      }

      if (!identical(feature_sample_ids, meta_sample_ids)) {
        errors <- c(
          errors,
          "The sample IDs in @sample_meta must be in the same order as columns in @counts$raw"
        )
      }
    }

    output <- NULL
    if (length(errors) > 0) {
      output <- errors
    }
    output
  }
)

#' Construct a multiOmicDataSet object from text files (e.g. TSV, CSV).
#'
#' @inheritParams create_multiOmicDataSet_from_dataframes
#' @param sample_meta_filepath path to text file with sample IDs and metadata for differential analysis.
#' @param feature_counts_filepath path to text file of expected feature counts (e.g. gene counts from RSEM).
#' @param delim Delimiter used in the input files. Any delimiter accepted by `readr::read_delim()` can be used.
#'   If the files are in CSV format, set `delim = ','`; for TSV format, set `delim = '\t'`.
#' @param ... additional arguments forwarded to `readr::read_delim()`.
#'
#' @returns A [multiOmicDataSet] object.
#' @export
#' @family moo
#' @examples
#' sample_meta_dat <- data.frame(sample_id = c("s1", "s2"), group = c("A", "B"))
#' feature_counts_dat <- data.frame(
#'   feature_id = c("gene1", "gene2"),
#'   s1 = c(10, 20),
#'   s2 = c(15, 25)
#' )
#' sample_meta_filepath <- tempfile(fileext = ".csv")
#' feature_counts_filepath <- tempfile(fileext = ".csv")
#' readr::write_csv(sample_meta_dat, sample_meta_filepath)
#' readr::write_csv(feature_counts_dat, feature_counts_filepath)
#'
#' moo <- create_multiOmicDataSet_from_files(
#'   sample_meta_filepath = sample_meta_filepath,
#'   feature_counts_filepath = feature_counts_filepath,
#'   delim = ","
#' )
#' head(moo@sample_meta)
#' head(moo@counts[['raw']])
#'
create_multiOmicDataSet_from_files <- function(
  sample_meta_filepath,
  feature_counts_filepath,
  count_type = "raw",
  sample_id_colname = NULL,
  feature_id_colname = NULL,
  delim = NULL,
  ...
) {
  counts_dat <- readr::read_delim(feature_counts_filepath, delim = delim, ...)
  sample_metadata <- readr::read_delim(sample_meta_filepath, delim = delim, ...)

  create_multiOmicDataSet_from_dataframes(
    sample_metadata = sample_metadata,
    counts_dat = counts_dat,
    sample_id_colname = sample_id_colname,
    feature_id_colname = feature_id_colname,
    count_type = count_type
  )
}

#' Construct a multiOmicDataSet object from data frames
#'
#' @inheritParams multiOmicDataSet
#' @param counts_dat data frame of feature counts (e.g. expected feature counts from RSEM).
#' @param sample_id_colname name of the column in `sample_metadata` that contains the sample IDs. (Default: `NULL` -
#'   first column in the sample metadata will be used.)
#' @param feature_id_colname name of the column in `counts_dat` that contains feature/gene IDs. (Default: `NULL` - first
#'   column in the count data will be used.)
#' @param count_type type to assign the values of `counts_dat` to in the `counts` slot
#'
#' @returns A [multiOmicDataSet] object.
#' @export
#' @family moo
#' @examples
#'
#' sample_meta_dat <- data.frame(sample_id = c("s1", "s2"), group = c("A", "B"))
#' feature_counts_dat <- data.frame(
#'   feature_id = c("gene1", "gene2"),
#'   s1 = c(10, 20),
#'   s2 = c(15, 25)
#' )
#' moo <- create_multiOmicDataSet_from_dataframes(
#'   sample_metadata = sample_meta_dat,
#'   counts_dat = feature_counts_dat
#' )
#' head(moo@sample_meta)
#' head(moo@counts[['raw']])
#'
create_multiOmicDataSet_from_dataframes <- function(
  sample_metadata,
  counts_dat,
  sample_id_colname = NULL,
  feature_id_colname = NULL,
  count_type = "raw"
) {
  if (is.null(sample_id_colname)) {
    sample_id_colname <- colnames(sample_metadata)[1]
  }
  if (is.null(feature_id_colname)) {
    feature_id_colname <- colnames(counts_dat)[1]
  }

  meta_sample_ids <- as.character(sample_metadata[[sample_id_colname]])
  missing_sample_ids <- meta_sample_ids[
    !(meta_sample_ids %in% colnames(counts_dat))
  ]
  if (length(missing_sample_ids) > 0) {
    stop(
      glue::glue(
        "Not all sample IDs in the sample metadata are in the count data. Samples missing in count data:\n\t",
        "{glue::glue_collapse(missing_sample_ids, sep = ', ')}"
      )
    )
  }

  non_sample_cols <- setdiff(colnames(counts_dat), meta_sample_ids)
  anno_dat <- counts_dat[, non_sample_cols, drop = FALSE]
  counts_order <- c(feature_id_colname, meta_sample_ids)
  counts_trimmed <- counts_dat[, counts_order, drop = FALSE]

  counts <- list()
  counts[[count_type]] <- counts_trimmed

  multiOmicDataSet(
    sample_metadata = sample_metadata,
    anno_dat = anno_dat,
    counts_lst = counts
  )
}


#' Write a multiOmicDataSet to RDS
#'
#' @param moo [multiOmicDataSet] object to serialize
#' @param filepath Path to the RDS file to write (default: "moo.rds")
#'
#' @returns Invisibly returns `filepath`.
#' @export
#' @family moo
#' @examples
#' sample_metadata <- data.frame(sample_id = c("s1", "s2"), group = c("A", "B"))
#' counts_dat <- data.frame(
#'   feature_id = c("gene1", "gene2"),
#'   s1 = c(10, 20),
#'   s2 = c(15, 25)
#' )
#' moo <- create_multiOmicDataSet_from_dataframes(sample_metadata, counts_dat)
#' filepath <- tempfile(fileext = ".rds")
#' write_multiOmicDataSet(moo, filepath)
write_multiOmicDataSet <- function(moo, filepath = "moo.rds") {
  if (!inherits(moo, multiOmicDataSet)) {
    stop("moo must be a multiOmicDataSet")
  }
  readr::write_rds(moo, filepath)
  invisible(filepath)
}

#' Read a multiOmicDataSet from RDS
#'
#' @param filepath Path to an RDS file produced by [write_multiOmicDataSet()]
#'
#' @returns A [multiOmicDataSet] object.
#' @export
#' @family moo
#' @examples
#' sample_metadata <- data.frame(sample_id = c("s1", "s2"), group = c("A", "B"))
#' counts_dat <- data.frame(
#'   feature_id = c("gene1", "gene2"),
#'   s1 = c(10, 20),
#'   s2 = c(15, 25)
#' )
#' moo <- create_multiOmicDataSet_from_dataframes(sample_metadata, counts_dat)
#' filepath <- tempfile(fileext = ".rds")
#' write_multiOmicDataSet(moo, filepath)
#' moo2 <- read_multiOmicDataSet(filepath)
read_multiOmicDataSet <- function(filepath) {
  moo <- readr::read_rds(filepath)
  if (!inherits(moo, multiOmicDataSet)) {
    stop("RDS does not contain a multiOmicDataSet")
  }
  moo
}

#' Write multiOmicDataSet properties to individual files.
#'
#' The `sample_meta` and `annotation` properties are written to CSV files, the
#' `counts` property is written to a subdirectory of CSV files, and the
#' `analyses` property is written to a subdirectory of CSV or RDS files
#' depending on the type of each analysis result.
#'
#' @param moo [multiOmicDataSet] object to write properties from
#' @param output_dir Directory where the properties will be saved (default: "moo")
#'
#' @returns Invisibly returns `output_dir`.
#' @export
#' @family moo
#' @examples
#' sample_metadata <- data.frame(sample_id = c("s1", "s2"), group = c("A", "B"))
#' counts_dat <- data.frame(
#'   feature_id = c("gene1", "gene2"),
#'   s1 = c(10, 20),
#'   s2 = c(15, 25)
#' )
#' moo <- create_multiOmicDataSet_from_dataframes(sample_metadata, counts_dat)
#' output_dir <- tempfile()
#' write_multiOmicDataSet_properties(moo, output_dir)
write_multiOmicDataSet_properties <- S7::new_generic(
  name = "write_multiOmicDataSet_properties",
  dispatch_args = "moo",
  fun = function(moo, output_dir = "moo") {
    S7::S7_dispatch()
  }
)

#' @rdname write_multiOmicDataSet_properties
S7::method(write_multiOmicDataSet_properties, multiOmicDataSet) <- function(
  moo,
  output_dir = "moo"
) {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  readr::write_csv(
    moo@sample_meta,
    file = file.path(output_dir, "sample_metadata.csv")
  )
  readr::write_csv(
    moo@annotation,
    file = file.path(output_dir, "feature_annotation.csv")
  )

  counts_dir <- file.path(output_dir, "counts")
  if (!dir.exists(counts_dir)) {
    dir.create(counts_dir)
  }

  for (count_type in names(moo@counts)) {
    counts_dat <- moo@counts[[count_type]]
    if (inherits(counts_dat, "list")) {
      sub_counts_dir <- file.path(counts_dir, count_type)
      if (!dir.exists(sub_counts_dir)) {
        dir.create(sub_counts_dir)
      }
      for (sub_count_type in names(counts_dat)) {
        readr::write_csv(
          counts_dat[[sub_count_type]],
          file = file.path(
            sub_counts_dir,
            paste0(sub_count_type, "_counts.csv")
          )
        )
      }
    } else {
      readr::write_csv(
        counts_dat,
        file = file.path(counts_dir, paste0(count_type, "_counts.csv"))
      )
    }
  }

  analyses_dir <- file.path(output_dir, "analyses")
  if (!dir.exists(analyses_dir)) {
    dir.create(analyses_dir)
  }

  for (analysis_name in names(moo@analyses)) {
    analysis_dat <- moo@analyses[[analysis_name]]
    if (inherits(analysis_dat, "data.frame")) {
      readr::write_csv(
        analysis_dat,
        file = file.path(analyses_dir, paste0(analysis_name, ".csv"))
      )
    } else if (inherits(analysis_dat, "list")) {
      sub_analysis_dir <- file.path(analyses_dir, analysis_name)
      if (!dir.exists(sub_analysis_dir)) {
        dir.create(sub_analysis_dir)
      }
      for (sub_analysis_name in names(analysis_dat)) {
        sub_obj <- analysis_dat[[sub_analysis_name]]
        if (inherits(sub_obj, "data.frame")) {
          readr::write_csv(
            sub_obj,
            file = file.path(
              sub_analysis_dir,
              paste0(analysis_name, "_", sub_analysis_name, ".csv")
            )
          )
        } else {
          saveRDS(
            sub_obj,
            file = file.path(
              sub_analysis_dir,
              paste0(analysis_name, "_", sub_analysis_name, ".rds")
            )
          )
        }
      }
    } else {
      saveRDS(
        analysis_dat,
        file = file.path(analyses_dir, paste0(analysis_name, ".rds"))
      )
    }
  }

  invisible(output_dir)
}

#' Read multiOmicDataSet properties from individual files.
#'
#' Reads a directory created by [write_multiOmicDataSet_properties()] and
#' reconstructs the [multiOmicDataSet] object.  The `sample_meta` and
#' `annotation` properties are read from CSV files, the `counts` property is
#' read from the `counts/` subdirectory, and the `analyses` property is read
#' from the `analyses/` subdirectory.
#'
#' @param input_dir Directory previously created by
#'   [write_multiOmicDataSet_properties()].
#'
#' @returns A [multiOmicDataSet] object.
#' @export
#' @family moo
#' @examples
#' sample_metadata <- data.frame(sample_id = c("s1", "s2"), group = c("A", "B"))
#' counts_dat <- data.frame(
#'   feature_id = c("gene1", "gene2"),
#'   s1 = c(10, 20),
#'   s2 = c(15, 25)
#' )
#' moo <- create_multiOmicDataSet_from_dataframes(sample_metadata, counts_dat)
#' output_dir <- tempfile()
#' write_multiOmicDataSet_properties(moo, output_dir)
#' moo2 <- read_multiOmicDataSet_properties(output_dir)
read_multiOmicDataSet_properties <- function(input_dir) {
  sample_meta <- readr::read_csv(
    file.path(input_dir, "sample_metadata.csv"),
    show_col_types = FALSE
  )
  annotation <- readr::read_csv(
    file.path(input_dir, "feature_annotation.csv"),
    show_col_types = FALSE
  )

  counts_dir <- file.path(input_dir, "counts")
  counts_lst <- read_counts_dir_(counts_dir)

  analyses_dir <- file.path(input_dir, "analyses")
  analyses_lst <- read_analyses_dir_(analyses_dir)

  multiOmicDataSet(
    sample_metadata = as.data.frame(sample_meta),
    anno_dat = as.data.frame(annotation),
    counts_lst = counts_lst,
    analyses_lst = analyses_lst
  )
}

#' Read counts from a directory written by write_multiOmicDataSet_properties
#'
#' @param counts_dir Path to the `counts/` subdirectory.
#'
#' @returns A named list of data frames (and nested lists for sub-count types).
#' @keywords internal
read_counts_dir_ <- function(counts_dir) {
  counts_lst <- list()

  if (!dir.exists(counts_dir)) {
    return(counts_lst)
  }

  entries <- list.files(counts_dir, full.names = FALSE)
  for (entry in entries) {
    full_path <- file.path(counts_dir, entry)
    if (dir.exists(full_path)) {
      count_type <- entry
      sub_files <- list.files(full_path, pattern = "\\.csv$", full.names = TRUE)
      sub_lst <- list()
      for (sf in sub_files) {
        sub_name <- sub("_counts\\.csv$", "", basename(sf))
        sub_lst[[sub_name]] <- as.data.frame(
          readr::read_csv(sf, show_col_types = FALSE)
        )
      }
      counts_lst[[count_type]] <- sub_lst
    } else if (grepl("_counts\\.csv$", entry)) {
      count_type <- sub("_counts\\.csv$", "", entry)
      counts_lst[[count_type]] <- as.data.frame(
        readr::read_csv(full_path, show_col_types = FALSE)
      )
    }
  }

  counts_lst
}

#' Read analyses from a directory written by write_multiOmicDataSet_properties
#'
#' @param analyses_dir Path to the `analyses/` subdirectory.
#'
#' @returns A named list of data frames, lists, or arbitrary R objects.
#' @keywords internal
read_analyses_dir_ <- function(analyses_dir) {
  analyses_lst <- list()

  if (!dir.exists(analyses_dir)) {
    return(analyses_lst)
  }

  entries <- list.files(analyses_dir, full.names = FALSE)
  for (entry in entries) {
    full_path <- file.path(analyses_dir, entry)
    if (dir.exists(full_path)) {
      analysis_name <- entry
      sub_files <- list.files(full_path, full.names = TRUE)
      sub_lst <- list()
      for (sf in sub_files) {
        sf_base <- basename(sf)
        prefix <- paste0(analysis_name, "_")
        if (grepl("\\.csv$", sf_base)) {
          sub_name <- sub("\\.csv$", "", sub(paste0("^", prefix), "", sf_base))
          sub_lst[[sub_name]] <- as.data.frame(
            readr::read_csv(sf, show_col_types = FALSE)
          )
        } else if (grepl("\\.rds$", sf_base)) {
          sub_name <- sub("\\.rds$", "", sub(paste0("^", prefix), "", sf_base))
          sub_lst[[sub_name]] <- readRDS(sf)
        }
      }
      analyses_lst[[analysis_name]] <- sub_lst
    } else if (grepl("\\.csv$", entry)) {
      analysis_name <- sub("\\.csv$", "", entry)
      analyses_lst[[analysis_name]] <- as.data.frame(
        readr::read_csv(full_path, show_col_types = FALSE)
      )
    } else if (grepl("\\.rds$", entry)) {
      analysis_name <- sub("\\.rds$", "", entry)
      analyses_lst[[analysis_name]] <- readRDS(full_path)
    }
  }

  analyses_lst
}

#' Extract count data
#'
#' @param moo multiOmicDataSet containing `count_type` & `sub_count_type` in the counts slot
#' @param count_type the type of counts to use -- must be a name in the counts slot (`moo@counts[[count_type]]`)
#' @param sub_count_type if `count_type` is a list, specify the sub count type within the list
#'   (`moo@counts[[count_type]][[sub_count_type]]`). (Default: `NULL`)
#'
#' @returns A data frame of counts.
#' @export
#' @family moo
#' @examples
#' sample_metadata <- data.frame(sample_id = c("s1", "s2"), group = c("A", "B"))
#' counts_dat <- data.frame(
#'   feature_id = c("gene1", "gene2"),
#'   s1 = c(10, 20),
#'   s2 = c(15, 25)
#' )
#' moo <- create_multiOmicDataSet_from_dataframes(sample_metadata, counts_dat)
#' extract_counts(moo, "raw")
extract_counts <- S7::new_generic(
  name = "extract_counts",
  dispatch_args = "moo",
  fun = function(moo, count_type, sub_count_type = NULL) {
    S7::S7_dispatch()
  }
)

#' @rdname extract_counts
S7::method(extract_counts, multiOmicDataSet) <- function(
  moo,
  count_type,
  sub_count_type = NULL
) {
  if (!(count_type %in% names(moo@counts))) {
    stop(
      glue::glue(
        "count_type {count_type} not in moo@counts. Count types: {glue::glue_collapse(names(moo@counts), sep = ', ')}"
      )
    )
  }

  counts_dat <- moo@counts[[count_type]]

  if (!is.null(sub_count_type)) {
    if (!inherits(counts_dat, "list")) {
      stop(
        glue::glue(
          "{count_type} counts does not contain subtypes. Set sub_count_type to NULL"
        )
      )
    }
    if (!(sub_count_type %in% names(counts_dat))) {
      stop(
        glue::glue(
          "sub_count_type {sub_count_type} is not in moo@counts[[{count_type}]]"
        )
      )
    }
    counts_dat <- counts_dat[[sub_count_type]]
  } else if (inherits(counts_dat, "list")) {
    stop(
      glue::glue(
        "{count_type} counts contains subtypes. Set sub_count_type to extract one"
      )
    )
  }

  counts_dat
}
