.binary_filename <- function(type, sysname) {
  base <- switch(type, spc = "SAINTexpress-spc", int = "SAINTexpress-int")
  if (identical(sysname, "Windows")) paste0(base, ".exe") else base
}

.platform_subdir <- function(sysname) {
  switch(sysname,
    Darwin = "Darwin",
    Linux = "Linux64",
    Windows = "Windows64",
    NA_character_
  )
}

.saintexpressbin_file <- function(...) {
  rel <- file.path(...)
  installed <- system.file(rel, package = "saintexpressbin")
  if (nzchar(installed)) {
    return(installed)
  }
  source_tree <- file.path(getwd(), "inst", rel)
  if (file.exists(source_tree)) {
    return(normalizePath(source_tree, mustWork = TRUE))
  }
  ""
}

.saintexpress_executable <- function(type, sysname = Sys.info()[["sysname"]]) {
  subdir <- .platform_subdir(sysname)
  if (is.na(subdir)) {
    return("")
  }
  path <- .saintexpressbin_file("bin", subdir, .binary_filename(type, sysname))
  if (!nzchar(path) || !file.exists(path)) {
    return("")
  }
  if (sysname != "Windows" && file.access(path, mode = 1) != 0) {
    return("")
  }
  path
}

#' Path to a shipped SAINTexpress executable
#'
#' @param type Either `"spc"` (spectral counts) or `"int"` (intensities).
#' @return Absolute path to the executable for the current platform, or `""` if
#'   no shipped binary matches.
#' @export
saintexpress_executable <- function(type = c("spc", "int")) {
  type <- match.arg(type)
  .saintexpress_executable(type)
}

#' Is SAINTexpress runnable on this machine?
#'
#' Returns `TRUE` if a native binary for the current platform is shipped, or if
#' Docker is available on macOS (the Docker image is built on first use).
#'
#' @param type Either `"spc"` or `"int"`.
#' @export
saintexpress_available <- function(type = c("spc", "int")) {
  type <- match.arg(type)
  if (nzchar(saintexpress_executable(type))) {
    return(TRUE)
  }
  sysname <- Sys.info()[["sysname"]]
  if (identical(sysname, "Darwin") && nzchar(Sys.which("docker"))) {
    return(TRUE)
  }
  FALSE
}
