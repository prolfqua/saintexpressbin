# Run SAINTexpress on prepared input

Writes `inter.txt`, `prey.txt`, `bait.txt` into `workdir`, then runs the
bundled native binary, or Docker on macOS when no native binary is
available (or when `use_docker = TRUE`).

## Usage

``` r
saintexpress_run(
  si,
  type = c("spc", "int"),
  workdir = getwd(),
  cleanup = TRUE,
  use_docker = NULL
)
```

## Arguments

- si:

  Named list with elements `inter`, `prey`, `bait` (data frames).

- type:

  `"spc"` (spectral counts) or `"int"` (intensities).

- workdir:

  Directory to write inputs and read `list.txt` from. Defaults to
  [`getwd()`](https://rdrr.io/r/base/getwd.html).

- cleanup:

  If `TRUE`, remove generated files after reading the results.

- use_docker:

  `NULL` (auto: native first, Docker fallback on macOS), `TRUE` to force
  Docker, or `FALSE` to require a native binary.

## Value

List with elements `listFile` (data frame with the path), `list` (the
parsed `list.txt`), and `out` (data frame with the run log).

## Examples

``` r
si <- list(
  inter = data.frame(
    ipId = c("IP1", "IP1", "IP2", "IP2", "IP3", "IP4"),
    baitId = c("BaitA", "BaitA", "BaitA", "BaitA", "Ctrl", "Ctrl"),
    preyId = c("Prey1", "Prey2", "Prey1", "Prey2", "Prey1", "Prey2"),
    quant = c(20, 1, 18, 1, 1, 1)
  ),
  prey = data.frame(
    preyId = c("Prey1", "Prey2"),
    preyLength = c(500, 500),
    preyGeneId = c("Gene1", "Gene2")
  ),
  bait = data.frame(
    ipId = c("IP1", "IP2", "IP3", "IP4"),
    baitId = c("BaitA", "BaitA", "Ctrl", "Ctrl"),
    CorT = c("T", "T", "C", "C")
  )
)
if (nzchar(saintexpress_executable("spc"))) {
  workdir <- tempfile("saintexpressbin-")
  dir.create(workdir)
  saintexpress_run(si, type = "spc", workdir = workdir, use_docker = FALSE)
}
#> Input files are: /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/inter.txt, /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/prey.txt, /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/bait.txt
#> Interaction file: "/tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/inter.txt"
#> Prey file: "/tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/prey.txt"
#> Bait file: "/tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/bait.txt"
#> GO file: ""
#> Parsing prey file /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/prey.txt ...done.
#> Parsing prey file /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/bait.txt ...done.
#> Parsing interaction file /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/inter.txt ...done.
#> Setting matrix indices for each interaction...done.
#> Creating matrix...done.
#> Creating a list of unique interactions...done.
#> $listFile
#>                                               listFile
#> 1 /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/list.txt
#> 
#> $list
#>    Bait  Prey PreyGene  Spec SpecSum AvgSpec NumReplicates ctrlCounts AvgP MaxP
#> 1 BaitA Prey1    Gene1 20|18      38      19             2        1|0    1    1
#> 2 BaitA Prey2    Gene2   1|1       2       1             2        0|1    0    0
#>   TopoAvgP TopoMaxP SaintScore logOddsScore FoldChange BFDR boosted_by
#> 1        1        1          1        24.22         38    0         NA
#> 2        0        0          0        -0.19          2    0         NA
#> 
#> $out
#>                                                                                                                                                                                   out
#> 1  Input files are: /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/inter.txt, /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/prey.txt, /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/bait.txt
#> 2                                                                                                           Interaction file: "/tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/inter.txt"
#> 3                                                                                                                   Prey file: "/tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/prey.txt"
#> 4                                                                                                                   Bait file: "/tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/bait.txt"
#> 5                                                                                                                                                                         GO file: ""
#> 6                                                                                                     Parsing prey file /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/prey.txt ...done.
#> 7                                                                                                     Parsing prey file /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/bait.txt ...done.
#> 8                                                                                             Parsing interaction file /tmp/RtmpAg6rOU/saintexpressbin-1c749daaf12/inter.txt ...done.
#> 9                                                                                                                                 Setting matrix indices for each interaction...done.
#> 10                                                                                                                                                            Creating matrix...done.
#> 11                                                                                                                                     Creating a list of unique interactions...done.
#> 
```
