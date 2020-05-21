# A test suite for a function "greedy" that will take an ordered vector, and returns a
# vector of integers that correspond to elements that sum to less than or equal
# to the supplied number


#-----------------------------------------------------------------------------#

context("Output is a vector of integers")

test_that("Output is an integer vector",
          {
            expect_type(
              object = greedy(runif(5), 1),
              type = "integer"
              )

            # a more sophisticated test that the output contains integers (note
            # that is.integer does not test this)
            test_output <- greedy(runif(5), 1)
            expect_equal(
              object = test_output,
              expected = round(test_output)
            )
          }
)

#-----------------------------------------------------------------------------#

context("Testing specified and random scenarios")

test_that("Output is correct for first test scenario",
          {
            test_input_1 <- c(1, 3, 6, 4, 2)

            expect_equal(
              object = greedy(test_input_1, 10),
              expected = c(1, 2, 3) # This is selecting 1, 3, 6 which sum to 10
            )
            expect_equal(
              object = greedy(test_input_1, 9),
              expected = c(1, 2, 4) # This is selecting 1, 3, 4 which sum to 8
            )
            expect_equal(
              object = greedy(test_input_1, 13),
              expected = c(1, 2, 3, 5) # This is selecting 1, 3, 6, 2 which sum to 12
            )
          }
)

test_that("Output is correct for second scenario",
          {
            test_input_2 <- c(1, 1, 4, 1, 4, 2)

            expect_equal(
              object = greedy(test_input_2, 10),
              expected = c(1, 2, 3, 4, 6) # This is selecting 1, 1, 4, 1, 2 which sum to 9
            )
            expect_equal(
              object = greedy(test_input_2, 5),
              expected = c(1, 2, 4, 6) # This is selecting 1, 1, 1, 2 which sum to 5
            )
            expect_equal(
              object = greedy(test_input_2, 25), # number is more than the sum
              expected = c(1, 2, 3, 4, 5, 6) # This is selecting all which sum to 13
            )
          }
)

test_that(
  desc = "Testing ten random scenarios",
  code = {
    for (i in 1:10){
      test_vector <- runif(100)
      test_number <- sum(test_vector) / 2
      test_output <- greedy(test_vector, test_number)

      expect_lte(
        object = sum(test_vector[test_output]),
        expected = test_number
      )
    }
  }
)


    # test that output is correct when nothing can be selected
    # what do we want our function to return in this case?
test_that("Nothing selected returns NULL",
          {
            expect_equal(
              object = greedy(1, 0),
              expected = c()
            )
          }
)

#-----------------------------------------------------------------------------#

context("Testing awkward inputs")

test_that("Passing an empty vector as an argument returns empty vector",
          {
            expect_equal(
              object = greedy(c(), 10),
              expected = c()
            )
            expect_equal(
              object = greedy(1:5, c()),
              expected = c()
            )
          }
)

test_that("Passing NA or vectors with NA returns correctly",
          {
            expect_equal(
              object = greedy(NA, 1),
              expected = c() # There is nothing to select
            )
            expect_equal(
              object = greedy(c(1, 2, NA, 3, 5), 10),
              expected = c(1, 2, 4) # The NA is not selected
            )
            expect_equal(
              object = greedy(c(NA, 2, NA, 3, NA), 10),
              expected = c(2, 4) # The NA is not selected
            )

            # I'm going to treat NA in the number as a zero, there is nothing to be selected
            expect_equal(
              object = greedy(1:5, NA),
              expected = NULL
            )

            # Similarly if the vector is empty, there is nothing to be selected so return
            # NULL
            expect_equal(
              object = greedy(NULL, 10),
              expected = c()
            )

          }
)

test_that(
  desc = "Inputting characters produces error",
  code = {

    expect_error(
      object = greedy("this is not a numeric vector", 1),
      regexp = "Both arguments to greedy must be numeric!"
    )

    expect_error(
      object = greedy(1:5, "this is not a number"),
      regexp = "Both arguments to greedy must be numeric!"
    )
  }
)
