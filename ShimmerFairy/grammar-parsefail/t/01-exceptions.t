# 01-exceptions.t --- test the Exception objects provided by the module

use v6;
use Test;
use Grammar::Parsefail::Exceptions;

plan 10;

## ExPointer

nok ExPointer.isa(Exception), "ExPointer is merely a helper class, not an Exception";

my $point = ExPointer.new(file => "somefile.p6", line => 42, col => 0);
is $point.gist, "somefile.p6:42,0", "Can construct an ExPointer with arguments";

$point.file = "another-file.p6";
$point.line = 12;
$point.col = 54;

is $point.gist, "another-file.p6:12,54", "Can modify an ExPointer's fields";

## X::Grammar

isa-ok X::Grammar, Exception, "X::Grammar is an Exception";

my $ex = X::Grammar.new(goodpart  => "foo bar",
                        badpart   => "baz quux",
                        err-point => $point);

is $ex.message, "Unspecified grammar error", "X::Grammar.message provides a fallback 'message'";

is $ex.gist, qq:to/END_EXPECT/.chomp, "X::Grammar produces the gist";
    \e[41;1m===SORRY!===\e[0m Issue in $point.gist():
    Unspecified grammar error
    at $point.gist()
    ------>|\e[32mfoo bar\e[33m\c[EJECT SYMBOL]\e[31mbaz quux\e[0m
    END_EXPECT

is $ex.gist(:!singular), qq:to/END_EXPECT/.chomp, "X::Grammar gist with :!singular has no heading";
    Unspecified grammar error
    at $point.gist()
    ------>|\e[32mfoo bar\e[33m\c[EJECT SYMBOL]\e[31mbaz quux\e[0m
    END_EXPECT

$ex = X::Grammar.new(goodpart            => $ex.goodpart,
                     badpart             => $ex.badpart,
                     err-point           => $point,
                     hint-message        => "And a hint",
                     hint-but-no-pointer => False,
                     hint-beforepoint    => "SOMETHING",
                     hint-afterpoint     => "HELPFUL",
                     hint-point          => $point);

is $ex.gist, qq:to/END_EXPECT/.chomp, "X::Grammar with hint";
    \e[41;1m===SORRY!===\e[0m Issue in $point.gist():
    Unspecified grammar error
    at $point.gist()
    ------>|\e[32mfoo bar\e[33m\c[EJECT SYMBOL]\e[31mbaz quux\e[0m

        And a hint
        at $point.gist()
        ------>|\e[32mSOMETHING\e[33m▶\e[32mHELPFUL\e[0m
    END_EXPECT

## X::Grammar::Epitaph

my $tombstone = X::Grammar::Epitaph.new(panic   => $ex,
                                        sorrows => [$ex],
                                        worries => [$ex, $ex]);

is $tombstone.gist, qq:to/END_GROUP/.chomp, "X::Grammar::Epitaph gist works";
    \e[41;1m===SORRY!===\e[0m
    Main issue:
    $ex.gist(:!singular).indent(4)

    Other problems:
    $ex.gist(:!singular).indent(4)

    Other potential difficulties:
    $ex.gist(:!singular).indent(4)
    $ex.gist(:!singular).indent(4)

    The main issue stopped parsing immediately. Please fix it so that we can parse more of the source code.
    END_GROUP

# XXX more Epitaph tests

## X::Grammar::AdHoc

$ex = X::Grammar::AdHoc.new(payload   => "A plain adhoc",
                            err-point => $point,
                            goodpart  => "foo",
                            badpart   => "bar");

is $ex.gist, qq:to/END_EXPECT/.chomp, "X::Grammar::AdHoc makes the right gist";
    \e[41;1m===SORRY!===\e[0m Issue in $point.gist():
    (ad-hoc) A plain adhoc
    at $point.gist()
    ------>|\e[32mfoo\e[33m\c[EJECT SYMBOL]\e[31mbar\e[0m
    END_EXPECT

# XXX more AdHoc tests
