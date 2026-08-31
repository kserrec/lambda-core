# TRUE = lambda x. lambda y. x
church_true <- function(x) {
  force(x)
  function(y) x
}

# FALSE = lambda x. lambda y. y
church_false <- function(x) function(y) y

# NOT = lambda b. b FALSE TRUE
church_not <- function(boolean) boolean(church_false)(church_true)

# AND = lambda p. lambda q. p q FALSE
church_and <- function(left) {
  force(left)
  function(right) left(right)(church_false)
}

# OR = lambda p. lambda q. p TRUE q
church_or <- function(left) {
  force(left)
  function(right) left(church_true)(right)
}

# ZERO = lambda f. lambda x. x
zero <- function(f) function(value) value

# SUCC = lambda n. lambda f. lambda x. f (n f x)
successor <- function(numeral) {
  force(numeral)
  function(f) {
    force(f)
    function(value) f(numeral(f)(value))
  }
}

# PRED = lambda n. lambda f. lambda x.
#          n (lambda g. lambda h. h (g f)) (lambda u. x) (lambda a. a)
predecessor <- function(numeral) {
  force(numeral)
  function(f) {
    force(f)
    function(value) {
      step <- function(g) {
        force(g)
        function(h) h(g(f))
      }
      seed <- function(u) value
      identity <- function(a) a
      numeral(step)(seed)(identity)
    }
  }
}

one <- successor(zero)

# These observers are the only code that converts terms to native values.
church_to_bool <- function(boolean) {
  when_true <- new.env(parent = emptyenv())
  when_false <- new.env(parent = emptyenv())
  selected <- boolean(when_true)(when_false)

  if (identical(selected, when_true)) {
    return(TRUE)
  }
  if (identical(selected, when_false)) {
    return(FALSE)
  }
  stop("a Church boolean did not select either argument", call. = FALSE)
}

church_to_int <- function(numeral) {
  applications <- 0L
  increment <- function(value) {
    applications <<- applications + 1L
    value
  }
  seed <- new.env(parent = emptyenv())
  numeral(increment)(seed)
  applications
}

check_boolean <- function(label, boolean, expected) {
  actual <- church_to_bool(boolean)
  if (!identical(actual, expected)) {
    stop(sprintf("%s: expected %s, got %s", label, expected, actual), call. = FALSE)
  }
  cat(sprintf("%s: %s\n", label, tolower(as.character(actual))))
}

check_numeral <- function(label, numeral, expected) {
  actual <- church_to_int(numeral)
  if (!identical(actual, as.integer(expected))) {
    stop(sprintf("%s: expected %d, got %d", label, expected, actual), call. = FALSE)
  }
  cat(sprintf("%s: %d\n", label, actual))
}

cat("CHURCH BOOLEANS\n")
check_boolean("TRUE", church_true, TRUE)
check_boolean("FALSE", church_false, FALSE)
check_boolean("NOT TRUE", church_not(church_true), FALSE)
check_boolean("NOT FALSE", church_not(church_false), TRUE)
check_boolean("FALSE AND FALSE", church_and(church_false)(church_false), FALSE)
check_boolean("FALSE AND TRUE", church_and(church_false)(church_true), FALSE)
check_boolean("TRUE AND FALSE", church_and(church_true)(church_false), FALSE)
check_boolean("TRUE AND TRUE", church_and(church_true)(church_true), TRUE)
check_boolean("FALSE OR FALSE", church_or(church_false)(church_false), FALSE)
check_boolean("FALSE OR TRUE", church_or(church_false)(church_true), TRUE)
check_boolean("TRUE OR FALSE", church_or(church_true)(church_false), TRUE)
check_boolean("TRUE OR TRUE", church_or(church_true)(church_true), TRUE)

cat("CHURCH NUMERALS\n")
check_numeral("ZERO", zero, 0L)
check_numeral("ONE", one, 1L)
check_numeral("SUCC ONE", successor(one), 2L)
check_numeral("SUCC (SUCC ONE)", successor(successor(one)), 3L)
check_numeral("PRED ZERO", predecessor(zero), 0L)
check_numeral("PRED ONE", predecessor(one), 0L)
check_numeral("PRED (SUCC ONE)", predecessor(successor(one)), 1L)
check_numeral(
  "PRED (SUCC (SUCC ONE))",
  predecessor(successor(successor(one))),
  2L
)
