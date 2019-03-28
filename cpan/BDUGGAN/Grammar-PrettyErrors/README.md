# Grammar::PrettyErrors
[![Build Status](https://travis-ci.org/bduggan/p6-grammar-prettyerrors.svg?branch=master)](https://travis-ci.org/bduggan/p6-grammar-prettyerrors)

Make grammars fail parsing with a pretty error instead of returning nil.

## SYNOPSIS

Input:

```perl6
use Grammar::PrettyErrors;

grammar G does Grammar::PrettyErrors {
  rule TOP {
    'orange'+ % ' '
  }
}

# Handle the failure.
G.parse('orange orange orange banana') orelse
    say "parse failed at line {.exception.line}";

# Don't handle it, an exception will be thrown:
G.parse('orange orange orange banana');
```

Output:

```
failed at line 1

--errors--
  1 │▶orange orange orange banana
                           ^

Uh oh, something went wrong around line 1.
Unable to parse TOP.
```

## DESCRIPTION

When the `Grammar::PrettyErrors` role is applied
to a Grammar, it changes the behavior of a parse
failure.  Instead of returning `nil`, a failure
is thrown.  The exception object has information
about the context of the failure, and a pretty
error message that includes some context around
the input text.

It works by wrapping
the `<ws>` token and keeping track of a highwater
mark (the position), and the name of the most
recent rule that was encountered.

This technique is described by moritz in his
excellent book [0] (see below).

## CLASSES, ROLES

### Grammar::PrettyErrors (Role)

#### ATTRIBUTES

* `quiet` -- Bool, default false: just save the error, don't throw it.

* `colors` -- Bool, default true: make output colorful.

* `error` -- a `X::Grammar::PrettyError` object (below).

#### METHODS

* `new` -- wraps the `<ws>` token as described above, it also takes
  additional named arguments (to set the ATTRIBUTEs above).

### X::Grammar::PrettyError (class)

#### METHODS

* `line` -- the line number at which the parse failed (starting at 1).
Or 0 if no lines were parsed;

* `column` -- the column at which the parse failed (starting at 1).
Or 0 if no characters were parsed;

* `lastrule` -- the last rule which was parsed.

* `report` -- the text of a report including the above information,
with a few lines before and after.  (see SYNOPSIS)

* `message` -- Same as `report`.

## EXAMPLES

```
grammar G does Grammar::PrettyErrors { ... }

# Throw an exception with a message when a parse fails.
G.parse('orange orange orange banana');

# Same thing
G.new.parse('orange orange orange banana');

# Pass options to the constructor.  Don't throw a failure.
my $g = G.new(:quiet, :!colors);
$g.parse('orange orange orange banana');
# Just print it ourselves.
say .report with $g.error;

# Use the failure to handle it without throwing it.
G.parse('orange orange orange banana') orelse
    say "parse failed at line {.exception.line}";
```

## SEE ALSO

* [0] [Parsing with Perl 6 Regexes and Grammars](https://www.apress.com/us/book/9781484232279) and the accompanying [code](https://github.com/Apress/perl-6-regexes-and-grammars/blob/master/chapter-11-error-reporting/03-high-water-mark.p6)

* Grammar::ErrorReporting

## AUTHOR

Brian Duggan
