# load testthat ----
library(testthat)

# what is a test? ---------------------------------------------------------

# passes with no message
expect_equal(
  object = 1 + 1,
  expected = 2
  )

# fails with message
expect_equal(
  object = 1 + 1,
  expected = 3
  )

# There are the usual R traps here (see R Inferno)
# The following fail due to numerical error so check you are using the right
# expectation

expect_true(
  object = sqrt(2) ^ 2 == 2
  )

expect_identical(
  object = sqrt(2) ^ 2,
  expected = 2
  )


# Bundling expectations into tests ----------------------------------------
# To automate testing, we bundle expectations into tests

context("Computer can do math")

test_that(
  desc = "Computer can do sums",
  code = {
    expect_equal(
      object = 1 + 1,
      expected = 2
    )
    expect_equal(
      object = 1 + 3,
      expected = 3
    )
  }
)

# These are put in a file to be called by test_file

test_file("computer_do_math.R")



# A greedy algorithm ------------------------------------------------------

# A test suite for a function "greedy" that will take an ordered vector, and
# returns a vector of integers that correspond to elements that sum to less than
# or equal to the supplied number.  It will select the first element if it can
# afford it, then the second, and so on, skipping those it cannot afford.

# test that output is integer class
expect_type(
  object = greedy(runif(5), 1),
  type = "integer"
  )

# a more sophisticated test that the output contains integers (note that is.integer does not test this), and defines the object outside of the expectation

test_output <- greedy(runif(5), 1)

expect_equal(
  object = test_output,
  expected = round(test_output)
)

test_that(desc = "output is an integer vector",
          code = {

            test_output <- greedy(runif(5), 1)

            expect_type(
              object = test_output,
              type = "integer"
            )

            expect_equal(
              object = test_output,
              expected = round(test_output)
              )

            })


# test that output is correct for particular scenarios
test_vector_1 <- c(1, 3, 6, 4, 2)

expect_equal(
  object = greedy(test_output_1, 10),
  expected = c(1, 2, 3) # This is selecting 1, 3, 6 which sum to 10
)

expect_equal(
  object = greedy(test_output_1, 9),
  expected = c(1, 2, 4) # This is selecting 1, 3, 4 which sum to 8
)

expect_equal(
  object = greedy(test_output_1, 13),
  expected = c(1, 2, 3, 5) # This is selecting 1, 3, 6, 2 which sum to 12
)




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


# test that output is not incorrect for random numbers
test_vector <- runif(100)
test_number <- sum(test_vector) / 2
test_output <- greedy(test_vector, test_number)

expect_lte(
  object = sum(test_vector[test_output]),
  expected = test_number
  )

# You can run random scenarios multiple times in a loop

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

expect_equal(
  object = greedy(1, 0),
  expected = c()
)

# test odd inputs
# again, we now need to consider what we want to do - ignore things, error out,
# print a message?

# If the vector is empty, there is nothing to be selected so return
# nothing

expect_equal(
  object = greedy(c(), 10),
  expected = c()
)

# If the number is empty, we cannot select anything so return
# an empty vector
expect_equal(
  object = greedy(1:5, c()),
  expected = c()
)

# I'm going to treat NA in the vector as missing and not available for selection.  I could
# count them as zero and therefore they can always be selected
expect_equal(
  object = greedy(NA, 1),
  expected = c() # There is nothing to select
  )

expect_equal(
  object = greedy(c(1, 2, NA, 3, 5), 10),
  expected = c(1, 2, 4) # The NA is not selected
  )

# I'm going to treat NA in the number as a zero, there is nothing to be selected
expect_equal(
  object = greedy(1:5, NA),
  expected = c()
  )

expect_equal(
  object = greedy(NULL, 10),
  expected = c()
 )


# testing an error message

expect_error(
  object = greedy("this is not a numeric vector", 1),
  regexp = "Both arguments to greedy must be numeric!"
  )

