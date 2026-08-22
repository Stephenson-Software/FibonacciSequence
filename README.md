# FibonacciSequence

A simple C++ program that asks how many numbers of the Fibonacci Sequence you want to see, then
prints that many numbers, one per line. Counts outside the advertised range are not rejected — see
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

## Committed binary

A prebuilt `fibonacci` executable is tracked at the repository root. It is an x86-64 Linux ELF
binary, so it will not run on macOS, Windows, or ARM machines, and nothing keeps it in sync with
`fibonacci.cc`. Whether it should remain tracked is under discussion in
[#3](https://github.com/Stephenson-Software/FibonacciSequence/issues/3); building from source is
recommended in the meantime.

## Known limitations

These are read from the source and are tracked as issues:

- The `(Between 2 and 47)` range printed by the prompt is not enforced anywhere in the code —
  [#4](https://github.com/Stephenson-Software/FibonacciSequence/issues/4).
- The state of `cin` is never checked after the count is read, so non-numeric input and end-of-file
  are not detected, nothing is written to standard error, and the exit status is always 0 —
  [#5](https://github.com/Stephenson-Software/FibonacciSequence/issues/5).
- The accumulators are `int`, so a large enough count overflows —
  [#6](https://github.com/Stephenson-Software/FibonacciSequence/issues/6).

## License

Stephenson Software Non-Commercial License (Stephenson-NC). See [LICENSE](LICENSE).
