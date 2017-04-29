[![Build Status](https://travis-ci.org/MARTIMM/unicode-precis.svg?branch=master)](https://travis-ci.org/MARTIMM/unicode-precis)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/MARTIMM/unicode-precis?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true)](https://ci.appveyor.com/project/MARTIMM/unicode-precis/branch/master)
[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# PRECIS Framework: Preparation, Enforcement, and Comparison of Internationalized Strings in Application Protocols

Many tests are based on the Unicode® database as well as the unicode tools from perl6. Not all methods and functions are in place e.g. uniprop() is not yet available in the jvm. Also perl6 seems to be based on Unicode version 8.0.0 but is scheduled for 9.0.0. However parts are working in version 9.0.0 now. Not available in jvm yet are uniprop, uniprop-bool, uniprop-int, uniprop-str.

## Synopsis

```
use Unicode::PRECIS;
use Unicode::PRECIS::Identifier::UsernameCasePreserved;

my Unicode::PRECIS::Identifier::UsernameCaseMapped $uname-profile .= new;

my Str $username = "نجمة-الصباح";
my TestValue $tv = $uname-profile.enforce($username);
if $tv ~~ Str {
  say "Username $username accepted but converted to $tv";
}

elsif $tv ~~ Bool {
  say "Username not accepted";
}

```

## RFC's and program documentation

#### Module documentation

* [Bugs, known limitations and todo](https://github.com/MARTIMM/unicode-precis/blob/master/doc/TODO.md)
* [Release notes](https://github.com/MARTIMM/unicode-precis/blob/master/doc/CHANGES.md)

#### Base information for the modules

I've started to study rfc4013 for SASLprep. Then recognized it was a profile based on Stringprep specified in rfc3454. Both are obsoleted by rfc7613 and rfc7564 resp because they are tied to Unicode version 3.2. The newer rfc's are specified to be free of any Unicode version.

* rfc3454 - Preparation of Internationalized Strings ("stringprep").
* [rfc7564 - PRECIS Framework: Preparation, Enforcement, and Comparison of Internationalized Strings in Application Protocols](https://tools.ietf.org/html/rfc7564#section-4.1) Obsoletes rfc3454.
* rfc4013 - SASLprep: Stringprep Profile for User Names and Passwords
* [rfc7613 - Preparation, Enforcement, and Comparison of Internationalized Strings Representing Usernames and Passwords](https://tools.ietf.org/html/rfc7613#section-3.1) Obsoletes rfc4013.

#### Further needed information

* [rfc5892 - The Unicode Code Points and Internationalized Domain Names for Applications (IDNA)](https://tools.ietf.org/html/rfc5892#section-2.8)
* [rfc5893 - Right-to-Left Scripts for Internationalized Domain Names for Applications (IDNA)](https://tools.ietf.org/html/rfc5893#section-2)
Several files are found at the Unicode® Character Database to generate the tables needed to find the proper character classes.

#### From unicode.org
* [UnicodeData.txt]( http://www.unicode.org/Public/9.0.0/ucd/UnicodeData.txt)
* [Whole zip file UCD.zip of version 9.0.0 including UnicodeData.txt]( http://www.unicode.org/Public/9.0.0/ucd/UCD.zip)
* [Unicode Data File Format]( ftp://unicode.org/Public/3.2-Update/UnicodeData-3.2.0.html)
* [Unicode Normalization Forms \#15](http://unicode.org/reports/tr15/)
* [Unicode Character Database \#44](http://unicode.org/reports/tr44/)
* [East Asian Width \#11](http://unicode.org/reports/tr11/)
* [Unicode Bidirectional Algorithm \#9](http://unicode.org/reports/tr9/)


## Perl 6

Perl 6 uses graphemes as a base for the Str string type. These are the visible entities which show as a single symbol and are counted as such with the ```Str.chars``` method. From this, normal forms can be generated using the string methods uniname, uninames, unival, univals, NFC, NFD, NFKC and NFKD. Furthermore the strings can be encoded to utf-8.

#### Versions of perl, moarvm

This project is tested with latest Rakudo built on MoarVM implementing Perl v6.c.

## Implementation track

First the basis of the PRECIS framework will be build. As soon as possible a profile for usernames and passwords follows. This is my first need. When this functions well enough, other profiles can be inserted. Much of it is now Implemented.

Naming of modules;
  * Unicode::PRECIS using rfc7564
  * Unicode::PRECIS::Identifier using rfc7564
  * Unicode::PRECIS::Identifier::UsernameCaseMapped using rfc7613
  * Unicode::PRECIS::Identifier::UsernameCasePreserved using rfc7613
  * Unicode::PRECIS::Freeform using rfc7564
  * Unicode::PRECIS::Freeform::OpaqueString using rfc7613


## Authors

```
Marcel Timmerman translation of the modules for perl 6
```
## Contact

MARTIMM [on github](https://github.com/MARTIMM)
