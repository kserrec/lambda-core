use std::cell::Cell;
use std::rc::Rc;

// A lambda-calculus term is a function from one term to another term.
// Rc supplies the indirection needed for this recursive type and lets a term
// be referenced more than once without copying the closure inside it.
#[derive(Clone)]
struct Term(Rc<dyn Fn(Term) -> Term>);

impl Term {
    fn new(function: impl Fn(Term) -> Term + 'static) -> Self {
        Self(Rc::new(function))
    }

    fn apply(&self, argument: Term) -> Term {
        (self.0)(argument)
    }

    fn is_same_term_as(&self, other: &Self) -> bool {
        Rc::ptr_eq(&self.0, &other.0)
    }
}

// TRUE  = λx.λy.x
fn church_true() -> Term {
    Term::new(|x| Term::new(move |_y| x.clone()))
}

// FALSE = λx.λy.y
fn church_false() -> Term {
    Term::new(|_x| Term::new(|y| y))
}

// NOT = λb.b FALSE TRUE
fn church_not() -> Term {
    Term::new(|boolean| boolean.apply(church_false()).apply(church_true()))
}

// AND = λp.λq.p q FALSE
fn church_and() -> Term {
    Term::new(|left| Term::new(move |right| left.apply(right).apply(church_false())))
}

// OR = λp.λq.p TRUE q
fn church_or() -> Term {
    Term::new(|left| Term::new(move |right| left.apply(church_true()).apply(right)))
}

// ZERO = λf.λx.x
fn zero() -> Term {
    Term::new(|_function| Term::new(|value| value))
}

// SUCC = λn.λf.λx.f (n f x)
fn successor() -> Term {
    Term::new(|numeral| {
        Term::new(move |function| {
            let numeral = numeral.clone();

            Term::new(move |value| {
                let previous = numeral.apply(function.clone()).apply(value);
                function.apply(previous)
            })
        })
    })
}

// PRED = λn.λf.λx.
//          n (λg.λh.h (g f)) (λu.x) (λu.u)
fn predecessor() -> Term {
    Term::new(|numeral| {
        Term::new(move |function| {
            let numeral = numeral.clone();

            Term::new(move |value| {
                let function_for_step = function.clone();
                let step = Term::new(move |g| {
                    let function = function_for_step.clone();
                    Term::new(move |h| h.apply(g.apply(function.clone())))
                });

                let constant = {
                    let value = value.clone();
                    Term::new(move |_unused| value.clone())
                };
                let identity = Term::new(|term| term);

                numeral.apply(step).apply(constant).apply(identity)
            })
        })
    })
}

fn one() -> Term {
    successor().apply(zero())
}

// The observers below exist only to turn encoded values into printable Rust
// values. None of the encodings or operations use Rust bools or integers.
fn church_to_bool(boolean: Term) -> bool {
    let when_true = Term::new(|term| term);
    let when_false = Term::new(|term| term);
    let selected = boolean.apply(when_true.clone()).apply(when_false.clone());

    if selected.is_same_term_as(&when_true) {
        true
    } else if selected.is_same_term_as(&when_false) {
        false
    } else {
        panic!("a Church boolean did not select either argument")
    }
}

fn church_to_usize(numeral: Term) -> usize {
    let applications = Rc::new(Cell::new(0));
    let count = applications.clone();
    let increment = Term::new(move |term| {
        count.set(count.get() + 1);
        term
    });
    let seed = Term::new(|term| term);

    numeral.apply(increment).apply(seed);
    applications.get()
}

fn check_bool(label: &str, boolean: Term, expected: bool) {
    let actual = church_to_bool(boolean);
    assert_eq!(actual, expected, "{label}");
    println!("{label}: {actual}");
}

fn check_numeral(label: &str, numeral: Term, expected: usize) {
    let actual = church_to_usize(numeral);
    assert_eq!(actual, expected, "{label}");
    println!("{label}: {actual}");
}

fn main() {
    println!("CHURCH BOOLEANS");
    check_bool("TRUE", church_true(), true);
    check_bool("FALSE", church_false(), false);
    check_bool("NOT TRUE", church_not().apply(church_true()), false);
    check_bool("NOT FALSE", church_not().apply(church_false()), true);
    check_bool(
        "FALSE AND FALSE",
        church_and().apply(church_false()).apply(church_false()),
        false,
    );
    check_bool(
        "FALSE AND TRUE",
        church_and().apply(church_false()).apply(church_true()),
        false,
    );
    check_bool(
        "TRUE AND FALSE",
        church_and().apply(church_true()).apply(church_false()),
        false,
    );
    check_bool(
        "TRUE AND TRUE",
        church_and().apply(church_true()).apply(church_true()),
        true,
    );
    check_bool(
        "FALSE OR FALSE",
        church_or().apply(church_false()).apply(church_false()),
        false,
    );
    check_bool(
        "FALSE OR TRUE",
        church_or().apply(church_false()).apply(church_true()),
        true,
    );
    check_bool(
        "TRUE OR FALSE",
        church_or().apply(church_true()).apply(church_false()),
        true,
    );
    check_bool(
        "TRUE OR TRUE",
        church_or().apply(church_true()).apply(church_true()),
        true,
    );

    println!("CHURCH NUMERALS");
    check_numeral("ZERO", zero(), 0);
    check_numeral("ONE", one(), 1);
    check_numeral("SUCC ONE", successor().apply(one()), 2);
    check_numeral("PRED ZERO", predecessor().apply(zero()), 0);
    check_numeral("PRED ONE", predecessor().apply(one()), 0);
    check_numeral(
        "PRED (SUCC ONE)",
        predecessor().apply(successor().apply(one())),
        1,
    );
}
