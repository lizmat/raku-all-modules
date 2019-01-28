use v6.c;

unit module P5lc:ver<0.0.6>:auth<cpan:ELIZABETH>;

proto sub lc(|) is export {*}
multi sub lc(         --> Str:D) { (CALLERS::<$_>).lc }
multi sub lc(Str() $s --> Str:D) { $s.lc              }

proto sub uc(|) is export {*}
multi sub uc(         --> Str:D) { (CALLERS::<$_>).uc }
multi sub uc(Str() $s --> Str:D) { $s.uc              }

=begin pod

=head1 NAME

P5lc - Implement Perl 5's lc() / uc() built-ins

=head1 SYNOPSIS

  use P5lc;

  say lc "FOOBAR"; # foobar
  with "ZIPPO" {
      say lc();  # zippo, may need to use parens to avoid compilation error
  }

  say uc "foobar"; # FOOBAR
  with "zippo" {
      say uc();  # ZIPPO, may need to use parens to avoid compilation error
  }

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<lc> / C<uc> functions of
Perl 5 as closely as possible.

=head1 ORIGINAL PERL 5 DOCUMENTATION

    lc EXPR
    lc      Returns a lowercased version of EXPR. This is the internal
            function implementing the "\L" escape in double-quoted strings.

            If EXPR is omitted, uses $_.

            What gets returned depends on several factors:

            If "use bytes" is in effect:
                The results follow ASCII rules. Only the characters "A-Z"
                change, to "a-z" respectively.

            Otherwise, if "use locale" (but not "use locale
            ':not_characters'") is in effect:
                Respects current LC_CTYPE locale for code points < 256; and
                uses Unicode rules for the remaining code points (this last
                can only happen if the UTF8 flag is also set). See perllocale.

                Starting in v5.20, Perl wil use full Unicode rules if the
                locale is UTF-8. Otherwise, there is a deficiency in this
                scheme, which is that case changes that cross the 255/256
                boundary are not well-defined. For example, the lower case of
                LATIN CAPITAL LETTER SHARP S (U+1E9E) in Unicode rules is
                U+00DF (on ASCII platforms). But under "use locale" (prior to
                v5.20 or not a UTF-8 locale), the lower case of U+1E9E is
                itself, because 0xDF may not be LATIN SMALL LETTER SHARP S in
                the current locale, and Perl has no way of knowing if that
                character even exists in the locale, much less what code point
                it is. Perl returns the input character unchanged, for all
                instances (and there aren't many) where the 255/256 boundary
                would otherwise be crossed.

            Otherwise, If EXPR has the UTF8 flag set:
                Unicode rules are used for the case change.

            Otherwise, if "use feature 'unicode_strings'" or "use locale
            ':not_characters'" is in effect:
                Unicode rules are used for the case change.

            Otherwise:
                ASCII rules are used for the case change. The lowercase of any
                character outside the ASCII range is the character itself.

    uc EXPR
    uc      Returns an uppercased version of EXPR. This is the internal
            function implementing the "\U" escape in double-quoted strings. It
            does not attempt to do titlecase mapping on initial letters. See
            "ucfirst" for that.

            If EXPR is omitted, uses $_.

            This function behaves the same way under various pragma, such as
            in a locale, as "lc" does.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5lc . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
