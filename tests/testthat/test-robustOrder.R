test_that("robustOrder sorts locale independent", {
  lcCollate <- Sys.getlocale("LC_COLLATE")

  x <- c("a", "b", "C")
  Sys.setlocale("LC_COLLATE", "C")
  expect_equal(order(x), c(3, 1, 2))
  expect_equal(madrat:::robustOrder(x), c(3, 1, 2))

  Sys.setlocale("LC_COLLATE", "en_US.UTF-8")
  expect_equal(order(x), c(1, 2, 3))
  expect_equal(madrat:::robustOrder(x), c(3, 1, 2))

  Sys.setlocale("LC_COLLATE", lcCollate)
})

test_that("robustOrder can deal with non-UTF-8 strings", {
  x <- c("2Mor\xe9e et al_2013.pdf", "1Mor\xe9e et al_2013.pdf")
  expect_error(order(x, method = "radix"), "Character encoding must be UTF-8, Latin-1 or bytes")
  expect_equal(madrat:::robustOrder(x), c(2, 1))
  expect_equal(madrat:::robustSort(x), c("1Mor\xe9e et al_2013.pdf", "2Mor\xe9e et al_2013.pdf"))

  expect_equal(madrat:::robustSort(c(5, 3, 2, 4), decreasing = TRUE), 5:2)
  expect_equal(madrat:::robustOrder(c(5, 2, 2, 4), c(0, 1, 0, 17)), c(3, 2, 4, 1))
  expect_equal(madrat:::robustSort(vector(mode = "character", length = 0)), vector(mode = "character", length = 0))
  expect_equal(madrat:::robustOrder(vector(mode = "character", length = 0)), vector(mode = "integer", length = 0))
})
