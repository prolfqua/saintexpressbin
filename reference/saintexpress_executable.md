# Path to a shipped SAINTexpress executable

Path to a shipped SAINTexpress executable

## Usage

``` r
saintexpress_executable(type = c("spc", "int"))
```

## Arguments

- type:

  Either `"spc"` (spectral counts) or `"int"` (intensities).

## Value

Absolute path to the executable for the current platform, or `""` if no
shipped binary matches.

## Examples

``` r
path <- saintexpress_executable("spc")
is.character(path)
#> [1] TRUE
```
