#!/bin/sh
# check.sh — compile fibonacci.cc and check what it prints for a few piped inputs.
#
# Characterization only. Every expectation below is what the program was observed to print
# in the Build workflow (run 33973065983, commit 20bfe97, g++ 13.3.0 at -std=c++17 on
# Ubuntu 24.04), including the cases that are open bugs. A case that starts failing means
# the behavior changed: update the expectation deliberately, in the same change, rather
# than weakening it to pass.
#
# Usage: sh check.sh
# Exits 0 when every case passes, 1 when any fails, and 0 with a SKIP line when no C++
# compiler is found. Never builds to ./fibonacci, which is a tracked file.

set -u

CXX=
for candidate in g++ c++ clang++
do
    if command -v "$candidate" > /dev/null 2>&1
    then
        CXX=$candidate
        break
    fi
done
if [ -z "$CXX" ]
then
    echo "SKIP: no C++ compiler (tried g++, c++, clang++)"
    exit 0
fi

BIN=./fibonacci-check
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

PROMPT='How many numbers of the Fibonacci Sequence would you like to see? (Between 2 and 47)'
failures=0

# Build with the flags documented in README.md, to a scratch name that .gitignore covers.
# The tree is warning-clean today, so any warning is treated as a failure.
echo "compiler: $CXX"
if ! "$CXX" -std=c++17 -Wall -Wextra -o "$BIN" fibonacci.cc 2> "$TMP/build-err"
then
    echo "FAIL: build"
    cat "$TMP/build-err"
    exit 1
fi
if [ -s "$TMP/build-err" ]
then
    echo "FAIL: build produced warnings"
    cat "$TMP/build-err"
    exit 1
fi
echo "build OK"

# run INPUT — pipe INPUT into the program, capturing stdout, stderr, and the exit status.
run()
{
    printf '%s\n' "$1" | timeout 10 "$BIN" > "$TMP/out" 2> "$TMP/err"
    status=$?
}

# check INPUT NUMBER... — assert that INPUT prints the prompt, a blank line, then exactly the
# given numbers one per line, with exit status 0 and nothing on stderr.
check()
{
    input=$1
    shift
    expected=$(printf '%s\n' "$PROMPT" '' "$@")
    run "$input"
    actual=$(cat "$TMP/out")
    if [ "$status" -eq 0 ] && [ "$actual" = "$expected" ] && [ ! -s "$TMP/err" ]
    then
        echo "PASS: input $input"
    else
        echo "FAIL: input $input (exit status $status)"
        echo "--- expected stdout ---"
        echo "$expected"
        echo "--- actual stdout ---"
        echo "$actual"
        echo "--- stderr ---"
        cat "$TMP/err"
        failures=$((failures + 1))
    fi
}

# Typical count and the lower bound of the advertised range.
check 10 0 1 1 2 3 5 8 13 21 34
check 2 0 1

# Counts below the advertised range, and non-numeric input, all print two numbers with no
# error and exit status 0. That is the current behavior, not the intended one — see #4 and #5.
check 1 0 1
check 0 0 1
check -5 0 1
check abc 0 1

# The advertised ceiling. 1836311903 is the last value that fits in the int accumulator.
check 47 0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 \
    10946 17711 28657 46368 75025 121393 196418 317811 514229 832040 1346269 2178309 \
    3524578 5702887 9227465 14930352 24157817 39088169 63245986 102334155 165580141 \
    267914296 433494437 701408733 1134903170 1836311903

# The two remaining cases are undefined behavior, so nothing is asserted about them; the
# output is recorded so the log still shows what this build did. A count of 48 overflows the
# int accumulator (#6); end-of-file leaves the count unassigned (#11) and has printed a
# different number of lines on every run so far.
observe()
{
    echo "--- observed: $1 (not asserted) ---"
    echo "exit status: $status"
    echo "stdout ($(wc -l < "$TMP/out" | tr -d ' ') lines), last 3 lines:"
    tail -n 3 "$TMP/out"
    echo "stderr ($(wc -c < "$TMP/err" | tr -d ' ') bytes)"
}

run 48
observe "input 48"

timeout 10 "$BIN" < /dev/null > "$TMP/out" 2> "$TMP/err"
status=$?
observe "end-of-file"

if [ "$failures" -ne 0 ]
then
    echo "FAILED: $failures case(s)"
    exit 1
fi
echo "all cases passed"
