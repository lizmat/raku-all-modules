# NQP::Eval [![build status][TRAVISIMG]][TRAVIS]

Enables `EVAL :lang<nqp>`

```
    use NQP::Eval;
    EVAL :lang<nqp>, 'my int $i := 42; say($i)';
```


## Know Issues

Using `EVAL` at compile-time (ie inside a `BEGIN` block) breaks precompilation.
This is not specific to evaluating NQP, but a general Rakudo issue.


## Bugs and Development

Development happens [at GitHub][SOURCE]. If you found a bug or have a feature
request, use the [issue tracker][ISSUES] over there.


## Copyright and License

Copyright (C) 2015 by <cygx@cpan.org>

Distributed under the [Boost Software License, Version 1.0][LICENSE]


[TRAVIS]:       https://travis-ci.org/cygx/p6-nqp-eval
[TRAVISIMG]:    https://travis-ci.org/cygx/p6-nqp-eval.svg?branch=master
[SOURCE]:       https://github.com/cygx/p6-nqp-eval
[ISSUES]:       https://github.com/cygx/p6-nqp-eval/issues
[LICENSE]:      http://www.boost.org/LICENSE_1_0.txt
