final class Term {
    private let function: (Term) -> Term

    init(_ function: @escaping (Term) -> Term) {
        self.function = function
    }

    func callAsFunction(_ argument: Term) -> Term {
        function(argument)
    }
}

func lambda(_ function: @escaping (Term) -> Term) -> Term {
    Term(function)
}

// TRUE = lambda x. lambda y. x
func churchTrue() -> Term {
    lambda { x in lambda { _ in x } }
}

// FALSE = lambda x. lambda y. y
func churchFalse() -> Term {
    lambda { _ in lambda { y in y } }
}

// NOT = lambda b. b FALSE TRUE
func churchNot() -> Term {
    lambda { boolean in boolean(churchFalse())(churchTrue()) }
}

// AND = lambda p. lambda q. p q FALSE
func churchAnd() -> Term {
    lambda { left in
        lambda { right in left(right)(churchFalse()) }
    }
}

// OR = lambda p. lambda q. p TRUE q
func churchOr() -> Term {
    lambda { left in
        lambda { right in left(churchTrue())(right) }
    }
}

// ZERO = lambda f. lambda x. x
func zero() -> Term {
    lambda { _ in lambda { value in value } }
}

// SUCC = lambda n. lambda f. lambda x. f (n f x)
func successor() -> Term {
    lambda { numeral in
        lambda { function in
            lambda { value in function(numeral(function)(value)) }
        }
    }
}

// PRED = lambda n. lambda f. lambda x.
//          n (lambda g. lambda h. h (g f)) (lambda u. x) (lambda a. a)
func predecessor() -> Term {
    lambda { numeral in
        lambda { function in
            lambda { value in
                let step = lambda { g in
                    lambda { h in h(g(function)) }
                }
                let seed = lambda { _ in value }
                let identity = lambda { term in term }
                return numeral(step)(seed)(identity)
            }
        }
    }
}

func one() -> Term {
    successor()(zero())
}

// These observers are the only code that converts terms to native values.
func churchToBool(_ boolean: Term) -> Bool {
    let whenTrue = lambda { term in term }
    let whenFalse = lambda { term in term }
    let selected = boolean(whenTrue)(whenFalse)

    if selected === whenTrue {
        return true
    }
    if selected === whenFalse {
        return false
    }
    preconditionFailure("a Church boolean did not select either argument")
}

func churchToInt(_ numeral: Term) -> Int {
    var applications = 0
    let increment = lambda { term in
        applications += 1
        return term
    }
    let seed = lambda { term in term }
    _ = numeral(increment)(seed)
    return applications
}

func checkBoolean(_ label: String, _ boolean: Term, _ expected: Bool) {
    let actual = churchToBool(boolean)
    precondition(actual == expected, "\(label): expected \(expected), got \(actual)")
    print("\(label): \(actual ? "true" : "false")")
}

func checkNumeral(_ label: String, _ numeral: Term, _ expected: Int) {
    let actual = churchToInt(numeral)
    precondition(actual == expected, "\(label): expected \(expected), got \(actual)")
    print("\(label): \(actual)")
}

print("CHURCH BOOLEANS")
checkBoolean("TRUE", churchTrue(), true)
checkBoolean("FALSE", churchFalse(), false)
checkBoolean("NOT TRUE", churchNot()(churchTrue()), false)
checkBoolean("NOT FALSE", churchNot()(churchFalse()), true)
checkBoolean("FALSE AND FALSE", churchAnd()(churchFalse())(churchFalse()), false)
checkBoolean("FALSE AND TRUE", churchAnd()(churchFalse())(churchTrue()), false)
checkBoolean("TRUE AND FALSE", churchAnd()(churchTrue())(churchFalse()), false)
checkBoolean("TRUE AND TRUE", churchAnd()(churchTrue())(churchTrue()), true)
checkBoolean("FALSE OR FALSE", churchOr()(churchFalse())(churchFalse()), false)
checkBoolean("FALSE OR TRUE", churchOr()(churchFalse())(churchTrue()), true)
checkBoolean("TRUE OR FALSE", churchOr()(churchTrue())(churchFalse()), true)
checkBoolean("TRUE OR TRUE", churchOr()(churchTrue())(churchTrue()), true)

print("CHURCH NUMERALS")
checkNumeral("ZERO", zero(), 0)
checkNumeral("ONE", one(), 1)
checkNumeral("SUCC ONE", successor()(one()), 2)
checkNumeral("SUCC (SUCC ONE)", successor()(successor()(one())), 3)
checkNumeral("PRED ZERO", predecessor()(zero()), 0)
checkNumeral("PRED ONE", predecessor()(one()), 0)
checkNumeral("PRED (SUCC ONE)", predecessor()(successor()(one())), 1)
checkNumeral(
    "PRED (SUCC (SUCC ONE))",
    predecessor()(successor()(successor()(one()))),
    2
)
