use v6;
use lib 'lib';
use TXN::Parser::Grammar;
use lib 't/lib';
use TXNParserTest;
use Test;

plan(3);

# include grammar tests {{{

subtest({
    my Str @include-line =
        Q:to/EOF/.trim,
        include 'includes/2014'
        EOF
        Q:to/EOF/.trim,
        include "includes/2014"
        EOF
        Q:to/EOF/.trim,
        include 'ledger includes/file with whitespace'
        EOF
        Q:to/EOF/.trim,
        include "ledger includes/file with whitespace"
        EOF
        Q:to/EOF/.trim,
        include <basic>
        EOF
        Q:to/EOF/.trim,
        include <FY/2011/Q1>
        EOF
        Q:to/EOF/.trim,
        include <ledger\ includes/lib\ with\ whitespace>
        EOF
        Q:to/EOF/.trim;
        include <includes\\/\>・ï\/©ㄦﬁ>
        EOF

    ok(
        @include-line
            .grep({ .&is-valid-include-line })
            .elems == @include-line.elems,
        q:to/EOF/
        ♪ [Grammar.parse($include-line, :rule<include-line>)] - 1 of 4
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Include lines validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end include grammar tests }}}
# entry grammar tests {{{

subtest({
    my Str @entry =
        Q:to/EOF/.trim,
        2015-01-01--comment
          ASSETS."∅"."First Bank Checking"  $440.00 USD
          INCOME."∅".interest               $440.00 USD
        EOF
        Q:to/EOF/.trim,
        2015-01-01 "I bought fuel at Shell station"-- EODESC comment
          -- comment
          expenses.personal.fuel.shell  $57.00 USD--comment
          -- comment
          liabilities.personal.amex     $57.00 USD--comment
        EOF
        Q:to/EOF/.trim;
        2015-01-01

        -- comment
        -- comment
        -- comment

        #tag1 #tag2 #tag3 !!!
        """
        This is a multiline description.
        """
        #more1 #more2 #more3

        -- comment
        -- comment
        -- comment

        Assets:Business:Cats        1 XCAT @ $1200.00 USD
        Expenses:Business:Cats      $1200.00 USD
        EOF

    ok(
        @entry.grep({ .&is-valid-entry }).elems == @entry.elems,
        q:to/EOF/
        ♪ [Grammar.parse($entry, :rule<entry>)] - 2 of 4
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Entries validate successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end entry grammar tests }}}
# ledger grammar tests {{{

subtest({
    my Str $ledger = slurp('t/data/sample/sample.txn');
    my Str $ledger-quoted =
        slurp('t/data/quoted-asset-codes/quoted-asset-codes.txn');

    my $ledger-match = TXN::Parser::Grammar.parse($ledger);
    my $ledger-quoted-match = TXN::Parser::Grammar.parse($ledger-quoted);

    is(
        $ledger-match.WHAT,
        TXN::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($ledger)] - 3 of 4
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Journal validates successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $ledger-quoted-match.WHAT,
        TXN::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($ledger-quoted)] - 4 of 4
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Journal with quoted asset codes validates
        ┃   Success   ┃    successfully, as expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end ledger grammar tests }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
