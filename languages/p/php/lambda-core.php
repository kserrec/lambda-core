<?php

declare(strict_types=1);

// TRUE = λx.λy.x
$churchTrue = fn(mixed $x): Closure => fn(mixed $_y): mixed => $x;

// FALSE = λx.λy.y
$churchFalse = fn(mixed $_x): Closure => fn(mixed $y): mixed => $y;

// NOT = λb.b FALSE TRUE
$churchNot = fn(Closure $boolean): mixed =>
    $boolean($churchFalse)($churchTrue);

// AND = λp.λq.p q FALSE
$churchAnd = fn(Closure $left): Closure =>
    fn(Closure $right): mixed => $left($right)($churchFalse);

// OR = λp.λq.p TRUE q
$churchOr = fn(Closure $left): Closure =>
    fn(Closure $right): mixed => $left($churchTrue)($right);

// ZERO = λf.λx.x
$zero = fn(Closure $_function): Closure => fn(mixed $value): mixed => $value;

// SUCC = λn.λf.λx.f (n f x)
$successor = fn(Closure $numeral): Closure =>
    fn(Closure $function): Closure =>
        fn(mixed $value): mixed =>
            $function($numeral($function)($value));

// PRED = λn.λf.λx.n (λg.λh.h (g f)) (λu.x) (λa.a)
$predecessor = fn(Closure $numeral): Closure =>
    fn(Closure $function): Closure =>
        fn(mixed $value): mixed =>
            $numeral(
                fn(Closure $g): Closure =>
                    fn(Closure $h): mixed => $h($g($function))
            )(fn(mixed $_u): mixed => $value)(fn(mixed $a): mixed => $a);

$one = $successor($zero);

// These observers are the only code that converts terms to native values.
function churchToBool(Closure $boolean): bool
{
    return $boolean(true)(false);
}

function churchToInt(Closure $numeral): int
{
    return $numeral(fn(int $value): int => $value + 1)(0);
}

function checkBoolean(string $label, Closure $boolean, bool $expected): void
{
    $actual = churchToBool($boolean);
    if ($actual !== $expected) {
        throw new RuntimeException(
            sprintf('%s: expected %s, got %s', $label, $expected ? 'true' : 'false', $actual ? 'true' : 'false')
        );
    }

    printf("%s: %s\n", $label, $actual ? 'true' : 'false');
}

function checkNumeral(string $label, Closure $numeral, int $expected): void
{
    $actual = churchToInt($numeral);
    if ($actual !== $expected) {
        throw new RuntimeException(
            sprintf('%s: expected %d, got %d', $label, $expected, $actual)
        );
    }

    printf("%s: %d\n", $label, $actual);
}

echo "CHURCH BOOLEANS\n";
checkBoolean('TRUE', $churchTrue, true);
checkBoolean('FALSE', $churchFalse, false);
checkBoolean('NOT TRUE', $churchNot($churchTrue), false);
checkBoolean('NOT FALSE', $churchNot($churchFalse), true);
checkBoolean('FALSE AND FALSE', $churchAnd($churchFalse)($churchFalse), false);
checkBoolean('FALSE AND TRUE', $churchAnd($churchFalse)($churchTrue), false);
checkBoolean('TRUE AND FALSE', $churchAnd($churchTrue)($churchFalse), false);
checkBoolean('TRUE AND TRUE', $churchAnd($churchTrue)($churchTrue), true);
checkBoolean('FALSE OR FALSE', $churchOr($churchFalse)($churchFalse), false);
checkBoolean('FALSE OR TRUE', $churchOr($churchFalse)($churchTrue), true);
checkBoolean('TRUE OR FALSE', $churchOr($churchTrue)($churchFalse), true);
checkBoolean('TRUE OR TRUE', $churchOr($churchTrue)($churchTrue), true);

echo "CHURCH NUMERALS\n";
checkNumeral('ZERO', $zero, 0);
checkNumeral('ONE', $one, 1);
checkNumeral('SUCC ONE', $successor($one), 2);
checkNumeral('SUCC (SUCC ONE)', $successor($successor($one)), 3);
checkNumeral('PRED ZERO', $predecessor($zero), 0);
checkNumeral('PRED ONE', $predecessor($one), 0);
checkNumeral('PRED (SUCC ONE)', $predecessor($successor($one)), 1);
checkNumeral('PRED (SUCC (SUCC ONE))', $predecessor($successor($successor($one))), 2);
