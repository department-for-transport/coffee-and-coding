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