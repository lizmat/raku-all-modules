use v6;
use lib 'lib';
use Test;
use TXN::Parser::Grammar;

plan 3;

# include grammar tests {{{

subtest
{
    my Str @include_lines;

    push @include_lines, Q:to/EOF/;
    include 'includes/2014'
    EOF

    push @include_lines, Q:to/EOF/;
    include "includes/2014"
    EOF

    push @include_lines, Q:to/EOF/;
    include 'journal includes/file with whitespace'
    EOF

    push @include_lines, Q:to/EOF/;
    include "journal includes/file with whitespace"
    EOF

    sub is_valid_include_line(Str:D $include_line) returns Bool:D
    {
        TXN::Parser::Grammar.parse($include_line, :rule<include_line>).so;
    }

    ok(
        @include_lines.grep({is_valid_include_line($_)}).elems ==
            @include_lines.elems,
        q:to/EOF/
        ♪ [Grammar.parse($include_line, :rule<include_line>)] - 1 of 4
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Include lines validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end include grammar tests }}}
# entry grammar tests {{{

subtest
{
    my Str @entries;

    push @entries, Q:to/EOF/;
    2015-01-01#comment
      ASSETS."∅"."First Bank Checking"  $440.00 USD
      INCOME."∅".interest               $440.00 USD
    EOF

    push @entries, Q:to/EOF/;
    2015-01-01 "I bought fuel at Shell station"# EODESC comment
      # comment
      expenses.personal.fuel.shell  $57.00 USD#comment
      # comment
      liabilities.personal.amex     $57.00 USD#comment
      # comment
      # comment
    EOF

    push @entries, Q:to/EOF/;
    2015-01-01

    # comment
    # comment
    # comment

    @tag1 @tag2 @tag3 !!!
    """
    This is a multiline description.
    """
    @more1 @more2 @more3

    # comment
    # comment
    # comment

    Assets:Business:Cats        1 XCAT @ $1200.00 USD
    Expenses:Business:Cats      $1200.00 USD
    EOF

    sub is_valid_entry(Str:D $entry) returns Bool:D
    {
        TXN::Parser::Grammar.parse($entry, :rule<entry>).so;
    }

    ok(
        @entries.grep({is_valid_entry($_)}).elems == @entries.elems,
        q:to/EOF/
        ♪ [Grammar.parse($entry, :rule<entry>)] - 2 of 4
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Entries validate successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end entry grammar tests }}}
# journal grammar tests {{{

subtest
{
    my Str $journal = slurp 't/data/sample/sample.txn';
    my Str $journal_quoted =
        slurp 't/data/quoted-asset-codes/quoted-asset-codes.txn';

    my $journal_match = TXN::Parser::Grammar.parse($journal);
    my $journal_quoted_match = TXN::Parser::Grammar.parse($journal_quoted);

    is(
        $journal_match.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($journal)] - 3 of 4
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Journal validates successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $journal_quoted_match.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($journal_quoted)] - 4 of 4
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Journal with quoted asset codes validates
        ┃   Success   ┃    successfully, as expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end journal grammar tests }}}

# vim: ft=perl6 fdm=marker fdl=0
