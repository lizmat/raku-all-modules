# Design Notes

## Purpose Overview

The module intends to provide a convenient method to conditionally run test
files, based on the set environmental variables, installed modules, or
installed C libraries.

If the conditions specified by the programmer do not match, the
tests in the file must be skipped, with a useful message to the user running
the tests, indicating why they're being skipped.

## Environmental Variables

The Perl 5's ecosystem is currently adhering to the
[environmental variables agreed upon as the Lancaster Consensus](https://github.com/Perl-Toolchain-Gang/toolchain-site/blob/master/lancaster-consensus.md#environment-variables-for-testing-contexts). This module is to implement
those (thus bringing them into the Perl 6 world), as well as introduce
a couple of extra ones.

In the list below, `CPAN client` is to mean a module installation tool,
such as [`panda`](https://github.com/tadzik/panda/). The environmental variables
to be supported by the module are:

* **Lancaster Consensus**

    * `AUTOMATED_TESTING`: if true, tests are being run by an automated testing facility and not as part of the installation of a module; CPAN smokers must set this to true; CPAN clients (e.g. `panda`) must not set this.

    * `NONINTERACTIVE_TESTING`: if true, tests should not attempt to interact with a user; output may not be seen and prompts will not be answered.

    * `EXTENDED_TESTING`: if true, the user or process running tests is willing to run optional tests that may take extra time or resources to complete. Such tests must not include any development or QA tests. Only tests of runtime functionality should be included.

    * `RELEASE_TESTING`: if true, tests are being run as part of a release QA process; CPAN clients must not set this variable.

    * `AUTHOR_TESTING`: if true, tests are being run as part of an author's personal development process; such tests may or may not be run prior to release. CPAN clients must not set this variable. Distribution packagers (ppm, deb, rpm, etc.) should not set this variable.

* **Extras**

    * `ONLINE_TESTING`: unless true, tests must not attempt to access a network
        resource (such a website or attempt to query a network interface).

    * `ALL_TESTING`: if true, all possible tests will be run. That is, this
    module will NOT skip any tests it could possibly skip under other
    environment. This **includes** tests that require a particular module
    or C library to be installed.

## Optional Modules

Some distributions can offer extra functionality if the user has an optional
module installed. The purpose of Test::When is to allow writing tests testing
such optional functionality by detecting availability of such an optional
module.

The test skip messages on the terminal would also be another place to alert
the user that extra functionality is available to them.

## Prerequisite C Libraries

Same as [optional modules](#optional-modules), for similar reasons, except
the tested environment will be the presence

## Method of Use

![][spec-partial]

The module will not export any functions and all of its functionality
will be used via the `use Test::When ...` line, for example:

```perl6
    use Test::When <network extended release>,       # env var settings
                    :modules<Foo::Bar  Ber::Boor>, # optional modules
                    :libs<sqlite3>;                # needed C libs
```

### Enviromental variables

![][spec-full]

Keywords to be specified on the `use...` will correspond to the following
sets of env vars that have to be set in order to run those tests. They
are to be provided on the `use...` line as positional arguments, like so:

```perl6
    use Test::When <smoke author>;
```

* `smoke`—tests to be run when either `AUTOMATED_TESTING` or
    `ALL_TESTING` env vars are true.

* `interactive`—tests must **NOT** be run when `NONINTERACTIVE_TESTING`
    is set to true, unless `ALL_TESTING` is also set to true.

* `extended`—tests to be run when either `EXTENDED_TESTING`,
    `RELEASE_TESTING`, or `ALL_TESTING` env var is set to true.

* `release`—tests to be run when `RELEASE_TESTING` or `ALL_TESTING` env var
    is set to true.

* `author`—tests to be run when `AUTHOR_TESTING` or `ALL_TESTING` env var is
    set to true.

* `online`—tests to be run when `ONLINE_TESTING` or `ALL_TESTING` is set to
    true.

### Optional Modules

![][spec-none]

Optional modules are to be specified as a list in `:modules` named argument:

```perl6
    use Test::When :modules<Extra::OptionalFeatures Moar::OptionalFeatures>;
```

Multiple modules can be specified and the entire test will be skipped if at
least one module is not installed.

To specify particular versions, use pairs:

```perl6
    use Test::When :modules( 'Extra::OptionalFeatures' => '1.001002'  );
    use Test::When :modules( 'Extra::OptionalFeatures' => (v6.a .. *) );
```

You can also use junctions to specify whether, say, you want any of the
modules installed:

```perl6
    use Test::When :modules( any <DB::MySQL  DB::SQLite> );
```


### Prerequisite C Libraries

![][spec-none]

The needed C libraries are to be specified as a list in `:libs` named argument.
Features and behaviour are same as [optional modules](#optional-modules).
Version `v1` is to be assumed by default.

```perl6
    use Test::When :libs<sqlite3  someotherlib>;
    use Test::When :libs( sqlite3 => 'v2' );
    use Test::When :libs( any<sqlite3  someotherlib> );
```

## Feeback

Results of feedback:

* Change module name from `Test::Is` to `Test::When`
* OFFLINE_TESTING might be changed to ONLINE_TESTING, there's a poll running
    https://twitter.com/zoffix/status/685108122227113984
* It's not uncommon to want any of X number of libraries/modules installed
    We need to support junctions in `:modules`/`:libs, e.g.
    `:lib('sqlite3', any(<foo bar ber>) )`

* Use http://modules.perl6.org/repo/LibraryCheck for lib checking
* https://github.com/jonathanstowe/CheckSocket might also be useful for
something

[spec-none]: _chromatin/spec-none.png
[spec-partial]: _chromatin/spec-partial.png
[spec-full]: _chromatin/spec-full.png
