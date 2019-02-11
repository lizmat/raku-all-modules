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
    say "The name of weekday 3 in Italian is {%dow<it><3>}";
    say "The name of weekday 3 in Spanish is {%dow<es><3>}";
    say "The two-letter abbreviation of weekday 3 in German is {%dow2<de><3>}";
    say "The three-letter abbreviation of weekday 3 in English is {%dow3<3>}";


DESCRIPTION
===========

Module **Date::Names** provides the full name of months and days of the week for
the numbers 1..12 and 1..7, respectively, primarily for use with
**Perl 6**'s date functions.

Full names of the months and week days are currently available in the
following languages:

  Language | ISO two-letter code 
  ---      | :---:    
  Dutch    | nl 
  English  | en 
  French   | fr 
  German   | de 
  Italian  | it 
  Norwegian (Bokmål) | nb 
  Russian  | ru  
  Spanish  | es 

CAPITALIZATION AND PUNCTUATION
==============================

All English month and weekday names are always capitalized.
Other languages vary in capitalization depending on where
the word or abbreviation is used or other factors. The
names and abbreviations herein are in the most common form,
but the user can always explicitly set the case by applying
the Perl 6 routines **tc**, **uc**, or **lc** to the name or
abbreviation.

None of the abbreviations include an ending period even though
that might be customary use in some languages.

LIMITATIONS
===========

Not all languages have a complete set of two- and three-letter
abbreviations, and some require up to four letters for the
official abbreviations.

The following table shows the hash names for the abbreviations
currently available. Hash names with a 2 or 3 appended are
complete abbreviation sets of that length only. 
Hash names with an 'a' appended are sets of abbreviations of mixed length.
An 'X' in a cell indicates a language has a complete set of that type
of abbreviation.

Language | %mon2 | %mon3 | %mona | %dow2 | %dow3 | %dowa
---      | :---: | :---: | :---: | :---: | :---: | :---:  
Dutch    |       |       |       |       |       |        
English  |       |       |       |       |       |              
French   |       |       |       |       |       |              
German   |       |       |       |       |       |              
Italian  |       |       |       |       |       |              
Norwegian|       |       |       |       |       |              
Russian  |       |       |       |       |       |              
Spanish  |       |       |       |       |       |              

PULL REQUESTS
=============

Native language speakers please submit PRs to (1) complete the
existing language abbreviations, (2), correct errors, and (3) provide
more languages.

CORRECTIONS & SUGGESTIONS
=========================

The goal of this module is to be useful to non-English users as well
as English users. The author welcomes suggestions for improvement
and increased utility.

ACKNOWLEDGEMENTS
================

The following persons (shown by their #perl6 IRC handles)
contributed to this project via PRs and comments:

+ @moritz - German and Norwegian data
+ @sena_kun - Russian data
+ @luc - French data

I am grateful for their help!

AUTHOR
======

Tom Browder, `<tom.browder@gmail.com> `

COPYRIGHT & LICENSE
===================

Copyright (c) 2019 Tom Browder, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl 6 itself.
