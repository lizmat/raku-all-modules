use v6;
use lib 'lib';
use Test;
use TXN;

plan 1;

=begin pod

=heading1 Purpose

The purpose of this test is to ensure transaction journals serialized
to JSON and round tripped back to Perl 6 are equivalent to transaction
journals parsed normally.

=end pod

subtest
{
    my Str $file = 't/data/sample/sample.txn';

    # old fashioned way
    my TXN::Parser::Actions $actions .= new;
    my $match_journal = TXN::Parser::Grammar.parsefile($file, :$actions);

    # with public API
    my @txn = from-txn(:$file);

    # with JSON round trip
    use JSON::Tiny;
    my $json = from-txn(:$file, :json);
    my @round_trip = from-json($json);

    is(
        @txn,
        $match_journal.made,
        q:to/EOF/
        ♪ [Is from-txn equivalent to Match.made?] - 1 of 2
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ from-txn produces equivalent results to
        ┃   Success   ┃    Match.made, as expected
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        @txn,
        @round_trip,
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

# vim: ft=perl6
