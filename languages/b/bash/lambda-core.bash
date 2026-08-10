#!/usr/bin/env bash
set -euo pipefail

# Church booleans are selectors. Bash has no first-class function values, so
# the name of a Bash function stands in for the function itself.
church_true() {
    printf '%s\n' "$1"
}

church_false() {
    printf '%s\n' "$2"
}

church_not() {
    local boolean=$1
    "$boolean" church_false church_true
}

church_and() {
    local first=$1
    local second=$2
    "$first" "$second" church_false
}

church_or() {
    local first=$1
    local second=$2
    "$first" church_true "$second"
}

read_bool() {
    local boolean=$1
    "$boolean" 'BOOLEAN TRUE' 'BOOLEAN FALSE'
}

# A Church numeral receives a function and a starting value, then applies that
# function a particular number of times. Function names again stand in for
# function values.
church_zero() {
    : "$1"
    printf '%s\n' "$2"
}

church_succ() {
    local numeral=$1
    local function=$2
    local value=$3
    local previous

    previous=$("$numeral" "$function" "$value")
    "$function" "$previous"
}

# ONE is derived from SUCC ZERO. TWO is a convenient name used by the PRED
# example below.
church_one() {
    church_succ church_zero "$@"
}

church_two() {
    church_succ church_one "$@"
}

church_increment() {
    printf '%s\n' "$(( $1 + 1 ))"
}

# PRED uses the usual "remember the previous value" idea. Its state is a pair
# written as previous:current. Each numeral application changes (a, b) into
# (b, f(b)); selecting the first value after n steps gives n - 1 applications.
# Bash variables are dynamically scoped, so church_pred_step can see the
# function selected by church_pred without using eval or creating source code.
church_pred_step() {
    local state=$1
    local current=${state#*:}
    local next

    next=$("$pred_function" "$current")
    printf '%s:%s\n' "$current" "$next"
}

church_pred() {
    local numeral=$1
    local pred_function=$2
    local value=$3
    local state

    state=$("$numeral" church_pred_step "$value:$value")
    printf '%s\n' "${state%%:*}"
}

# The arguments to read_church form a Bash command: either a numeral function
# by itself or an operation followed by its already supplied numeral argument.
read_church() {
    local -a numeral=("$@")
    "${numeral[@]}" church_increment 0
}

# Boolean examples: constants, NOT, and complete AND/OR truth tables.
read_bool church_true
read_bool church_false

read_bool "$(church_not church_true)"
read_bool "$(church_not church_false)"

read_bool "$(church_and church_false church_false)"
read_bool "$(church_and church_true church_false)"
read_bool "$(church_and church_false church_true)"
read_bool "$(church_and church_true church_true)"

read_bool "$(church_or church_false church_false)"
read_bool "$(church_or church_true church_false)"
read_bool "$(church_or church_false church_true)"
read_bool "$(church_or church_true church_true)"

# Numeral examples: ZERO, ONE = SUCC ZERO, SUCC ONE, and predecessor at and
# above the zero boundary.
read_church church_zero
read_church church_one
read_church church_succ church_one
read_church church_pred church_two
read_church church_pred church_one
read_church church_pred church_zero
