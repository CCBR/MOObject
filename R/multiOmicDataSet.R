#' multiOmicDataSet class
#'
#' @param sample_metadata sample metadata as a data frame. The first column is
#'   assumed to contain sample IDs that correspond to columns in raw counts.
#' @param anno_dat data frame of feature annotations.
#' @param counts_lst named list of count data frames. Each count data frame must
#'   have a feature ID column first and sample columns after.
#' @param analyses_lst named list of analysis results.
#'
#' @prop sample_meta sample metadata as a data frame.
#' @prop annotation feature annotation data frame.
#' @prop counts named list of counts data frames.
#' @prop analyses named list of analysis results.
#'
#' @returns A `multiOmicDataSet` S7 object.
#' @export
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

#' Construct a multiOmicDataSet object from data frames
#'
#' @inheritParams multiOmicDataSet
#' @param counts_dat data frame of feature counts.
#' @param sample_id_colname column in `sample_metadata` that contains sample IDs.
#'   If `NULL`, use the first column.
#' @param feature_id_colname column in `counts_dat` that contains feature IDs.
#'   If `NULL`, use the first column.
#' @param count_type type to assign the values of `counts_dat` to in `counts`.
#'
#' @returns A `multiOmicDataSet` object.
#' @export
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

#' Construct a multiOmicDataSet object from delimited files
#'
#' @inheritParams create_multiOmicDataSet_from_dataframes
#' @param sample_meta_filepath path to sample metadata file.
#' @param feature_counts_filepath path to feature counts file.
#' @param delim delimiter for `readr::read_delim()`.
#' @param ... additional arguments passed to `readr::read_delim()`.
#'
#' @returns A `multiOmicDataSet` object.
#' @export
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

#' Extract count data from a multiOmicDataSet
#'
#' @param moo multiOmicDataSet containing counts.
#' @param count_type count type in `moo@counts`.
#' @param sub_count_type subtype in `moo@counts[[count_type]]` when that entry is a list.
#'
#' @returns A data frame of counts.
#' @export
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

#' Write a multiOmicDataSet to disk as RDS
#'
#' @param moo multiOmicDataSet object to serialize.
#' @param filepath output path for RDS file.
#'
#' @returns Invisibly returns `filepath`.
#' @export
write_multiOmicDataSet <- function(moo, filepath = "moo.rds") {
  if (!inherits(moo, multiOmicDataSet)) {
    stop("moo must be a multiOmicDataSet")
  }
  readr::write_rds(moo, filepath)
  invisible(filepath)
}

#' Read a multiOmicDataSet from disk
#'
#' @param filepath path to an RDS file produced by [write_multiOmicDataSet()].
#'
#' @returns A `multiOmicDataSet` object.
#' @export
read_multiOmicDataSet <- function(filepath) {
  moo <- readr::read_rds(filepath)
  if (!inherits(moo, multiOmicDataSet)) {
    stop("RDS does not contain a multiOmicDataSet")
  }
  moo
}

#' Write multiOmicDataSet properties to disk
#'
#' @param moo multiOmicDataSet object to write.
#' @param output_dir output directory.
#'
#' @returns Invisibly returns `output_dir`.
#' @export
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
