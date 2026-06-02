# Is SAINTexpress runnable on this machine?

Returns `TRUE` if a native binary for the current platform is shipped,
or if Docker is available on macOS (the Docker image is built on first
use).

## Usage

``` r
saintexpress_available(type = c("spc", "int"))
```

## Arguments

- type:

  Either `"spc"` or `"int"`.

## Value

`TRUE` if SAINTexpress can run for `type` on this machine, otherwise
`FALSE`.

## Examples

``` r
saintexpress_available("spc")
#> [1] TRUE
```
