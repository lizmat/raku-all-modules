Locale::Codes::Country
======================

Locale::Codes::Country is a first attempt at creating a pure Perl 6 implementation
of the Perl 5 module of the same name found on CPAN. This version extends
the functionality of the original version.

Requirements
============

Rakudo Perl 6 (I developed this with the 2016.01 release).

Installation
============

I use Panda. The command: `panda install Locale-Codes-Country` should work.

What's it for?
==============

Locale::Codes::Country is an implementation of the ISO3166 standard, which defines
codes for the names of countries, dependent territories, etc. There are
essentially four types of codes associated with each country/area:

* LOCALE_CODE_ALPHA_2 defines a unique 2 character code for each country/area
* LOCALE_CODE_ALPHA_3 defines a unique 3 character code
* LOCALE_CODE_NUMERIC defines a numeric code (between 000 and 999) for each
  country/area
* LOCALE_CODE_DOM defines the IANA assigned Top Level Domain for a country.
    For most countrues this just the LOCALE_CODE_ALPHA_2 code in lower case
    with a leading dot, but every now and again there is a difference. I may
    not have caught those yet ;-)
    
For each of the constants listed above there is an equivalent string. Respectively:
* 'alpha-2'
* 'alpha-3'
* 'numeric'
* 'dom'


Using Locale::Codes::Country, you may lookup a country name by its ISO3166-2,
ISO3166-3 or ISO3166-Numeric defined code. You may also look up a country's
ISO-assigned code using the full country name. You may also lookup one
of the other ISO-defined codes by passing in any of the other unique values.

Examples
========

    use v6;
	use Locale::Codes::Country;
	
	say codeToCountry("BGD"); # will print 'Bangladesh'
	say codeToCountry("CA"); # will print 'Canada'. LOCALE_CODE_ALPHA_2 is default
	say countryToCode("Austria",LOCALE_CODE_NUMERIC) # will print 40
	say codeToCode(70, 'alpha-3'); # will print BIH (Bosnia and Herzegovina)

Future
======

I may in the near future add other codes such as IOC designations, or FIPS
codes to the mix.

Testing
=======

Not yet. Soon!

License and Author
==================

The MIT License (MIT)

Copyright (c) 2016  Dean Powell

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
