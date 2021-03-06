context("getCode")

globalassign <- function(...) {
  for (x in c(...)) assign(x,eval.parent(parse(text = x)),.GlobalEnv)
}

test_that("getCode works", {
 setConfig(verbosity = 1, .verbose = FALSE)
 expect_silent(a <- madrat:::getCode("madrat"))
 flags <- list(monitor = list(`madrat:::readTau` = c("madrat:::sysdata$iso_cell", 
                                                     "magclass:::ncells")), 
               ignore = list(`madrat:::readTau` = "madrat:::toolAggregate"))
 expect_identical(attr(a,"flags"), flags)
 expect_setequal(names(attributes(a)), c("names", "fpool", "hash", "mappings", "flags"))
 calcTauTotal <- function() {
   return(1)
 }
 calcFlagTest <- function() {
   "!# @ignore  testIgnore"
   "!# @ignore  ignoreMore"
   return(1)
 }
 globalassign("calcTauTotal", "calcFlagTest")
 expect_warning(a <- madrat:::getCode("madrat", globalenv = TRUE), "Duplicate entries")
 expect_setequal(attr(a,"flags")$ignore$calcFlagTest, c("testIgnore", "ignoreMore"))
 rm(list = c("calcTauTotal", "calcFlagTest"), envir = .GlobalEnv)
 expect_null(attr(madrat:::getCode(NULL, TRUE),"flags"))
})