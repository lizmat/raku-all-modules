[![Build Status](https://travis-ci.org/zoffixznet/perl6-Test-When.svg)](https://travis-ci.org/zoffixznet/perl6-Test-When)

# NAME

Test::When - Selectively run tests based on the environment and installed modules and libs

# TABLE OF CONTENTS
- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [UNIMPLEMENTED / SPEC](#unimplemented--spec)
- [DESCRIPTION](#description)
- [USAGE](#usage)
    - [Environmental Variable Controlled Tests](#environmental-variable-controlled-tests)
        - [`smoke`](#smoke)
        - [`interactive`](#interactive)
        - [`extended`](#extended)
        - [`release`](#release)
        - [`author`](#author)
        - [`online`](#online)
        - [Meaning of the Respected Environmental Variables](#meaning-of-the-respected-environmental-variables)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author-1)
- [LICENSE](#license)

# SYNOPSIS

```perl6
    use Test::When <release author>,
        :modules<Extra::Features  More::Options>,
        :libs( 'someClib', any(<sqlite3 mysql pg>) );
```

# UNIMPLEMENTED / SPEC

The `:modules` and `:libs` restrictions aren't yet implemented, but will
be soon. Checkout the [SPECIFICATION](SPECIFICATION.md) for details on what
they will do.

# DESCRIPTION

This module lets you write selective tests that will only run when user requested, say, network tests to run, or when the runner of the tests
explicitly requested any interactive tests to be avoided. These checks are
heavily based on the decisions by the [Lancaster Consensus](https://github.com/Perl-Toolchain-Gang/toolchain-site/blob/master/lancaster-consensus.md#environment-variables-for-testing-contexts)

*Currently unimplemented.* The module also allows run tests only when a
specific module or C library are installed. This is handy when your
module offers extra optional functionality dependent on extra stuff, for
example.

# USAGE

The type of tests your test file represents is specified on the `use` line
of `Test::When` module.

## Environmental Variable Controlled Tests

```perl6
    use Test::When <author extended>;
```

The type of test environment to look for is set by positional arguments
provided on the `use` line. Multiple positional arguments can be
combined. Whether your tests run depends on the set
environmental variables.

The following positional arguments are supported:

### `smoke`

```perl6
    use Test::When <smoke>;
```

Tests to run when either `AUTOMATED_TESTING` or `ALL_TESTING` env vars are true.

### `interactive`

```perl6
    use Test::When <interactive>;
```

Tests must **NOT** be run when `NONINTERACTIVE_TESTING` is set to true,
unless `ALL_TESTING` is also set to true.

### `extended`

```perl6
    use Test::When <extended>;
```

Tests to be run when either `EXTENDED_TESTING`, `RELEASE_TESTING`,
or `ALL_TESTING` env var is set to true.

### `release`

```perl6
    use Test::When <release>;
```

Tests to be run when `RELEASE_TESTING` or `ALL_TESTING` env var is set to true.

### `author`

```perl6
    use Test::When <author>;
```

Tests to be run when `AUTHOR_TESTING` or `ALL_TESTING` env var is set to true.

### `online`

```perl6
    use Test::When <online>;
```

Tests to be run when `ONLINE_TESTING` or `ALL_TESTING` env var is set to true.

### Meaning of the Respected Environmental Variables

* `AUTOMATED_TESTING`: if true, tests are being run by an automated testing facility and not as part of the installation of a module; CPAN smokers must set this to true; CPAN clients (e.g. `zef`) must not set this.

* `NONINTERACTIVE_TESTING`: if true, tests should not attempt to interact with a user; output may not be seen and prompts will not be answered.

* `EXTENDED_TESTING`: if true, the user or process running tests is willing to run optional tests that may take extra time or resources to complete. Such tests must not include any development or QA tests. Only tests of runtime functionality should be included.

* `RELEASE_TESTING`: if true, tests are being run as part of a release QA process; CPAN clients must not set this variable.

* `AUTHOR_TESTING`: if true, tests are being run as part of an author's personal development process; such tests may or may not be run prior to release. CPAN clients must not set this variable. Distribution packagers (ppm, deb, rpm, etc.) should not set this variable.

* `ONLINE_TESTING`: unless true, tests must not attempt to access a network
    resource (such a website or attempt to query a network interface).

* `ALL_TESTING`: if true, all possible tests will be run. That is, this
module will NOT skip any tests it could possibly skip under other
environment. This **includes** tests that require a particular module
or C library to be installed.

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Test-When

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Test-When/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
