.write_saint_inputs <- function(si, workdir) {
  stopifnot(identical(names(si), c("inter", "prey", "bait")))
  paths <- character(3)
  for (i in seq_along(si)) {
    filen <- file.path(workdir, paste0(names(si)[i], ".txt"))
    paths[i] <- filen
    readr::write_tsv(si[[i]], file = filen, col_names = FALSE)
  }
  paths
}

.run_native <- function(exe, paths, workdir, sysname) {
  oldwd <- getwd()
  on.exit(setwd(oldwd), add = TRUE)
  setwd(workdir)
  args <- list(
    command = exe,
    args = paths,
    stdout = TRUE,
    stderr = TRUE,
    wait = TRUE
  )
  if (identical(sysname, "Windows")) {
    args$minimized <- TRUE
  }
  do.call(system2, args)
}

.run_docker <- function(
  binary_name,
  paths,
  workdir,
  image_name = "saintexpress:latest"
) {
  ensure_saintexpress_docker_image(image_name)
  container_dir <- "/data"
  container_paths <- file.path(container_dir, basename(paths))
  docker_args <- c(
    "run",
    "--rm",
    "--platform",
    "linux/amd64",
    "-v",
    paste0(workdir, ":", container_dir),
    "-w",
    container_dir,
    image_name,
    binary_name,
    container_paths
  )
  system2(
    "docker",
    args = docker_args,
    stdout = TRUE,
    stderr = TRUE,
    wait = TRUE
  )
}

#' Run SAINTexpress on prepared input
#'
#' Writes `inter.txt`, `prey.txt`, `bait.txt` into `workdir`, then runs the
#' bundled native binary, or Docker on macOS when no native binary is available
#' (or when `use_docker = TRUE`).
#'
#' @param si Named list with elements `inter`, `prey`, `bait` (data frames).
#' @param type `"spc"` (spectral counts) or `"int"` (intensities).
#' @param workdir Directory to write inputs and read `list.txt` from. Defaults
#'   to `getwd()`.
#' @param cleanup If `TRUE`, remove generated files after reading the results.
#' @param use_docker `NULL` (auto: native first, Docker fallback on macOS),
#'   `TRUE` to force Docker, or `FALSE` to require a native binary.
#' @return List with elements `listFile` (data frame with the path),
#'   `list` (the parsed `list.txt`), and `out` (data frame with the run log).
#' @examples
#' si <- list(
#'   inter = data.frame(
#'     ipId = c("IP1", "IP1", "IP2", "IP2", "IP3", "IP4"),
#'     baitId = c("BaitA", "BaitA", "BaitA", "BaitA", "Ctrl", "Ctrl"),
#'     preyId = c("Prey1", "Prey2", "Prey1", "Prey2", "Prey1", "Prey2"),
#'     quant = c(20, 1, 18, 1, 1, 1)
#'   ),
#'   prey = data.frame(
#'     preyId = c("Prey1", "Prey2"),
#'     preyLength = c(500, 500),
#'     preyGeneId = c("Gene1", "Gene2")
#'   ),
#'   bait = data.frame(
#'     ipId = c("IP1", "IP2", "IP3", "IP4"),
#'     baitId = c("BaitA", "BaitA", "Ctrl", "Ctrl"),
#'     CorT = c("T", "T", "C", "C")
#'   )
#' )
#' if (nzchar(saintexpress_executable("spc"))) {
#'   workdir <- tempfile("saintexpressbin-")
#'   dir.create(workdir)
#'   saintexpress_run(si, type = "spc", workdir = workdir, use_docker = FALSE)
#' }
#' @export
saintexpress_run <- function(si,
                             type = c("spc", "int"),
                             workdir = getwd(),
                             cleanup = TRUE,
                             use_docker = NULL) {
  type <- match.arg(type)
  stopifnot(is.list(si), identical(names(si), c("inter", "prey", "bait")))
  workdir <- normalizePath(workdir, mustWork = TRUE)
  paths <- .write_saint_inputs(si, workdir)

  sysname <- Sys.info()[["sysname"]]
  binary_name <- if (type == "spc") "SAINTexpress-spc" else "SAINTexpress-int"
  native_exe <- .saintexpress_executable(type, sysname = sysname)

  if (is.null(use_docker)) {
    use_docker <- identical(sysname, "Darwin") && !nzchar(native_exe)
  }

  if (use_docker) {
    out <- .run_docker(binary_name, paths, workdir)
  } else if (nzchar(native_exe)) {
    out <- .run_native(native_exe, paths, workdir, sysname)
  } else {
    stop(
      "No native ", binary_name, " for ", sysname, ". ",
      "Set use_docker = TRUE where Docker is supported, ",
      "or install a platform binary."
    )
  }
  listFile <- file.path(workdir, "list.txt")

  message(paste(out, collapse = "\n"))
  Sys.sleep(2)
  res <- utils::read.csv(file = listFile, sep = "\t")
  if (cleanup) {
    if (file.exists(listFile) && !file.remove(listFile)) {
      warning("can't remove ", listFile)
    }
    file.remove(paths)
  }
  list(
    listFile = data.frame(listFile = listFile),
    list = res,
    out = data.frame(out = out)
  )
}
