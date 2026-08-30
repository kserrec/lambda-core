#!/usr/bin/env bash
set -euo pipefail

# Bash functions are not first-class values and do not form lexical closures.
# This tiny runtime represents a lambda term with an opaque ID. Associative
# arrays attach a handler and up to two captured terms to each ID, letting the
# handlers below implement curried application without eval or generated code.
declare -A term_handler=()
declare -A term_a=()
declare -A term_b=()

next_term=0
result=

new_term() {
    local handler=$1
    local captured_a=${2-}
    local captured_b=${3-}

    next_term=$((next_term + 1))
    result="term_$next_term"
    term_handler["$result"]=$handler
    term_a["$result"]=$captured_a
    term_b["$result"]=$captured_b
}

apply() {
    local term=$1
    local argument=$2
    local handler=${term_handler["$term"]-}

    if [[ -z $handler ]]; then
        printf 'cannot apply unknown term: %s\n' "$term" >&2
        return 1
    fi

    "$handler" "$term" "$argument"
}

apply_two() {
    local term=$1
    local first=$2
    local second=$3

    apply "$term" "$first"
    local partial=$result
    apply "$partial" "$second"
}

# TRUE = λx.λy.x
make_true() {
    new_term true_first
}

true_first() {
    local selected=$2
    new_term constant_second "$selected"
}

constant_second() {
    local self=$1
    result=${term_a["$self"]}
}

# FALSE = λx.λy.y
make_false() {
    new_term false_first
}

false_first() {
    new_term identity
}

identity() {
    result=$2
}

# NOT = λb.b FALSE TRUE
make_not() {
    local false_term=$1
    local true_term=$2
    new_term not_boolean "$false_term" "$true_term"
}

not_boolean() {
    local self=$1
    local boolean=$2

    apply_two "$boolean" "${term_a["$self"]}" "${term_b["$self"]}"
}

# AND = λp.λq.p q FALSE
make_and() {
    local false_term=$1
    new_term and_left "$false_term"
}

and_left() {
    local self=$1
    local left=$2
    new_term and_right "$left" "${term_a["$self"]}"
}

and_right() {
    local self=$1
    local right=$2
    apply_two "${term_a["$self"]}" "$right" "${term_b["$self"]}"
}

# OR = λp.λq.p TRUE q
make_or() {
    local true_term=$1
    new_term or_left "$true_term"
}

or_left() {
    local self=$1
    local left=$2
    new_term or_right "$left" "${term_a["$self"]}"
}

or_right() {
    local self=$1
    local right=$2
    apply_two "${term_a["$self"]}" "${term_b["$self"]}" "$right"
}

# ZERO = λf.λx.x
make_zero() {
    new_term zero_function
}

zero_function() {
    new_term identity
}

# SUCC = λn.λf.λx.f (n f x)
make_successor() {
    new_term successor_numeral
}

successor_numeral() {
    local numeral=$2
    new_term successor_function "$numeral"
}

successor_function() {
    local self=$1
    local function=$2
    new_term successor_value "${term_a["$self"]}" "$function"
}

successor_value() {
    local self=$1
    local value=$2
    local numeral=${term_a["$self"]}
    local function=${term_b["$self"]}

    apply_two "$numeral" "$function" "$value"
    local inner=$result
    apply "$function" "$inner"
}

# PRED = λn.λf.λx.n (λg.λh.h (g f)) (λu.x) (λa.a)
make_predecessor() {
    new_term predecessor_numeral
}

predecessor_numeral() {
    local numeral=$2
    new_term predecessor_function "$numeral"
}

predecessor_function() {
    local self=$1
    local function=$2
    new_term predecessor_value "${term_a["$self"]}" "$function"
}

predecessor_value() {
    local self=$1
    local value=$2
    local numeral=${term_a["$self"]}
    local function=${term_b["$self"]}

    new_term predecessor_step_g "$function"
    local step=$result
    new_term constant_second "$value"
    local seed=$result
    new_term identity
    local identity_term=$result

    apply "$numeral" "$step"
    local at_step=$result
    apply "$at_step" "$seed"
    local at_seed=$result
    apply "$at_seed" "$identity_term"
}

predecessor_step_g() {
    local self=$1
    local g=$2
    new_term predecessor_step_h "$g" "${term_a["$self"]}"
}

