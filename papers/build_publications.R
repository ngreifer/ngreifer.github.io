library(RefManageR)
library(yaml)

build_publications <- function(
    dois,
    your_family  = "Greifer",
    your_initial = "N",
    out_path     = "publications.yml",
    pause        = 0.5,
    max_retries  = 5
) {

  # ── Helpers ───────────────────────────────────────────────────────────────

  `%||%` <- function(a, b) if (!is.null(a)) a else b

  # Strip all BibEntry custom operators by unclassing down to a plain list.
  # unclass(bib) is a list of 1 (one entry); [[1]] gives its 12 fields.
  raw_data <- function(bib) unclass(bib)[[1]]

  # Safely extract a scalar character field from the raw list
  get_field <- function(bib, name) {
    val <- tryCatch(raw_data(bib)[[name]], error = function(e) NULL)
    if (is.null(val) || length(val) == 0) return(NA_character_)
    trimws(as.character(val[1]))
  }

  # Return the first non-NA, non-empty value across multiple field names
  coalesce_field <- function(bib, names) {
    for (nm in names) {
      val <- get_field(bib, nm)
      if (!is.na(val) && nchar(val) > 0) return(val)
    }
    NA_character_
  }

  fetch_one <- function(doi) {
    delay <- 2
    for (attempt in seq_len(max_retries)) {
      result <- tryCatch(
        GetBibEntryWithDOI(doi, temp.file   = tempfile(fileext = ".bib"),
                           delete.file = TRUE),
        error = function(e) {
          if (grepl("429|503", conditionMessage(e))) {
            message("    Rate limited, waiting ", delay, "s ",
                    "(attempt ", attempt, "/", max_retries, ")...")
            Sys.sleep(delay)
            delay <<- delay * 2
            NULL
          } else {
            stop(e)
          }
        }
      )
      if (!is.null(result)) return(result)
    }
    stop("Failed after ", max_retries, " attempts: ", doi)
  }

  format_authors <- function(bib, your_family, your_initial) {
    author_field <- tryCatch(raw_data(bib)[["author"]], error = function(e) NULL)
    if (is.null(author_field)) return("")

    persons <- unclass(author_field)
    if (length(persons) == 0) return("")

    formatted <- character(0)
    for (i in seq_along(persons)) {
      # Defensively handle both list and atomic vector person entries
      p_raw <- tryCatch(unclass(persons[[i]]), error = function(e) NULL)
      if (is.null(p_raw)) next

      # If unclass gives a list of length 1, descend one more level
      p <- if (is.list(p_raw) && length(p_raw) == 1) p_raw[[1]] else p_raw

      # p may now be a named list or a named character vector; handle both
      family_raw <- if (is.list(p)) p[["family"]] else p["family"]
      given      <- if (is.list(p)) p[["given"]]  else p["given"]

      # family may be a vector e.g. c("de", "Jong") — collapse to one string
      family <- if (!is.null(family_raw) && length(family_raw) > 0)
        paste(family_raw, collapse = " ")
      else
        NA_character_

      if (is.null(family) || length(family) == 0 ||
          is.na(family)   || nchar(trimws(family)) == 0) next

      if (!is.null(given) && length(given) > 0 &&
          !all(is.na(given)) && any(nchar(given) > 0)) {
        given    <- given[!is.na(given) & nchar(given) > 0]
        initials <- paste0(substr(given, 1, 1), ".", collapse = " ")
        fmt <- paste0(trimws(family), ", ", initials)
      } else {
        fmt <- trimws(family)
      }
      formatted <- c(formatted, fmt)
    }

    n <- length(formatted)
    if (n == 0) return("")

    formatted <- sapply(formatted, function(a) {
      if (grepl(your_family, a, ignore.case = TRUE) &&
          grepl(paste0("\\b", your_initial, "\\."), a))
        paste0("<strong>", a, "</strong>")
      else
        a
    }, USE.NAMES = FALSE)

    if (n == 1)  return(formatted)
    if (n <= 20) return(paste0(paste(formatted[-n], collapse = ", "),
                               ", & ", formatted[n]))
    paste0(paste(formatted[1:19], collapse = ", "), ", ... ", formatted[n])
  }

  format_entry <- function(bib, doi) {
    # bibtype lives on the entry (bib[[1]]), not on the field list (raw_data)
    bibtype <- tryCatch(
      tolower(attr(bib[[1]], "bibtype") %||% "misc"),
      error = function(e) "misc"
    )

    authors <- format_authors(bib, your_family, your_initial)

    # Year: avoid lubridate by extracting only the 4-digit year substring
    year_raw <- coalesce_field(bib, c("year", "date", "urldate"))
    year_str <- if (!is.na(year_raw)) {
      m <- regmatches(year_raw, regexpr("[0-9]{4}", year_raw))
      if (length(m) > 0) m else "n.d."
    } else "n.d."
    year_int <- suppressWarnings(as.integer(year_str))

    title <- get_field(bib, "title")
    if (!is.na(title)) title <- gsub("[.]+$", "", trimws(title))

    journal     <- coalesce_field(bib, c("journal", "journaltitle",
                                         "booktitle", "publisher"))
    journal_fmt <- if (!is.na(journal)) paste0("<em>", journal, "</em>") else ""

    volume <- get_field(bib, "volume")
    number <- get_field(bib, "number")
    pages  <- get_field(bib, "pages")

    vol_str <- if (!is.na(volume)) {
      if (!is.na(number)) paste0("<em>", volume, "</em>(", number, ")")
      else                paste0("<em>", volume, "</em>")
    } else ""

    page_str <- if (!is.na(pages)) pages else ""
    vol_page  <- paste(Filter(nchar, c(vol_str, page_str)), collapse = ", ")

    source_part <- if (nchar(journal_fmt) > 0 && nchar(vol_page) > 0)
      paste0(journal_fmt, ", ", vol_page, ".")
    else if (nchar(journal_fmt) > 0)
      paste0(journal_fmt, ".")
    else if (bibtype %in% c("misc", "online") ||
             grepl("arxiv", doi, ignore.case = TRUE))
      "Manuscript submitted for publication."
    else
      ""

    parts <- Filter(nchar, c(
      paste0(authors, " (", year_str, ")."),
      if (!is.na(title)) paste0(title, ".") else NULL,
      source_part
    ))

    list(
      title    = doi,
      citation = paste(parts, collapse = " "),
      doi      = doi,
      link     = paste0("https://doi.org/", doi),
      year     = year_int
    )
  }

  # ── Load existing cache ────────────────────────────────────────────────────
  existing <- list()
  if (file.exists(out_path)) {
    raw <- tryCatch(yaml.load_file(out_path), error = function(e) list())
    if (length(raw) > 0) {
      existing <- setNames(raw, tolower(sapply(raw, `[[`, "doi")))
      message("Loaded ", length(existing), " cached entry/entries.")
    }
  }

  # ── Identify new DOIs ──────────────────────────────────────────────────────
  new_dois <- dois[!tolower(dois) %in% names(existing)]
  if (length(new_dois) == 0) {
    message("All DOIs already cached. Nothing to fetch.")
  } else {
    message(length(new_dois), " new DOI(s) to fetch.")
  }

  # ── Fetch and format ───────────────────────────────────────────────────────
  new_entries <- list()
  for (doi in new_dois) {
    message("  Fetching: ", doi)
    bib <- tryCatch(
      fetch_one(doi),
      error = function(e) {
        message("  ERROR fetching '", doi, "': ", e$message); NULL
      }
    )
    if (!is.null(bib)) {
      entry <- tryCatch(
        format_entry(bib, doi),
        error = function(e) {
          message("  ERROR formatting '", doi, "': ", e$message); NULL
        }
      )
      if (!is.null(entry)) new_entries[[tolower(doi)]] <- entry
    }
    Sys.sleep(pause)
  }

  # ── Merge, prune, sort, write ──────────────────────────────────────────────
  all_entries <- c(existing, new_entries)
  all_entries <- all_entries[!duplicated(names(all_entries))]
  all_entries <- all_entries[names(all_entries) %in% tolower(dois)]

  if (length(all_entries) == 0) stop("No entries to write.")

  all_entries <- all_entries[order(
    -sapply(all_entries, function(x) if (is.na(x$year)) 0L else x$year),
    sapply(all_entries, `[[`, "citation")
  )]

  write_yaml(unname(all_entries), out_path)
  message("Written ", length(all_entries), " entry/entries to ", out_path)
  invisible(all_entries)
}
