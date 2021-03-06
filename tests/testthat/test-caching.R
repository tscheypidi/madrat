context("Test caching")

globalassign <- function(...) {
  for (x in c(...)) assign(x,eval.parent(parse(text = x)),.GlobalEnv)
}

test_that("Caching works", {
  calcCacheExample <- function() return(list(x = as.magpie(1), description = "-", unit = "-"))
  globalassign("calcCacheExample")
  setConfig(globalenv = TRUE, ignorecache = FALSE, .verbose = FALSE,
            cachefolder = paste0(tempdir(), "/test_caching_works"))
  expect_null(madrat:::cacheGet("calc","CacheExample"))
  expect_message(calcOutput("CacheExample", aggregate = FALSE), "writing cache")
  expect_identical(madrat:::cacheGet("calc","CacheExample")$x, as.magpie(1))
  setConfig(ignorecache = TRUE, .verbose = FALSE)
  expect_null(madrat:::cacheGet("calc","CacheExample"))
  setConfig(ignorecache = FALSE, .verbose = FALSE)
  
  expect_identical(basename(madrat:::cacheName("calc","CacheExample")), "calcCacheExample-F43888ba0.rds")
  
  calcCacheExample <- function() return(list(x = as.magpie(2), description = "-", unit = "-"))
  globalassign("calcCacheExample")
  expect_null(madrat:::cacheName("calc","CacheExample", mode = "get"))
  setConfig(forcecache = TRUE, .verbose = FALSE)
  expect_identical(basename(madrat:::cacheName("calc","CacheExample")), "calcCacheExample.rds")
  expect_message(cf <- madrat:::cacheName("calc","CacheExample", mode = "get"), "does not match fingerprint")
  expect_identical(basename(cf), "calcCacheExample-F43888ba0.rds")
  setConfig(forcecache = FALSE, .verbose = FALSE)
  expect_message(a <- calcOutput("CacheExample", aggregate=FALSE), "writing cache")
  expect_identical(basename(madrat:::cacheName("calc","CacheExample", mode = "get")), "calcCacheExample-F4ece4fe6.rds")
  
  calcCacheExample <- function() return(list(x = as.magpie(3), description = "-", unit = "-"))
  globalassign("calcCacheExample")
  setConfig(forcecache = TRUE, .verbose = FALSE)
  expect_message(cf <- madrat:::cacheName("calc","CacheExample", mode = "get"), "does not match fingerprint")
  expect_identical(basename(cf), "calcCacheExample-F4ece4fe6.rds")
  
})

test_that("Argument hashing works", {
  expect_null(madrat:::cacheArgumentsHash(madrat:::readTau))
  expect_null(madrat:::cacheArgumentsHash(madrat:::readTau, list(subtype="paper")))
  expect_identical(madrat:::cacheArgumentsHash(madrat:::readTau, args=list(subtype="historical")), "-50d72f51")
  expect_identical(madrat:::cacheArgumentsHash(c(madrat:::readTau, madrat:::convertTau), args=list(subtype="historical")), "-50d72f51")
  # nonexisting arguments will be ignored if ... is missing
  expect_identical(madrat:::cacheArgumentsHash(madrat:::readTau, args=list(subtype="historical", notthere = 42)), "-50d72f51")
  # if ... exists all arguments will get considered
  expect_null(madrat:::cacheArgumentsHash(calcOutput, args=list(try=FALSE)))
  expect_identical(madrat:::cacheArgumentsHash(calcOutput, args=list(try=TRUE)), "-01df3eb2")
  expect_identical(madrat:::cacheArgumentsHash(calcOutput, args=list(try=TRUE, notthere = 42)), "-ae021eac")
  calcArgs <- function(a = NULL) return(1)
  expect_null(madrat:::cacheArgumentsHash(calcArgs))
  expect_null(madrat:::cacheArgumentsHash(calcArgs, args=list(a = NULL)))
  expect_identical(madrat:::cacheArgumentsHash(calcArgs, args=list(a=12)), "-8bb64daf")
  expect_error(madrat:::cacheArgumentsHash(NULL,args=list(no="call")), "No call")
})

test_that("Cache naming and identification works correctly", {
  setConfig(forcecache = FALSE, .verbose = FALSE)
  downloadCacheExample <- function() return(list(url = 1, author = 1, title = 1, license = 1,
                                                 description = 1, unit = 1))
  readCacheExample <- function() return(as.magpie(1))
  correctCacheExample <- function(x, subtype = "blub") {
    if (subtype == "blub") return(as.magpie(1))
    else if (subtype == "bla") return(as.magpie(2))
  }
  globalassign("downloadCacheExample", "readCacheExample", "correctCacheExample")
  expect_message(readSource("CacheExample", convert = "onlycorrect"), "correctCacheExample-F[^-]*.rds")
  expect_message(readSource("CacheExample", convert = "onlycorrect", subtype = "bla"), "correctCacheExample-F[^-]*-d0d19d80.rds")
  expect_message(readSource("CacheExample", convert = "onlycorrect", subtype = "blub"), "correctCacheExample-F[^-]*.rds")
  
  readCacheExample <- function(subtype = "blub") {
    if (subtype == "blub") return(as.magpie(1))
    else if (subtype == "bla") return(as.magpie(2))
  }
  correctCacheExample <- function(x) return(x)

  globalassign("downloadCacheExample", "readCacheExample", "correctCacheExample")
  expect_message(readSource("CacheExample", convert = "onlycorrect"), "correctCacheExample-F[^-]*.rds")
  expect_message(readSource("CacheExample", convert = "onlycorrect", subtype = "bla"), "correctCacheExample-F[^-]*-d0d19d80.rds")
  expect_message(readSource("CacheExample", convert = "onlycorrect", subtype = "blub"), "correctCacheExample-F[^-]*.rds")
  
  
})
