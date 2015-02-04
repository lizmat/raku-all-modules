# colortext.t --- test that everything is output correctly.

use v6;
use Test;
use Term::ColorText;

plan 22;

is HEADER("foo"), "\e[30;47mfoo\e[0m",                  "HEADER command works";
is DOING("foo"),  "\e[33mfoo\e[33m \e[0m",              "DOING command works";
is CHK("foo"),    "\e[32mfoo\e[0m",                     "CHK command works";
is INFO("foo"),   "\e[36mfoo\e[0m",                     "INFO command works";
is VAL("foo"),    "\e[1;35mfoo\e[0m",                   "VAL command works";
is DONE("foo"),   "\e[32m\r\e[K\e[32mfoo\e[0m",         "DONE command works";
is TODO("foo"),   "\e[37;41mXXX\e[0m\e[31;47mfoo\e[0m", "TODO command works";

# Test the DEBUG statement

my $no_dbg;
my $yes_dbg;
my $slurp_dbg;
my $single_dbg;
{
    class Foo {
        has $.a = "";
        method print($b) { $!a ~= $b }
        method clear()   { $!a = "" }
    }
    temp $*ERR = Foo.new;
    DEBUG("foo");
    $no_dbg = $*ERR.a;

    $*ERR.clear;

    my $*YES_DEBUG = True;
    DEBUG("foo");
    $yes_dbg = $*ERR.a;

    # take care of these next two now, instead of later

    $*ERR.clear;
    DEBUG("foo", "bar");
    $slurp_dbg = $*ERR.a;

    $*ERR.clear;
    DEBUG("foo\e[1;37;43mbar");
    $single_dbg = $*ERR.a;

}

is $no_dbg, "", "DEBUG command doesn't work by default.";
is $yes_dbg, "\e[1;37;43mfoo\e[0m\n", "DEBUG command works with a true \$*YES_DEBUG";

# Test the FRAC statement

is FRAC(0, 10),  "\e[31m0\e[0m/\e[32m10\e[0m",  "FRAC works with fractions == zero";
is FRAC(2, 10),  "\e[33m2\e[0m/\e[32m10\e[0m",  "FRAC works with fractions ~~ 0^..^1";
is FRAC(10, 10), "\e[32m10\e[0m/\e[32m10\e[0m", "FRAC works with fractions == one";
is FRAC(11, 10), "\e[1;34m11\e[0m/\e[32m10\e[0m", "FRAC works with fractions > 1";
# can't really test the error string, though I suppose that's a good thing :)

# other tests

is HEADER("foo", "bar"), "\e[30;47mfoo\e[30;47mbar\e[0m",                  "HEADER takes a slurpy argument";
is DOING("foo", "bar"),  "\e[33mfoo\e[33mbar\e[33m \e[0m",                 "DOING takes a slurpy argument";
is CHK("foo", "bar"),    "\e[32mfoo\e[32mbar\e[0m",                        "CHK takes a slurpy argument";
is INFO("foo", "bar"),   "\e[36mfoo\e[36mbar\e[0m",                        "INFO takes a slurpy argument";
is VAL("foo", "bar"),    "\e[1;35mfoo\e[1;35mbar\e[0m",                    "VAL takes a slurpy argument";
is DONE("foo", "bar"),   "\e[32m\r\e[K\e[32mfoo\e[32mbar\e[0m",            "DONE takes a slurpy argument";
is TODO("foo", "bar"),   "\e[37;41mXXX\e[0m\e[31;47mfoo\e[31;47mbar\e[0m", "TODO takes a slurpy argument";

is $slurp_dbg, $single_dbg, "DEBUG takes a slurpy argument";

is CHK, CHK("✔"), "CHK defaults to green ✔";
