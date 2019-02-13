[![Build Status](https://travis-ci.org/tbrowder/Date-Names-Perl6.svg?branch=master)](https://travis-ci.org/tbrowder/Date-Names-Perl6)

Date::Names
===========

Module **Date::Names** - Provides month and day-of-the-week names for numbers (multilingual)

This is Version 2. A new Date::Names class is available and
direct hash access has changed from Version 1.

Version 2:

```perl6
# Three syntaxes to use, in all the hash name is now listed
# last in the identifier following the language code:

my %dow = $Date::Names::nl::dow; # <== the author's preference
say "key $_" for %dow.keys.sort; # 1..7
my $dow = $Date::Names::nl::dow;
say "key $_" for $dow.keys.sort; # 1..7
my %dow = %($Date::Names::nl::dow);
say "key $_" for %dow.keys.sort; # 1..7

```

Version 1 for comparison (deprecated):

``` perl6
my %dow = %Date::Names::dow<nl>;

```

SYNOPSIS
========

~~~perl6
use Date::Names;

# For one-off use
say "Month 3, Dutch: '{$Date::Names::nl::mon<3>}'";
say "Weekday 3, Italian: '{$Date::Names::it::dow<3>}'";
say "Two-letter abbrev., weekday 3, German is '{$Date::Names::de::dow2<3>}'";
say "Three-letter abbrev., weekday 3, English is '{$Date::Names::en::dow3<3>}'";

# For more intense cases, one can use this syntax:
my %dow = $Date::Names::nl::dow; # a convenience hash
say "Weekdays in Dutch:";
for 1..7 -> $n {
    say "  day $n: {%dow{$n}}";
}
~~~

DESCRIPTION
===========

Module **Date::Names** provides the full name of months and days of the week for
the numbers 1..12 and 1..7, respectively, primarily for use with
**Perl 6**'s date functions.

Full names of the months and weekdays are currently available in the
following languages:

### Table 1. Language two-letter ISO codes (lower-case)

Language           | ISO code
:---               | :---:
Dutch              | nl
English            | en
French             | fr
German             | de
Italian            | it
Norwegian (Bokmål) | nb
Russian            | ru
Spanish            | es

CAPITALIZATION AND PUNCTUATION
==============================

All English month and weekday names are always capitalized.
Other languages vary in capitalization depending on where
the word or abbreviation is used or other factors. The
names and abbreviations herein are in the most common form,
but the user can always explicitly set the case by applying
the Perl 6 routines **tc**, **uc**, or **lc** to the name or
abbreviation.

Some of the abbreviations include an ending period since that is
customary use in some languages (e.g., French).

LIMITATIONS
===========

Not all languages have a complete set of two- and three-letter
abbreviations, and some require up to four letters for the official
abbreviations.

Table 2 shows the hash names for the full names and abbreviations
currently available. Hash names with a 2 or 3 appended are complete
abbreviation sets of that length only.  Hash names with an 'a'
appended are sets of abbreviations of mixed length.  A 'Y' in a cell
indicates a language has a complete set of that type of abbreviation.

Note that in some countries the term "abbreviation" is distinctly
different than "code" as it applies to date names. An asterisk in a cell
marks those which are technically codes rather than abbreviations.
Table 3 shows the meaning of other codes used in the Table 2 cells.

The hash names in Table 2 (without a sigil) are the ones to be used
for the day and month hash names for the Date::Names class constructor.

### Table 2. Name hash availability by language

Language / Hash  |  mon  | dow   | mon3  | dow3  | mon2  | dow2  | mona  | dowa
---              | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---:
Dutch            |   Y   |   Y   |   Y   |   Y   |       |   Y   |       |
English          |   Y   |   Y   |   Y   |   Y   |       |   Y   |       |
French           |   Y   |   Y   |       |   Y   |   Y*  |       |   Y   |   Y
German           |   Y   |   Y   |   Y   |       |       |   Y   |       |
Italian          |   Y   |   Y   |       |       |       |       |       |
Norwegian        |   Y   |   Y   |       |       |       |       |       |
Russian          |   Y   |   Y   |   Y   |       |       |   Y   |       |   Y
Spanish          |   Y   |   Y   |   Y*  |   Y*  |       |   Y   |       |

### Table 3. Name hash cell codes and meaning

Code | Meaning
---  | ---
\*   | code rather than an abbreviation
L    | hash values are lower-case
M    | hash values are mixed-case
P    | hash values have a trailing period
T    | hash values are title-case
U    | hash values are upper-case
Y    | language has this hash

Note that when the Date::Names class is fully implemented in Version 3,
the user will be able to specify desired hash table attributes for
his or her tastes (case, trailing period, truncation or padding);

PULL REQUESTS
=============

Native language speakers please submit PRs to (1) complete the
existing language abbreviations, (2), correct errors, and (3) provide
more languages. See the [CONTRIBUTING](./CONTRIBUTING.md) file for
details.

CORRECTIONS & SUGGESTIONS
=========================

The goal of this module is to be useful to non-English users as well
as English users. The author welcomes suggestions for improvement and
increased utility.

Class Date::Names
=================

Now available is class Date::Names to ease use of the module:

```perl6
perl6
use Date::Names;
my $dn = Date::Names.new; # default: English, full names
is $dn.dow(1), "Monday";  # ok
is $dn.mon(1), "January"; # ok
is $dn.dow(1, 3), "Mon";  # ok, raw truncation on full names only
is $dn.mon(1, 3), "Jan";  # ok, raw truncation on full named only
```

The full API for the class constructor looks like this, but the names
aren't all set in concrete yet (SUGGESTIONS WELCOME):

``` perl6
enum Period <yes no keep-p>;
enum Case <uc lc tc p keep-c>;
my $dn = Date::Names.new(
    lang     => 'nl',   # default: 'en'
    day-hash => 'dow3', # default: 'dow' # VAR NAME SUBJECT TO CHANGE
    mon-hash => 'mon',  # default: 'mon' # VAR NAME SUBJECT TO CHANGE
    period   => yes,    # default: keep-p (use native)
    case     => uc,     # default: keep-c (use native)
    truncate => 0,      # default
    pad      => 0,      # default
):

```

### Planned features:

1. English language default [complete]
2. Default month and weekday hash choices [complete]
3. User chooses truncation or padding [API complete]
4. User chooses which month and weekday has to use [complete, var names may change]
5. User chooses case of the output names [API complete]
6. User can choose raw truncation on a full name, if permitted by the language [API partially complete]
7. User can choose to have a period or not for abbreviations [API complete]

### Future features

1. Language-specific attributes to affect class behavior (e.g., allow raw truncation or not)
2. Add additional hash names and types on a language basis
3. Graceful messages if a desired hash is empty [version 2+]
4. Features desired by users

The basic class is working (see **Planned features** above) and is
tested briefly.  More is to be done, but eventually it will be able to
proved a unified handling of full names and abbreviations. The user
will be able to control casing, absence or presence of periods on
abbreviations, and truncation or padding as desired.

VERSION 3
=========

The Date::Names class API will be fixed and all currently planned
features will be implemented.


ACKNOWLEDGEMENTS
================

The following persons contributed to this project via PRs and
comments (@name is an alias on IRC #perl6):

+ Moritz Lenz (@moritz, github: moritz) - German and Norwegian data
+ @sena_kun (github: Altai-man) - Russian data
+ Luc St-Louis (@lucs, github: lucs) - French data
+ Luis F. Uceta (github: uzluisf) - Spanish data
+ Elizabeth Mattijsen (@lizmat, github: lizmat) - Dutch data

I am grateful for their help!

REFERENCES
==========

1. [FR] <http://bdl.oqlf.gouv.qc.ca/bdl/gabarit_bdl.asp?id=3617>
2. [ES] <http://www.wikilengua.org/index.php/Abreviaciones_en_fechas>
3. [ES] <http://lema.rae.es/dpd/srv/search?id=fKODyKTfZD6s0mX7bz>

AUTHOR
======

Tom Browder, `<tom.browder@gmail.com> `

COPYRIGHT & LICENSE
===================

Copyright (c) 2019 Tom Browder, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl 6 itself.
