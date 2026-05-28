ensure_saintexpress_docker_image <- function(image_name = "saintexpress:latest") {
  docker_path <- Sys.which("docker")
  if (!nzchar(docker_path)) {
    stop(
      "Docker is not installed or not in PATH. ",
      "Install Docker Desktop from https://www.docker.com/products/docker-desktop/"
    )
  }
  check <- system2("docker", args = c("image", "inspect", image_name),
                   stdout = FALSE, stderr = FALSE)
  if (check == 0) {
    message("Docker image '", image_name, "' found.")
    return(invisible(TRUE))
  }
  message("Building Docker image '", image_name, "' (one-time setup)...")
  build_dir <- file.path(tempdir(), "saintexpressbin_build")
  dir.create(build_dir, showWarnings = FALSE, recursive = TRUE)
  dockerfile_path <- .saintexpressbin_file("docker", "Dockerfile")
  bin_dir <- .saintexpressbin_file("bin", "Linux64")
  if (!nzchar(dockerfile_path) || !nzchar(bin_dir)) {
    stop("Docker resources not found in installed saintexpressbin package.")
  }
  file.copy(dockerfile_path, build_dir, overwrite = TRUE)
  file.copy(file.path(bin_dir, "SAINTexpress-spc"), build_dir, overwrite = TRUE)
  file.copy(file.path(bin_dir, "SAINTexpress-int"), build_dir, overwrite = TRUE)
  result <- system2("docker",
                    args = c("build", "--platform", "linux/amd64",
                             "-t", image_name, build_dir),
                    stdout = TRUE, stderr = TRUE)
  status <- attr(result, "status")
  if (!is.null(status) && status != 0) {
    stop("Failed to build Docker image. Is Docker Desktop running?\n",
         paste(result, collapse = "\n"))
  }
  message("Docker image '", image_name, "' built successfully.")
  invisible(TRUE)
}
