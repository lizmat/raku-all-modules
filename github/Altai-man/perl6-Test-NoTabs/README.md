# Test::NoTabs
[![Build Status](https://travis-ci.org/Altai-man/perl6-Test-NoTabs.svg?branch=master)](https://travis-ci.org/Altai-man/perl6-Test-NoTabs)

This is a port of Test::NoTabs in Perl 6. It checks your Perl 6 files that can contain tabs. If it's so, test will be failed.

# Functions

`notabs-ok` takes path as a string to the file and check it for tabs absence.

`all-perl-files-ok` takes path to the directory and checks all files with extensions: `pl`, `pm`, `pl6`, `pm6`, `p6`.

# Usage example

``` perl6
use Test::NoTabs;
# Very simple.
notabs-ok("test-without-tabs");
```
