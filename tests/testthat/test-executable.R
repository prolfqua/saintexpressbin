test_that("binary filename varies by platform", {
  expect_equal(saintexpressbin:::.binary_filename("spc", "Linux"), "SAINTexpress-spc")
  expect_equal(saintexpressbin:::.binary_filename("int", "Darwin"), "SAINTexpress-int")
  expect_equal(saintexpressbin:::.binary_filename("spc", "Windows"), "SAINTexpress-spc.exe")
})

test_that("platform subdir maps known sysnames", {
  expect_equal(saintexpressbin:::.platform_subdir("Darwin"), "Darwin")
  expect_equal(saintexpressbin:::.platform_subdir("Linux"), "Linux64")
  expect_equal(saintexpressbin:::.platform_subdir("Windows"), "Windows64")
  expect_true(is.na(saintexpressbin:::.platform_subdir("SunOS")))
})

test_that("executable resolves for at least one shipped platform", {
  hits <- vapply(c("Darwin", "Linux", "Windows"), function(s) {
    nzchar(saintexpressbin:::.saintexpress_executable("spc", sysname = s))
  }, logical(1))
  expect_true(any(hits))
})
