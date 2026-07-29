# The package intentionally ships executable files in inst/bin. Treat that
# expected R CMD check warning as non-fatal while still failing on errors.
CHECK_CMD = Rscript -e "devtools::check(error_on = 'error')"
CHECK_FAST_CMD = Rscript -e "devtools::check(build_args = '--no-build-vignettes', args = '--no-vignettes', vignettes = FALSE, error_on = 'error')"
