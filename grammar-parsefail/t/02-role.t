# 02-role.t --- test the parsefail role

use v6;
use Test;
use Grammar::Parsefail;

plan 8;

#| the grammar we'll be using
grammar TestingPF is Grammar::Parsefail {
    token dont_panic {
        foo <.typed_panic(X::Grammar)>
    }

    token not_sorry {
        bar <.typed_sorry(X::Grammar)>
        <.express_concerns>
    }

    token no_worry {
        baz <.typed_worry(X::Grammar)>
        <.express_concerns>
    }

    token panic_string {
        FOO <.panic("OH NO!")>
    }

    token sorry_string {
        BAR <.sorry("EEK!")>
        <.express_concerns>
    }

    token worry_string {
        BAZ <.worry("GASP!")>
        <.express_concerns>
    }

    token limited_sorry {
        limits
        { $¢.limit_sorrows(2) } # XXX putting at top breaks things; see RT#126249
        <.sorry("A")>
        <.sorry("B")>
    }

    token nesting_concerns {
        <nested_concern>
        <.express_concerns>
    }

    token nested_concern {
        quux <.typed_sorry(X::Grammar)>
    }
}

#| A fake IO to capture error output
class FakeIO {
    has $.result;

    method print($str) {
        $!result ~= $str;
        True;
    }

    method CLEAR { $!result = "" }
}

my $fio = FakeIO.new;

## typed failures

{
    temp $*ERR = $fio;
    TestingPF.parse("foo", :rule<dont_panic>);
    CATCH {
        default {
            note $_;
        }
    }
}

is $fio.result, qq:to/END_ERR/, "Panic thrown properly";
    \e[41;1m===SORRY!===\e[0m Issue in <unspecified file>:1,3:
    Unspecified grammar error
    at <unspecified file>:1,3
    ------>|\e[32mfoo\e[33m\c[EJECT SYMBOL]\e[31m\e[0m
    END_ERR

$fio.CLEAR;

{
    temp $*ERR = $fio;
    TestingPF.parse("bar", :rule<not_sorry>);
    CATCH {
        default {
            note $_;
        }
    }
}

is $fio.result, qq:to/END_ERR/, "Sorrow thrown properly";
    \e[41;1m===SORRY!===\e[0m Issue in <unspecified file>:1,3:
    Unspecified grammar error
    at <unspecified file>:1,3
    ------>|\e[32mbar\e[33m\c[EJECT SYMBOL]\e[31m\e[0m
    END_ERR

$fio.CLEAR;

{
    temp $*ERR = $fio;
    TestingPF.parse("baz", :rule<no_worry>);
    CATCH {
        default {
            note $_;
        }
    }
}

is $fio.result, qq:to/END_ERR/, "Worry thrown properly";
    Potential difficulties:
        Unspecified grammar error
        at <unspecified file>:1,3
        ------>|\e[32mbaz\e[33m\c[EJECT SYMBOL]\e[31m\e[0m

    The potential difficulties above may cause unexpected results, since they don't prevent the parser from completing.
    Fix or suppress the issues as needed to avoid any doubt in the results of parsing.
    END_ERR

$fio.CLEAR;

## Untyped problems

{
    temp $*ERR = $fio;
    TestingPF.parse("FOO", :rule<panic_string>);
    CATCH {
        default {
            note $_;
        }
    }
}

is $fio.result, qq:to/END_ERR/, "Untyped panic thrown properly";
    \e[41;1m===SORRY!===\e[0m Issue in <unspecified file>:1,3:
    (ad-hoc) OH NO!
    at <unspecified file>:1,3
    ------>|\e[32mFOO\e[33m\c[EJECT SYMBOL]\e[31m\e[0m
    END_ERR

$fio.CLEAR;

{
    temp $*ERR = $fio;
    TestingPF.parse("BAR", :rule<sorry_string>);
    CATCH {
        default {
            note $_;
        }
    }
}

is $fio.result, qq:to/END_ERR/, "Untyped sorrow thrown properly";
    \e[41;1m===SORRY!===\e[0m Issue in <unspecified file>:1,3:
    (ad-hoc) EEK!
    at <unspecified file>:1,3
    ------>|\e[32mBAR\e[33m\c[EJECT SYMBOL]\e[31m\e[0m
    END_ERR

$fio.CLEAR;

{
    temp $*ERR = $fio;
    TestingPF.parse("BAZ", :rule<worry_string>);
    CATCH {
        default {
            note $_;
        }
    }
}

is $fio.result, qq:to/END_ERR/, "Untyped worry thrown properly";
    Potential difficulties:
        (ad-hoc) GASP!
        at <unspecified file>:1,3
        ------>|\e[32mBAZ\e[33m\c[EJECT SYMBOL]\e[31m\e[0m

    The potential difficulties above may cause unexpected results, since they don't prevent the parser from completing.
    Fix or suppress the issues as needed to avoid any doubt in the results of parsing.
    END_ERR

$fio.CLEAR;

## sorry limiting

{
    temp $*ERR = $fio;
    TestingPF.parse("limits", :rule<limited_sorry>);
    CATCH {
        default {
            note $_;
        }
    }
}

is $fio.result, qq:to/END_ERR/, "Limiting sorrows works";
    \e[41;1m===SORRY!===\e[0m
    Problems:
        (ad-hoc) A
        at <unspecified file>:1,6
        ------>|\e[32mlimits\e[33m\c[EJECT SYMBOL]\e[31m\e[0m
        (ad-hoc) B
        at <unspecified file>:1,6
        ------>|\e[32mlimits\e[33m\c[EJECT SYMBOL]\e[31m\e[0m

    There were too many problems to continue parsing. Please fix some of them so that we can parse more of the source code.
    END_ERR

$fio.CLEAR;

## causing concern in a subrule

{
    temp $*ERR = $fio;
    TestingPF.parse("quux", :rule<nesting_concerns>);
    CATCH {
        default {
            note $_;
        }
    }
}

is $fio.result, qq:to/END_ERR/, "Concern in subrule works";
    \e[41;1m===SORRY!===\e[0m Issue in <unspecified file>:1,4:
    Unspecified grammar error
    at <unspecified file>:1,4
    ------>|\e[32mquux\e[33m\c[EJECT SYMBOL]\e[31m\e[0m
    END_ERR

$fio.CLEAR;