final class Term {
  const Term(this._function);

  final Term Function(Term) _function;

  Term call(Term argument) => _function(argument);
}

Term lambda(Term Function(Term) function) => Term(function);

// TRUE = lambda x. lambda y. x
Term churchTrue() => lambda((x) => lambda((_) => x));

// FALSE = lambda x. lambda y. y
Term churchFalse() => lambda((_) => lambda((y) => y));

// NOT = lambda b. b FALSE TRUE
Term churchNot() => lambda((boolean) => boolean(churchFalse())(churchTrue()));

// AND = lambda p. lambda q. p q FALSE
Term churchAnd() =>
    lambda((left) => lambda((right) => left(right)(churchFalse())));

// OR = lambda p. lambda q. p TRUE q
Term churchOr() =>
    lambda((left) => lambda((right) => left(churchTrue())(right)));

// ZERO = lambda f. lambda x. x
Term zero() => lambda((_) => lambda((value) => value));

// SUCC = lambda n. lambda f. lambda x. f (n f x)
Term successor() => lambda(
  (numeral) => lambda(
    (function) => lambda((value) => function(numeral(function)(value))),
  ),
);

// PRED = lambda n. lambda f. lambda x.
//          n (lambda g. lambda h. h (g f)) (lambda u. x) (lambda a. a)
Term predecessor() => lambda(
  (numeral) => lambda(
    (function) => lambda((value) {
      final step = lambda((g) => lambda((h) => h(g(function))));
      final seed = lambda((_) => value);
      final identity = lambda((term) => term);
      return numeral(step)(seed)(identity);
    }),
  ),
);

Term one() => successor()(zero());

// These observers are the only code that converts terms to native values.
bool churchToBool(Term boolean) {
  final whenTrue = lambda((term) => term);
  final whenFalse = lambda((term) => term);
  final selected = boolean(whenTrue)(whenFalse);

  if (identical(selected, whenTrue)) {
    return true;
  }
  if (identical(selected, whenFalse)) {
    return false;
  }
  throw StateError('a Church boolean did not select either argument');
}

int churchToInt(Term numeral) {
  var applications = 0;
  final increment = lambda((term) {
    applications += 1;
    return term;
  });
  final seed = lambda((term) => term);
  numeral(increment)(seed);
  return applications;
}

void checkBoolean(String label, Term boolean, bool expected) {
  final actual = churchToBool(boolean);
  if (actual != expected) {
    throw StateError('$label: expected $expected, got $actual');
  }
  print('$label: $actual');
}

void checkNumeral(String label, Term numeral, int expected) {
  final actual = churchToInt(numeral);
  if (actual != expected) {
    throw StateError('$label: expected $expected, got $actual');
  }
  print('$label: $actual');
}

void main() {
  print('CHURCH BOOLEANS');
  checkBoolean('TRUE', churchTrue(), true);
  checkBoolean('FALSE', churchFalse(), false);
  checkBoolean('NOT TRUE', churchNot()(churchTrue()), false);
  checkBoolean('NOT FALSE', churchNot()(churchFalse()), true);
  checkBoolean(
    'FALSE AND FALSE',
    churchAnd()(churchFalse())(churchFalse()),
    false,
  );
  checkBoolean(
    'FALSE AND TRUE',
    churchAnd()(churchFalse())(churchTrue()),
    false,
  );
  checkBoolean(
    'TRUE AND FALSE',
    churchAnd()(churchTrue())(churchFalse()),
    false,
  );
  checkBoolean('TRUE AND TRUE', churchAnd()(churchTrue())(churchTrue()), true);
  checkBoolean(
    'FALSE OR FALSE',
    churchOr()(churchFalse())(churchFalse()),
    false,
  );
  checkBoolean('FALSE OR TRUE', churchOr()(churchFalse())(churchTrue()), true);
  checkBoolean('TRUE OR FALSE', churchOr()(churchTrue())(churchFalse()), true);
  checkBoolean('TRUE OR TRUE', churchOr()(churchTrue())(churchTrue()), true);

  print('CHURCH NUMERALS');
  checkNumeral('ZERO', zero(), 0);
  checkNumeral('ONE', one(), 1);
  checkNumeral('SUCC ONE', successor()(one()), 2);
  checkNumeral('SUCC (SUCC ONE)', successor()(successor()(one())), 3);
  checkNumeral('PRED ZERO', predecessor()(zero()), 0);
  checkNumeral('PRED ONE', predecessor()(one()), 0);
  checkNumeral('PRED (SUCC ONE)', predecessor()(successor()(one())), 1);
  checkNumeral(
    'PRED (SUCC (SUCC ONE))',
    predecessor()(successor()(successor()(one()))),
    2,
  );
}
