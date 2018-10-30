[![Build Status](https://travis-ci.org/zoffixznet/perl6-Lingua-Conjunction.svg)](https://travis-ci.org/zoffixznet/perl6-Lingua-Conjunction)

# NAME

Lingua::Conjunction - Convert lists into linguistic conjunctions and fill them into a template

# SYNOPSIS

```perl6
    use Lingua::Conjunction;

    say conjunction <chair>; # chair
    say conjunction <chair spoon>; # chair and spoon
    say conjunction <chair spoon window>; # chair, spoon, and window

    # "Tom, a man; Tiffany, a woman; and GumbyBRAIN, a bot"
    say conjunction 'Tom, a man', 'Tiffany, a woman', 'GumbyBRAIN, a bot';

    # These are reports for May, June, and August
    say conjunction <May June August>, :str('These [is|are] report[|s] for |list|');

    # "Jacques, un garcon; Jeanne, une fille et Spot, un chien"
    say conjunction 'Jacques, un garcon', 'Jeanne, une fille', 'Spot, un chien',
        :lang<fr>;
```

# Table of Contents
- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [EXPORTED SUBROUTINES](#exported-subroutines)
    - [`conjunction`](#conjunction)
        - [`alt`](#alt)
        - [`con`](#con)
        - [`dis`](#dis)
        - [`lang`](#lang)
        - [`last`](#last)
        - [`sep`](#sep)
        - [`str`](#str)
        - [`type`](#type)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# DESCRIPTION

Provides a way to make it easy to prepare a string containing a list of items,
where that string is meant to be read by a human.

# EXPORTED SUBROUTINES

## `conjunction`

    say conjunction <chair spoon>;
    say conjunction <May June August>, :str('Report[|s] for |list|'),
        :lang<fr>, :!last, :sep<·>, :alt<°>, :con<aaand>, :dis<ooor>, :type<or>;

Returns a string with the given list of items joined based on the
configuration specified by the named arguments, which are as follows:

### `alt`

Specifies an alternative separator to use when at least one of the items
contains `sep` separator. **Defaults to** `;` (a semicolon).

### `con`

Short for **con**junction. The term to use when joining the last item
to the previous one, when `type` argument is set to value `and`.
**By default** is set based on value of `lang` argument.

### `dis`

Short for **dis**junction. The term to use when joining the last item
to the previous one, when `type` argument is set to value `or`.
**By default** is set based on value of `lang` argument.

### `lang`

Takes a string representing the code of the language to use. This will
pre-set `con`, `dis`, and `last` arguments. **Defaults to** `en`.
Currently supported languages and the defaults they pre-set are as follows
(language is the first two-letter key on the left; that's what you'd
specify as `lang` argument):

```perl6
    af => { last => True,  con => 'en',  dis => 'of'    },
    da => { last => True,  con => 'og',  dis => 'eller' },
    de => { last => True,  con => 'und', dis => 'oder'  },
    en => { last => True,  con => 'and', dis => 'or'    },
    es => { last => True,  con => 'y',   dis => 'o'     },
    fi => { last => True,  con => 'ja',  dis => 'tai'   },
    fr => { last => False, con => 'et',  dis => 'ou'    },
    it => { last => True,  con => 'e',   dis => 'o'     },
    la => { last => True,  con => 'et',  dis => 'vel'   },
    nl => { last => True,  con => 'en',  dis => 'of'    },
    no => { last => False, con => 'og',  dis => 'eller' },
    pt => { last => True,  con => 'e',   dis => 'ou'    },
    sw => { last => True,  con => 'na',  dis => 'au'    },
```

### `last`

Specifies whether to use `sep` when joining the penultimate and last elements
of the list, when the number of elements is more than 2. In English, this
is what's known as [Oxford Comma](https://en.wikipedia.org/wiki/Serial_comma).
**By default** is set based on value of `lang` argument.

### `sep`

The primary item separator to use. **Defaults to** `,` (a comma).

### `str`

    say conjunction <May June August>, :str('Report[|s] for |list|');
    say conjunction <Squishy Slushi Sushi>,
        :str('Octop[us|i] [is|are] named |list|');

Specifies a template to use when generating the string. You can use
special sequence `[|]` (e.g. `octop[us|i]`) where string to the left of
the `|` will be used when the list contains just one item and the string to
the right will be used otherwise. The other special sequence is
`|list|` that can will be replaced with the "conjuncted" items of the list.
**Defaults to** `|list|`

### `type`

Takes either value `and` or value `or`. Specifies whether words
specified by `con` or by `dis` arguments should be used when joining the
last two elements of the list.

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Lingua-Conjunction

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Lingua-Conjunction/issues

# AUTHOR

This module was inspired by Perl 5's
[Lingua::Conjunction](https://metacpan.org/pod/Lingua::Conjunction) and
and my own
[List::ToHumanString](https://metacpan.org/pod/List::ToHumanString). Some
of the internal data was shamelessly ~~stolen~~ borrowed from
[Lingua::Conjunction](https://metacpan.org/pod/Lingua::Conjunction)'s guts.

The rest is by Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

