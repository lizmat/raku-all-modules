![Perl CLDR](https://www.gravatar.com/avatar/656f15a25eff4437f5a82e7c929f41dd?s=96)

# NAME

CLDR::List - Localized list formatters using the Unicode CLDR

# SYNOPSIS

    use CLDR::List;

    my $list  = CLDR::List.new(locale => 'en');
    my @fruit = <apples oranges bananas>;

    say $list.format(@fruit);      # apples, oranges, and bananas

    $list.locale = 'en-GB';        # British English
    say $list.format(@fruit);      # apples, oranges and bananas

    $list.locale = 'zh-Hant';      # Traditional Chinese
    say $list.format('１'..'４');  # １、２、３和４

# DESCRIPTION

Localized list formatters using the Unicode CLDR.

## Attributes

- locale

## Methods

- format

# SEE ALSO

- [List Patterns in UTS \#35: Unicode LDML](http://www.unicode.org/reports/tr35/tr35-general.html\#ListPatterns)
- [Perl CLDR](http://perl-cldr.github.io/)

# AUTHOR

Nick Patch <patch@cpan.org>

# COPYRIGHT AND LICENSE

© 2013 Nick Patch

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
