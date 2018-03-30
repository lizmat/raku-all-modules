[![Build Status](https://travis-ci.org/chsanch/perl6-Lingua-Stopwords.svg?branch=master)](https://travis-ci.org/chsanch/perl6-Lingua-Stopwords)

# NAME

Lingua::Stopwords - Stop words for several languages.

# SYNOPSIS

```perl6
    use Lingua::Stopwords;

    # Get the stopwords list, the first parameter is the iso code language and the second is the list type
    my $stopwords = get-stopwords('en', 'snowball');

    my $text = "This is a test and it has some stopwords. This is a test for a Perl 6 module to extract them";

    # It will return a Set of words without the stopwords
    my $text-parsed = $text.subst(/<:punct>/, '', :g).words.grep: { !$stopwords{$_}};

    say $text-parsed.join(' '); # OUTPUT: This test stopwords This test Perl 6 module extract

    # $stopwords is a a SetHash, so you can add more words
    $stopwords<Perl>++;

    $text-parsed = $text.subst(/<:punct>/, '', :g).words.grep: { !$stopwords{$_}};

    say $text-parsed.join(' '); #OUTPUT: This test stopwords This test 6 module extract

    
```
## TABLE OF CONTENTS
- [NAME](#name)
- [SYNOPSIS](#synopsis)
    - [TABLE OF CONTENTS](#table-of-contents)
- [DESCRIPTION](#description)
    - [Supported languages](#supported-languages)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# DESCRIPTION

This module provides Stopwords for several languages.

## Supported languages

For each language, this module provides Stopwords list from different sources. The _all_ type list contained all the list available for the language.

| Language   | ISO code | List type               |
| ---------- | :------: | :---------------------: |
| Catalan    | ca       | ranks-nl                |
| Danish     | da       | snowball, ranks-nl, all |
| Dutch      | nl       | snowball, ranks-nl, all |
| English    | en       | snowball, ranks-nl, all |
| Finnish    | fi       | snowball, ranks-nl, all |
| French     | fr       | snowball, ranks-nl, all |
| Galician   | gl       | ranks-nl                |
| German     | de       | snowball, ranks-nl, all |
| Hebrew     | he       | ranks-nl                |
| Hungarian  | hu       | snowball, ranks-nl, all |
| Italian    | it       | snowball, ranks-nl, all |
| Norwegian  | no       | snowball, ranks-nl, all |
| Portuguese | pt       | snowball, ranks-nl, all |
| Russian    | ru       | snowball, ranks-nl, all |
| Spanish    | es       | snowball, ranks-nl, all |
| Swedish    | sv       | snowball, ranks-nl, all |

---
# REPOSITORY

Fork this module on GitHub:
https://github.com/chsanch/perl6-Lingua-Stopwords

# BUGS

To report bugs or request features, please use
https://github.com/chsanch/perl6-Lingua-Stopwords/issues

# AUTHOR

This module was inspired by Perl 5's module [Lingua::Stopwords](https://metacpan.org/pod/Lingua::StopWords).

The snowball stoplists by this module were created as part of the [Snowball project](see http://snowball.tartarus.org).

The Ranks NL stoplists by this module were created by [Ranks NL](https://www.ranks.nl/stopwords).

Christian Sánchez <chsanch@cpan.org>.

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
