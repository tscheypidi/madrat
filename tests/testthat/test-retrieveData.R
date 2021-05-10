globalassign <- function(...) {
  for (x in c(...)) assign(x, eval.parent(parse(text = x)), .GlobalEnv)
}


test_that("retrieveData works as expected", {
  expect_message(retrieveData("example", rev = 0, dev = "test"), "Run retrieveData")
  expect_true(file.exists(paste0(getConfig("outputfolder"), "/rev0test_h12_example_customizable_tag.tgz")))
  expect_message(retrieveData("example", rev = 0, dev = "test"), "data is already available")
})

test_that("retrieveData properly detects malformed inputs", {
  expect_error(retrieveData("NotThere"), "is not a valid output type")
  expect_error(retrieveData("Example", cachetype = "fantasy"), "Unknown cachetype")
  expect_error(retrieveData("Example", unknownargument = 42), "Unknown argument")
})

test_that("argument handling works", {
  fullTEST <- function(rev, myargument = NULL, forcecache = 12) {
    if (!is.null(myargument)) message("myargument = ", myargument)
    return()
  }
  globalassign("fullTEST")
  setConfig(globalenv = FALSE, .verbose = FALSE)
  expect_error(retrieveData("Test"), "is not a valid output type")
  expect_warning(retrieveData("Test", globalenv = TRUE), "Overlapping arguments")
  expect_message(suppressWarnings(retrieveData("Test", myargument = "hello")), "myargument = hello")
})

test_that("a tag can be appended to filename", {
  fullTEST <- function() {
    return(list(tag = "some_tag"))
  }
  globalassign("fullTEST")

  expect_message(retrieveData("Test", globalenv = TRUE), "Run retrieveData")
  expect_true(file.exists(paste0(getConfig("outputfolder"), "/rev0_h12_test_some_tag.tgz")))
})

test_that("retrieveData works if no tag is returned", {
  fullTESTTWO <- function() {
  }
  globalassign("fullTESTTWO")

  expect_message(retrieveData("Testtwo", globalenv = TRUE), "Run retrieveData")
  expect_true(file.exists(paste0(getConfig("outputfolder"), "/rev0_h12_testtwo.tgz")))
})

test_that("retrieveData warns on regex characters in model name", {
  fullMODEL.REGEX <- function() {
  }
  globalassign("fullMODEL.REGEX")

  expect_warning(retrieveData("MODEL.REGEX", globalenv = TRUE), "At least one of the regex characters")
})