use std::cell::Cell;
use std::rc::Rc;

#[derive(Clone)]
struct Term {
    function: Rc<dyn Fn(Term) -> Term>,
}

impl Term {
    fn apply(&self, argument: Term) -> Term {
        (self.function)(argument)
    }

    fn same_value_as(&self, other: &Term) -> bool {
        Rc::ptr_eq(&self.function, &other.function)
    }
}

fn lambda(function: impl Fn(Term) -> Term + 'static) -> Term {
    Term {
        function: Rc::new(function),
    }
}

// TRUE = λx.λy.x
fn church_true() -> Term {
    lambda(|x| {
        let selected = x.clone();
        lambda(move |_| selected.clone())
    })
}

// FALSE = λx.λy.y
fn church_false() -> Term {
    lambda(|_| lambda(|y| y))
}

// NOT = λb.b FALSE TRUE
fn church_not() -> Term {
    lambda(|boolean| boolean.apply(church_false()).apply(church_true()))
}

// AND = λp.λq.p q FALSE
fn church_and() -> Term {
    lambda(|left| lambda(move |right| left.apply(right).apply(church_false())))
}

// OR = λp.λq.p TRUE q
fn church_or() -> Term {
    lambda(|left| lambda(move |right| left.apply(church_true()).apply(right)))
}

// ZERO = λf.λx.x
fn zero() -> Term {
    lambda(|_| lambda(|value| value))
}

// SUCC = λn.λf.λx.f (n f x)
fn successor() -> Term {
    lambda(|numeral| {
        lambda(move |function| {
            let captured_numeral = numeral.clone();
            lambda(move |value| {
                let inner = captured_numeral.apply(function.clone()).apply(value);
                function.apply(inner)
            })
        })
    })
}

// PRED = λn.λf.λx.n (λg.λh.h (g f)) (λu.x) (λa.a)
fn predecessor() -> Term {
    lambda(|numeral| {
        lambda(move |function| {
            let captured_numeral = numeral.clone();
            lambda(move |value| {
                let step_function = function.clone();
                let step = lambda(move |g| {
                    let captured_function = step_function.clone();
                    lambda(move |h| h.apply(g.apply(captured_function.clone())))
                });

                let seed_value = value.clone();
                let seed = lambda(move |_| seed_value.clone());
                let identity = lambda(|term| term);

                captured_numeral.apply(step).apply(seed).apply(identity)
            })
        })
    })
}

fn one() -> Term {
    successor().apply(zero())
}

// These observers are the only code that converts terms to native values.
fn church_to_bool(boolean: Term) -> bool {
    let when_true = lambda(|term| term);
    let when_false = lambda(|term| term);
    let selected = boolean.apply(when_true.clone()).apply(when_false.clone());

    if selected.same_value_as(&when_true) {
        true
    } else if selected.same_value_as(&when_false) {
        false
    } else {
        panic!("a Church boolean did not select either argument");
    }
}

fn church_to_int(numeral: Term) -> i32 {
    let applications = Rc::new(Cell::new(0));
    let counter = Rc::clone(&applications);
    let increment = lambda(move |term| {
        counter.set(counter.get() + 1);
        term
    });
    let seed = lambda(|term| term);

    numeral.apply(increment).apply(seed);
    applications.get()
}

fn check_boolean(label: &str, boolean: Term, expected: bool) {
    let actual = church_to_bool(boolean);
    assert_eq!(actual, expected, "{label}");
    println!("{label}: {actual}");
}

fn check_numeral(label: &str, numeral: Term, expected: i32) {
    let actual = church_to_int(numeral);
    assert_eq!(actual, expected, "{label}");
    println!("{label}: {actual}");
}

fn main() {
    println!("CHURCH BOOLEANS");
    check_boolean("TRUE", church_true(), true);
    check_boolean("FALSE", church_false(), false);
    check_boolean("NOT TRUE", church_not().apply(church_true()), false);
    check_boolean("NOT FALSE", church_not().apply(church_false()), true);
    check_boolean(
        "FALSE AND FALSE",
        church_and().apply(church_false()).apply(church_false()),
        false,
    );
    check_boolean(
        "FALSE AND TRUE",
        church_and().apply(church_false()).apply(church_true()),
        false,
    );
    check_boolean(
        "TRUE AND FALSE",
        church_and().apply(church_true()).apply(church_false()),
        false,
    );
    check_boolean(
        "TRUE AND TRUE",
        church_and().apply(church_true()).apply(church_true()),
        true,
    );
    check_boolean(
        "FALSE OR FALSE",
        church_or().apply(church_false()).apply(church_false()),
        false,
    );
    check_boolean(
        "FALSE OR TRUE",
        church_or().apply(church_false()).apply(church_true()),
        true,
    );
    check_boolean(
        "TRUE OR FALSE",
        church_or().apply(church_true()).apply(church_false()),
        true,
    );
    check_boolean(
        "TRUE OR TRUE",
        church_or().apply(church_true()).apply(church_true()),
        true,
    );

    println!("CHURCH NUMERALS");
    check_numeral("ZERO", zero(), 0);
    check_numeral("ONE", one(), 1);
    check_numeral("SUCC ONE", successor().apply(one()), 2);
    check_numeral(
        "SUCC (SUCC ONE)",
        successor().apply(successor().apply(one())),
        3,
    );
    check_numeral("PRED ZERO", predecessor().apply(zero()), 0);
    check_numeral("PRED ONE", predecessor().apply(one()), 0);
    check_numeral(
        "PRED (SUCC ONE)",
        predecessor().apply(successor().apply(one())),
        1,
    );
    check_numeral(
        "PRED (SUCC (SUCC ONE))",
        predecessor().apply(successor().apply(successor().apply(one()))),
        2,
    );
}
