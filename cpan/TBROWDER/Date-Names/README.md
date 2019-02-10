[![Build Status](https://travis-ci.org/tbrowder/Date-Names-Perl6.svg?branch=master)](https://travis-ci.org/tbrowder/Date-Names-Perl6)

Date::Names
===========

Module **Date::Names** - Provides month and day-of-the-week names for numbers (multilingual)

SYNOPSIS
========

    use Date::Names;

    say "The name of month 3 in Dutch is {%mon<nl><3>}";
    say "The name of month 3 in English is {%mon<3>} or {%mon<en><3>}";
    say "The name of month 3 in French is {%mon<fr><3>}";
    say "The name of weekday 3 in German is {%dow<de><3>}";
    say "The name of weekday 3 in Italian is {%dow<it><3>}";
    say "The name of weekday 3 in Spanish is {%dow<es><3>}";
    say "The two-letter abbreviation of weekday 3 in German is {%dow-abbrev2<de><3>}";
    say "The three-letter abbreviation of weekday 3 in English is {%dow-abbrev3<3>}";


DESCRIPTION
===========

Module **Date::Names** provides the full name of months and days of the week for
the numbers 1..12 and 1..7, respectively, primarily for use with
**Perl 6**'s date functions.

Three-letter abbreviations for months and week days are available
in **English** in this version.

Two-letter abbreviations for week days are available in **English**
and **German**.

Full names of the months and week days are currently available in the
following languages:

  Name | ISO two-letter code | Notes
  ---  | :---:                 | ---
  Dutch   | nl | Lower-case
  English | en | Capitalized
  French  | fr | Lower-case
  German  | de | Capitalized
  Italian | it | Months capitalized, week days in lower-case
  Spanish | es | Lower-case

LIMITATIONS
===========

Whether to capitalize the names or not seems to be inconsistent in my
Internet search for the values for the various languages. It is clear
in English: they are always capitalized. The choices I made for the
current languages are shown in the list above.


PULL REQUESTS
=============

Native language speakers please submit PRs to (1) complete the
existing language abbreviations and (2) provide more languages.


AUTHOR
======

Tom Browder, `<tom.browder@gmail.com> `

COPYRIGHT & LICENSE
===================

Copyright (c) 2019 Tom Browder, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