predecessor_step_h() {
    local self=$1
    local h=$2

    apply "${term_a["$self"]}" "${term_b["$self"]}"
    local g_at_function=$result
    apply "$h" "$g_at_function"
}

# Observers use markers and a counter; the core terms above do not use native
# booleans or integer numeral values.
marker() {
    printf 'marker terms are not callable\n' >&2
    return 1
}

church_to_bool() {
    local boolean=$1

    new_term marker
    local true_marker=$result
    new_term marker
    local false_marker=$result

    apply_two "$boolean" "$true_marker" "$false_marker"
    local selected=$result

    if [[ $selected == "$true_marker" ]]; then
        result=true
    elif [[ $selected == "$false_marker" ]]; then
        result=false
    else
        printf 'a Church boolean did not select either argument\n' >&2
        return 1
    fi
}

application_count=0

increment_counter() {
    application_count=$((application_count + 1))
    result=$2
}

church_to_int() {
    local numeral=$1

    application_count=0
    new_term increment_counter
    local increment=$result
    new_term marker
    local seed=$result

    apply_two "$numeral" "$increment" "$seed"
    result=$application_count
}

check_boolean() {
    local label=$1
    local boolean=$2
    local expected=$3

    church_to_bool "$boolean"
    local actual=$result
    if [[ $actual != "$expected" ]]; then
        printf '%s: expected %s, got %s\n' "$label" "$expected" "$actual" >&2
        return 1
    fi

    printf '%s: %s\n' "$label" "$actual"
}

check_numeral() {
    local label=$1
    local numeral=$2
    local expected=$3

    church_to_int "$numeral"
    local actual=$result
    if [[ $actual != "$expected" ]]; then
        printf '%s: expected %s, got %s\n' "$label" "$expected" "$actual" >&2
        return 1
    fi

    printf '%s: %s\n' "$label" "$actual"
}

make_true
church_true=$result
make_false
church_false=$result
make_not "$church_false" "$church_true"
church_not=$result
make_and "$church_false"
church_and=$result
make_or "$church_true"
church_or=$result
make_zero
zero=$result
make_successor
successor=$result
make_predecessor
predecessor=$result
apply "$successor" "$zero"
one=$result

printf 'CHURCH BOOLEANS\n'
check_boolean 'TRUE' "$church_true" true
check_boolean 'FALSE' "$church_false" false
apply "$church_not" "$church_true"
check_boolean 'NOT TRUE' "$result" false
apply "$church_not" "$church_false"
check_boolean 'NOT FALSE' "$result" true
apply_two "$church_and" "$church_false" "$church_false"
check_boolean 'FALSE AND FALSE' "$result" false
apply_two "$church_and" "$church_false" "$church_true"
check_boolean 'FALSE AND TRUE' "$result" false
apply_two "$church_and" "$church_true" "$church_false"
check_boolean 'TRUE AND FALSE' "$result" false
apply_two "$church_and" "$church_true" "$church_true"
check_boolean 'TRUE AND TRUE' "$result" true
apply_two "$church_or" "$church_false" "$church_false"
check_boolean 'FALSE OR FALSE' "$result" false
apply_two "$church_or" "$church_false" "$church_true"
check_boolean 'FALSE OR TRUE' "$result" true
apply_two "$church_or" "$church_true" "$church_false"
check_boolean 'TRUE OR FALSE' "$result" true
apply_two "$church_or" "$church_true" "$church_true"
check_boolean 'TRUE OR TRUE' "$result" true

printf 'CHURCH NUMERALS\n'
check_numeral 'ZERO' "$zero" 0
check_numeral 'ONE' "$one" 1
apply "$successor" "$one"
two=$result
check_numeral 'SUCC ONE' "$two" 2
apply "$successor" "$two"
three=$result
check_numeral 'SUCC (SUCC ONE)' "$three" 3
apply "$predecessor" "$zero"
check_numeral 'PRED ZERO' "$result" 0
apply "$predecessor" "$one"
check_numeral 'PRED ONE' "$result" 0
apply "$predecessor" "$two"
check_numeral 'PRED (SUCC ONE)' "$result" 1
apply "$predecessor" "$three"
check_numeral 'PRED (SUCC (SUCC ONE))' "$result" 2