expect_error(
  object = greedy(1:5, "this is not a number"),
  regexp = "Both arguments to greedy must be numeric!"
  )

# as you can see, there is no limit to what test you can implement and it is
# counter-productive to do too many (I HAVE DONE TOO MANY).  You need to judge
# what is appropriate.

# For example, if I know that there is no way that my code will be passing a
# character to the greedy function, I probably don't need that test.

# For automation, these test functions have been bundled together into the file
# test_greedy.R.

# Let's implement a simple approach to our function

greedy <- function(vector, number){
  # initialise cumulative sum tracker and output vector
  total <- 0 # how much I've spent
  output <- c() # what I've selected

  # loop over vector, adding indices and adjusting cumulative sum if selected
  for (i in 1:length(vector)){
    if (total + vector[i] <= number) {
      total <- total - vector[i] # OH NO, WHAT A TERRIBLE MISTAKE. IT SHOULD BE +
      output <- c(output, i)
    }
  }

  # return output
  return(output)
}

test_file("test_greedy.R")

# Oops we are failing just about everything, because of that typo

greedy <- function(vector, number){
  # initialise cumulative sum tracker and output vector
  total <- 0
  output <- c()

  # loop over vector, adding indices and adjusting cumulative sum if selected
  for (i in 1:length(vector)){
    if (total + vector[i] <= number) {
      total <- total + vector[i] # THAT'S BETTER!
      output <- c(output, i)
    }
  }

  # return output
  return(output)
}

test_file("test_greedy.R")

# We are now passing all the scenario tests.  Yay!

# I have committed a cardinal R sin when writing a loop.  The 1:length(vector)
# gives c(1, 0).  I refer to vector[0], which returns a zero length numeric object
# you cannot add with.

greedy <- function(vector, number){
  # initialise cumulative sum tracker and output vector
  total <- 0
  output <- c()

  # loop over vector, adding indices and adjusting cumulative sum if selected
  for (i in seq_along(vector)){ # USE seq_along NOT 1:length() IN LOOPS
    if (total + vector[i] <= number) {
      total <- total + vector[i]
      output <- c(output, i)
    }
  }

  # return output
  return(output)
}

test_file("test_greedy.R")

# We fixed one problem but we still have a problem with the empty number argument
# We will fix it and, while we're at it, deal with recognising text inputs, and with NAs in a numeric vector

greedy <- function(vector, number){

  # validate inputs
  # if either argument is empty then return empty vector
  if (length(number) == 0 | length(vector) == 0)
    return(c())
  # if either argument is NA then return empty vector
  if (is.na(number) | is.na(vector)[1] & length(vector) == 1)
    return(c())
  # if either argument is non-numeric then error out
  # Note that c() and NA are non-numeric but will be caught earlier and
  # return c() as per our test requirements
  if (!is.numeric(vector) | !is.numeric(number))
    stop("Both arguments to greedy must be numeric!")

  # identify NAs in vector for removal later and change them to Inf

  na_to_remove <- which(is.na(vector))
  vector[na_to_remove] <- Inf

  # initialise cumulative sum tracker and output vector
  total <- 0
  output <- c()

  # loop over vector, adding indices and adjusting cumulative sum if selected
  for (i in seq_along(vector)){ # USE seq_along NOT 1:length() IN LOOPS
    if (total + vector[i] <= number) {
      total <- total + vector[i]
      output <- c(output, i)
    }
  }

  # if there are any NAs in the vector, remove them from the output so they aren't selected
  output <- output[!output %in% na_to_remove]

  # return output
  return(output)
}

# And now everything passes

test_file("test_greedy.R")


# test_file will run the tests in a file

# test_dir will run the tests in all files in a directory

test_dir(".")

# If you are developing a package the following are useful -----------------

# add project infrastructure - it adds the tests/testthat subfolders where you
# put all your tests and it includes testthat in the suggests field of your
# package DESCRIPTION
devtools::use_testthat()

# run the test suite for your package - this runs the files containing the tests in the test/testthat folder
devtools::test()




