# FibonacciSequence

A simple C++ program that asks how many numbers of the Fibonacci Sequence you want to see, then
prints that many numbers, one per line. Counts outside the advertised range are not rejected, and a
count below two still prints two numbers — see [Example](#example) and
[Known limitations](#known-limitations).

The whole program is a single 23-line file, `fibonacci.cc`. It is a teaching exercise, and it is
meant to stay small enough to read top to bottom in one sitting.

## Building

The program has no dependencies beyond the C++ standard library and no build system. One compiler
invocation is enough:

```sh
g++ -std=c++17 -Wall -Wextra -o fibonacci-build fibonacci.cc
```

The source uses no features newer than C++03, so a different `-std` flag also works.

The output name `fibonacci-build` is deliberate: a compiled binary named `fibonacci` is already
tracked in this repository (see [Committed binary](#committed-binary) below), and building to that
name would overwrite it. `fibonacci-build` is covered by `.gitignore`.

## Running

The program reads one number — how many values of the sequence to print — from standard input:

```sh
./fibonacci-build
```

It can also be driven non-interactively by piping the count in:

```sh
printf '10\n' | ./fibonacci-build
```

Note that the program blocks waiting for input if standard input is a terminal and nothing is typed,
so scripted invocations should always pipe a value in.

## Example

Everything in this section was captured from workflow run
[33031826885](https://github.com/Stephenson-Software/FibonacciSequence/actions/runs/33031826885),
which built commit `4af17de` with `g++ -std=c++17 -Wall -Wextra` (g++ 13.3.0 on Ubuntu 24.04) and
ran the result with each input piped in. No value below was computed by hand. That build produced no
compiler warnings.

Asking for ten numbers:

```
$ printf '10\n' | ./fibonacci-build
How many numbers of the Fibonacci Sequence would you like to see? (Between 2 and 47)

0
1
1
2
3
5
8
13
21
34
```

The prompt is written to standard output, not to standard error, and a blank line separates it from
the sequence — so anything parsing this output has to skip two lines before the first number.

### What other inputs did

The same run also observed the counts below. In every one of these cases the exit status was `0` and
nothing at all was written to standard error, including for the inputs the program cannot use.

| Input | Lines on stdout | Numbers printed | Last number printed |
|-------|-----------------|-----------------|---------------------|
| `47` | 49 | 47 | `1836311903` |
| `10` | 12 | 10 | `34` |
| `2` | 4 | 2 | `1` |
| `1` | 4 | 2 | `1` |
| `0` | 4 | 2 | `1` |
| `-5` | 4 | 2 | `1` |
| `abc` | 4 | 2 | `1` |
| `48` | 50 | 48 | `-1323752223` |
| end-of-file | 32766 | 32764 | not recorded |

Three of those rows are worth reading twice:

- **`1`, `0`, `-5`, and `abc` all print two numbers.** The seed values `0` and `1` are printed before
  the loop is entered and are not conditional on the count, so asking for fewer than two numbers —
  or for no valid number at all — still prints two, and the program reports no error while doing it.
- **`48` printed a negative number.** The accumulators are `int`, so the addition past the
  advertised ceiling of 47 overflows. That is undefined behavior rather than merely a wrong value,
  and `-1323752223` is what this one build on this one machine happened to produce. It is not a
  result to rely on.
- **End-of-file printed tens of thousands of lines.** An earlier run of the same workflow,
  [32822432007](https://github.com/Stephenson-Software/FibonacciSequence/actions/runs/32822432007),
  printed 32,769 lines for this input rather than 32,766. The count is never assigned when the
  stream is already at end-of-file, so the loop bound comes from whatever occupied that storage —
  which is why the two runs disagree.

## Committed binary

A prebuilt `fibonacci` executable is tracked at the repository root. It is an x86-64 Linux ELF
binary, so it will not run on macOS, Windows, or ARM machines, and nothing keeps it in sync with
`fibonacci.cc`. Whether it should remain tracked is under discussion in
[#3](https://github.com/Stephenson-Software/FibonacciSequence/issues/3); building from source is
recommended in the meantime.

## Known limitations

These are read from the source, confirmed by the run quoted in [Example](#example), and tracked as
issues:

- The `(Between 2 and 47)` range printed by the prompt is not enforced anywhere in the code —
  [#4](https://github.com/Stephenson-Software/FibonacciSequence/issues/4).
- The state of `cin` is never checked after the count is read, so non-numeric input is not detected,
  nothing is written to standard error, and the exit status is always 0 —
  [#5](https://github.com/Stephenson-Software/FibonacciSequence/issues/5).
- The accumulators are `int`, so a large enough count overflows —
  [#6](https://github.com/Stephenson-Software/FibonacciSequence/issues/6).
- The count is never assigned when standard input is already at end-of-file, and reading it anyway
  is undefined behavior — [#11](https://github.com/Stephenson-Software/FibonacciSequence/issues/11).

## License

Stephenson Software Non-Commercial License (Stephenson-NC). See [LICENSE](LICENSE).
