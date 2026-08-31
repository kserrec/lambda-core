// TRUE = lambda x. lambda y. x
def churchTrue = { x -> { ignored -> x } }

// FALSE = lambda x. lambda y. y
def churchFalse = { ignored -> { y -> y } }

// NOT = lambda b. b FALSE TRUE
def churchNot = { encodedBoolean ->
    encodedBoolean.call(churchFalse).call(churchTrue)
}

// AND = lambda p. lambda q. p q FALSE
def churchAnd = { left -> { right -> left.call(right).call(churchFalse) } }

// OR = lambda p. lambda q. p TRUE q
def churchOr = { left -> { right -> left.call(churchTrue).call(right) } }

// ZERO = lambda f. lambda x. x
def zero = { ignored -> { value -> value } }

// SUCC = lambda n. lambda f. lambda x. f (n f x)
def successor = { numeral ->
    { function ->
        { value -> function.call(numeral.call(function).call(value)) }
    }
}

// PRED = lambda n. lambda f. lambda x.
//          n (lambda g. lambda h. h (g f)) (lambda u. x) (lambda a. a)
def predecessor = { numeral ->
    { function ->
        { value ->
            def step = { g -> { h -> h.call(g.call(function)) } }
            def seed = { ignored -> value }
            def identity = { term -> term }
            numeral.call(step).call(seed).call(identity)
        }
    }
}

def one = successor.call(zero)

// These observers are the only code that converts terms to native values.
def churchToBool = { encodedBoolean ->
    def whenTrue = new Object()
    def whenFalse = new Object()
    def selected = encodedBoolean.call(whenTrue).call(whenFalse)

    if (selected.is(whenTrue)) {
        return true
    }
    if (selected.is(whenFalse)) {
        return false
    }
    throw new IllegalStateException('a Church boolean did not select either argument')
}

def churchToInt = { numeral ->
    int applications = 0
    def increment = { value ->
        applications += 1
        value
    }
    def seed = new Object()
    numeral.call(increment).call(seed)
    applications
}

def checkBoolean = { String label, encodedBoolean, boolean expected ->
    boolean actual = churchToBool.call(encodedBoolean)
    if (actual != expected) {
        throw new IllegalStateException("${label}: expected ${expected}, got ${actual}")
    }
    println "${label}: ${actual}"
}

def checkNumeral = { String label, numeral, int expected ->
    int actual = churchToInt.call(numeral)
    if (actual != expected) {
        throw new IllegalStateException("${label}: expected ${expected}, got ${actual}")
    }
    println "${label}: ${actual}"
}

println 'CHURCH BOOLEANS'
checkBoolean.call('TRUE', churchTrue, true)
checkBoolean.call('FALSE', churchFalse, false)
checkBoolean.call('NOT TRUE', churchNot.call(churchTrue), false)
checkBoolean.call('NOT FALSE', churchNot.call(churchFalse), true)
checkBoolean.call('FALSE AND FALSE', churchAnd.call(churchFalse).call(churchFalse), false)
checkBoolean.call('FALSE AND TRUE', churchAnd.call(churchFalse).call(churchTrue), false)
checkBoolean.call('TRUE AND FALSE', churchAnd.call(churchTrue).call(churchFalse), false)
checkBoolean.call('TRUE AND TRUE', churchAnd.call(churchTrue).call(churchTrue), true)
checkBoolean.call('FALSE OR FALSE', churchOr.call(churchFalse).call(churchFalse), false)
checkBoolean.call('FALSE OR TRUE', churchOr.call(churchFalse).call(churchTrue), true)
checkBoolean.call('TRUE OR FALSE', churchOr.call(churchTrue).call(churchFalse), true)
checkBoolean.call('TRUE OR TRUE', churchOr.call(churchTrue).call(churchTrue), true)

println 'CHURCH NUMERALS'
checkNumeral.call('ZERO', zero, 0)
checkNumeral.call('ONE', one, 1)
checkNumeral.call('SUCC ONE', successor.call(one), 2)
checkNumeral.call('SUCC (SUCC ONE)', successor.call(successor.call(one)), 3)
checkNumeral.call('PRED ZERO', predecessor.call(zero), 0)
checkNumeral.call('PRED ONE', predecessor.call(one), 0)
checkNumeral.call('PRED (SUCC ONE)', predecessor.call(successor.call(one)), 1)
checkNumeral.call(
    'PRED (SUCC (SUCC ONE))',
    predecessor.call(successor.call(successor.call(one))),
    2
)
