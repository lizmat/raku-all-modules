# NAME

TAP::Harness

# DESCRIPTION

An asynchronous TAP framework written in Perl 6.

# prove6

This module provides the `prove6` command which runs a TAP based test suite and prints a report.
The `prove6` command is a minimal wrapper around an instance of this module.

For a detailed documentation on how to use `prove6` [click here](./README-prove6.md) or run `prove6 --help`

# SYNOPSIS

```Perl 6
use TAP::Harness;
my $harness = TAP::Harness.new(|%args);
$harness.run(@tests);
```

# METHODS

## Class Methods

### new

```Perl 6
my %args = jobs => 1, err  => 'ignore';
my $harness = TAP::Harness.new( |%args );
```

The constructor returns a new `TAP::Harness` object.
It accepts an optional hash whose allowed keys are:

* `volume`

  Default value: `Normal`

  Possible values: `Silent` `ReallyQuiet` `Quiet` `Normal` `Verbose`
* `jobs`

  The maximum number of parallel tests to run.

  Default value: `1`

  Possible values: An `Int`
* `timer`

  Append run time for each test to output.

  Default value: `False`

  Possible values: `True` `False`
* `err`

  Error reporting configuration.

  Default value: `stderr`

  Possible values: `stderr` `ignore` `merge` `Supply` `IO::Handle`

  |Value       |Definition                                        |
  |------------|--------------------------------------------------|
  |`stderr`    |Direct the test's `$*ERR` to the harness' `$*ERR` |
  |`ignore`    |Ignore the test scripts' `$*ERR`                  |
  |`merge`     |Merge the test scripts' `$*ERR` into their `$*OUT`|
  |`Supply`    |Direct the test's `$*ERR` to a `Supply`           |
  |`IO::Handle`|Direct the test's `$*ERR` to an `IO::Handle`      |
* `ignore-exit`

  If set to `True` will instruct `TAP::Parser` to ignore exit and wait for status from test scripts.

  Default value: `False`

  Possible values: `True` `False`
* `trap`

  Attempt to print summary information if run is interrupted by SIGINT (Ctrl-C).

  Default value: `False`

  Possible values: `True` `False`
* `handlers`

  Default value: `TAP::Harness::SourceHandler::Perl6`

  Possible values: `TAP::Harness::SourceHandler::Perl6`
  `TAP::Harness::SourceHandler::Exec`

  |Language|Handler                                          |
  |--------|-------------------------------------------------|
  |Perl 6  |`TAP::Harness::SourceHandler::Perl6.new`         |
  |Perl 5  |`TAP::Harness::SourceHandler::Exec.new('perl')`  |
  |Ruby    |`TAP::Harness::SourceHandler::Exec.new('ruby')`  |
  |Python  |`TAP::Harness::SourceHandler::Exec.new('python')`|

## Instance Methods

### run

```Perl 6
$harness.run(@tests);
```

Accepts an array of `@tests` to be run. This should generally be the names of test files.

# TODO

These features are currently not implemented but are considered desirable:

 * Rule based parallel scheduling
 * Source Handlers other than `::Perl6`
 * Various `prove6` arguments
 * Better documentation

 # LICENSE

You can use and distribute this module under the terms of the The Artistic License 2.0. See the LICENSE file included in this distribution for complete details.
