use v6;
use lib 'lib';
use Test;
use TXN;

plan 1;

=begin pod

=heading1 Purpose

The purpose of this test is to ensure accounting ledgers serialized
to JSON and round tripped back to Perl6 are equivalent to accounting
ledgers parsed normally.

=end pod

subtest
{
    my Str $file = 't/data/sample/sample.txn';

    # with TXN::Parser
    my $match-ledger = TXN::Parser.parsefile($file);

    # with TXN
    my @txn = from-txn(:$file);

    # with TXN (JSON)
    my $json = from-txn(:$file, :json);
    my @round-trip = Rakudo::Internals::JSON.from-json($json);

    is-deeply(
        @txn,
        $match-ledger.made,
        q:to/EOF/
        ♪ [Is from-txn equivalent to Match.made?] - 1 of 2
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ from-txn produces equivalent results to
        ┃   Success   ┃    Match.made, as expected
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    # use is vs is-deeply to autostringify DateTimes in headers
    is(
        @txn,
        @round-trip,
        q:to/EOF/
        ♪ [Is from-txn JSON round trip valid?] - 2 of 2
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ from-txn(:json) round tripped produces
        ┃   Success   ┃    equivalent results to from-txn
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
