# TinyCC [![build status][TRAVISIMG]][TRAVIS]

The Tiny C Compiler


### Synopsis

```
    use TinyCC *;

    tcc.define(NAME => '"cygx"');
    tcc.compile(q:to/__END__/).run;
        int puts(const char *);
        int main(void) {
            puts("Hello, " NAME "!");
            return 0;
        }
        __END__
```

```
    use TinyCC;

    TinyCC.new.target(:EXE).compile(q:to/__END__/).dump('42.exe');
        int main(void) { return 42; }
        __END__

    run('./42.exe');
```

```
    use TinyCC::Eval;
    use TinyCC::Types;

    my $out = cval(uint64);

    EVAL q:to/__END__/, :lang<C>, init => { .define: N => 42; .declare: :$out };
        extern unsigned long long out;

        static unsigned long long fib(unsigned n) {
            return n < 2 ? n : fib(n - 1) + fib(n - 2);
        }

        int main(void) {
            out = fib(N);
            return 0;
        }
        __END__

    say $out.deref;
```

```
    use TinyCC::CFunc;

    sub forty-two(--> int) is cfunc('return 42;') {*}

    sub plus(int \a, int \b --> int) is cfunc({ q:to/__END__/ }) {*}
        return a + b;
        __END__

    say plus(1, forty-two);
```

```
    use TinyCC::CCall;

    sub abort is ccall {*}
    abort;
```


### Description

The TinyCC C codebase can be found [in this repository][TINYCC]. A properly
installed compiler should be recognized out of the box. If you want to use
the compiler without installation, set the environment vars `LIBTCC` and
`TCCROOT` appropriately or configure these at runtime via

    use TinyCC {
        .load: <candidate/path/one/to/libtcc candidate/path/two/to/libtcc>;
        .setroot: 'path/to/tcc/build/dir';
    };

As the author is notoriously bad at writing documentation, for now you
have to look at [the tests][TESTS] or even [the module source][MODSOURCE]
to see what is or is not implemented.


### Known Issues

Rakudo's `NativeCall` interacts badly with precompilation, so the module's
bytecode size and startup time leave something to be desired.

Passing a block to the `use` statement is nice in principle, but
problematic in practice: Any named argument occurring within gets silently
adjusted to a positional one. You can work around this by either promoting
the block to a `sub (@_) { ... }` or by adding list interpolation to any
named argument, ie use `|:arg` instead of plain `:arg`.


### Bugs and Development

Development happens [at GitHub][SOURCE]. If you found a bug or have a feature
request, use the [issue tracker][ISSUES] over there.


### Copyright and License

Copyright (C) 2015 by <cygx@cpan.org>

Distributed under the [Boost Software License, Version 1.0][LICENSE]


[TRAVIS]:       https://travis-ci.org/cygx/p6-tinycc
[TRAVISIMG]:    https://travis-ci.org/cygx/p6-tinycc.svg?branch=master
[TINYCC]:       http://repo.or.cz/tinycc.git
[SOURCE]:       https://github.com/cygx/p6-tinycc
[ISSUES]:       https://github.com/cygx/p6-tinycc/issues
[LICENSE]:      http://www.boost.org/LICENSE_1_0.txt
[TESTS]:        https://github.com/cygx/p6-tinycc/tree/master/t
[MODSOURCE]:    https://github.com/cygx/p6-tinycc/tree/master/lib
