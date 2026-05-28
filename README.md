# saintexpressbin

`saintexpressbin` ships SAINTexpress native executables and provides a small R
runner for prepared SAINT input data.

This package owns native execution details: resolving the platform-specific
binary, writing SAINT input files, running the native executable or Docker,
reading `list.txt`, and cleaning up generated files. It does not prepare
prolfqua data objects; that integration belongs in
[`prolfquasaint`](https://github.com/prolfqua/prolfquasaint). For the pure-R
implementation of the same scoring, see
[`saintexpress`](https://github.com/prolfqua/saintexpress).

## Installation

```r
# install.packages("remotes")
remotes::install_github("prolfqua/saintexpressbin")
```

## Binaries

The package expects binaries in this layout:

```text
inst/bin/Darwin/SAINTexpress-spc
inst/bin/Darwin/SAINTexpress-int
inst/bin/Linux64/SAINTexpress-spc
inst/bin/Linux64/SAINTexpress-int
inst/bin/Windows64/SAINTexpress-spc.exe
inst/bin/Windows64/SAINTexpress-int.exe
```

Unix binaries must be executable in the package source and after installation.

## Availability

Check whether a native executable, or the macOS Docker fallback, is available:

```r
saintexpressbin::saintexpress_available("spc")
saintexpressbin::saintexpress_available("int")
```

Get the executable path for the current platform:

```r
saintexpressbin::saintexpress_executable("spc")
saintexpressbin::saintexpress_executable("int")
```

The function returns `""` when no matching native executable is available.

## Running SAINTexpress

Prepare a SAINT input list with data frames named `inter`, `prey`, and `bait`:

```r
si <- list(
  inter = inter,
  prey = prey,
  bait = bait
)
```

Run the spectral-count binary:

```r
result <- saintexpressbin::saintexpress_run(si, type = "spc")
```

Run the intensity binary:

```r
result <- saintexpressbin::saintexpress_run(si, type = "int")
```

`saintexpress_run()` writes `inter.txt`, `prey.txt`, and `bait.txt` into
`workdir`, runs SAINTexpress, reads `list.txt`, and returns a list with:

- `listFile`: data frame containing the `list.txt` path.
- `list`: parsed SAINTexpress result table.
- `out`: captured process output.

Use `cleanup = FALSE` to keep generated input and output files for inspection:

```r
result <- saintexpressbin::saintexpress_run(
  si,
  type = "spc",
  workdir = tempdir(),
  cleanup = FALSE
)
```

On macOS, Docker is used automatically when no native binary is available. Set
`use_docker = TRUE` to force Docker, or `use_docker = FALSE` to require a native
binary.

## Vignette

A worked example using the native binaries on simulated AP-MS data is included
as a package vignette:

```r
vignette("saintexpressbin", package = "saintexpressbin")
```

It runs `SAINTexpress-spc` and `SAINTexpress-int` on a 6-prey/4-bait synthetic
experiment with known true interactors, and mirrors the structure of the
companion [`saintexpress`](https://github.com/prolfqua/saintexpress) vignette so
the native and pure-R engines can be compared side by side. Native-run chunks
are skipped automatically when no platform binary is resolvable.

## License Note

Before public redistribution, verify that the shipped SAINTexpress binaries can
be distributed under the intended hosting and package release terms.
