[![Build Status](https://travis-ci.org/tbrowder/Date-Names-Perl6.svg?branch=master)](https://travis-ci.org/tbrowder/Date-Names-Perl6)

Date::Names
===========

Module **Date::Names** - Provides month and day-of-the-week names for numbers (multilingual)

SYNOPSIS
========

## IMPORTANT NOTE:

The module's hashes are no longer exported in order to avoid interference with the user's environment.
But the **@lang** array is still exported.

~~~perl6
use Date::Names; # <== note no :ALL

# For one-off use
say "Month 3 in Dutch is '{%Date::Names::mon<nl><3>}'";
say "Month 3 in English is '{%Date::Names::mon<3>}' or '{%Date::Names::mon<en><3>}'";
say "Month 3 in French is '{%Date::Names::mon<fr><3>}'";
say "Weekday 3 in Italian is '{%Date::Names::dow<it><3>}'";
say "Weekday 3 in Spanish is '{%Date::Names::dow<it><3>}'";
say "Two-letter abbrev. of weekday 3 in German is '{%Date::Names::dow2<de><3>}'";
say "Three-letter abbrev. of weekday 3 in English is '{%Date::Names::dow3<en><3>}'";

# For more intense cases, one can use this syntax:
my %dow = %Date::Names::dow<nl>; # a convenience hash
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

  Language           | ISO two-letter code (lower-case)
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

The following table shows the hash names for the abbreviations
currently available. Hash names with a 2 or 3 appended are complete
abbreviation sets of that length only.  Hash names with an 'a'
appended are sets of abbreviations of mixed length.  A 'Y' in a cell
indicates a language has a complete set of that type of abbreviation.

Note that in some countries the term "abbreviation" is distinctly
different than "code" as applies to date names. An asterisk in a cell
marks those which are technically codes rather than abbreviations.

Language | %mon2 | %mon3 | %mona | %dow2 | %dow3 | %dowa
---      | :---: | :---: | :---: | :---: | :---: | :---:
Dutch    |       |   Y   |       |   Y   |   Y   |
English  |       |   Y   |       |   Y   |   Y   |
French   |   Y*  |       |   Y   |       |   Y   |   Y
German   |       |   Y   |       |   Y   |       |
Italian  |       |       |       |       |       |
Norwegian|       |       |       |       |       |
Russian  |       |   Y   |       |   Y   |       |   Y
Spanish  |       |   Y*  |       |   Y   |   Y*  |

PULL REQUESTS
=============

Native language speakers please submit PRs to (1) complete the
existing language abbreviations, (2), correct errors, and (3) provide
more languages.

CORRECTIONS & SUGGESTIONS
=========================

The goal of this module is to be useful to non-English users as well
as English users. The author welcomes suggestions for improvement and
increased utility.

VERSION 2 PLANS
===============

In work now is a class to ease use of the module:

```perl6
perl6
use Date::Names;
my $dn = Date::Names.new(
    :lang<en>,
    :day-hash<dow2>,
    :mon-hash<mon3>,
);
is $dn.dow(1), "Mo";  # ok
is $dn.mon(1), "Jan"; # ok

```

The basic class is working and is tested briefly.  More is to be done,
but eventually it will be able to proved a unified handling of full
names and abbreviations. The user will be able to control casing,
absence or presence of periods on abbreviations, and truncation or
padding as desired.


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
