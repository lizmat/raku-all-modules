use v6;
use TXN::Parser::Grammar;
unit module TXNParserTest;

sub is-valid-account(Str:D $account --> Bool:D) is export
{
    my Bool:D $is-valid-account =
        TXN::Parser::Grammar.parse($account, :rule<account>).so;
}

sub is-valid-amount(Str:D $amount --> Bool:D) is export
{
    my Bool:D $is-valid-amount =
        TXN::Parser::Grammar.parse($amount, :rule<amount>).so;
}

sub is-valid-asset-code(Str:D $asset-code --> Bool:D) is export
{
    my Bool:D $is-valid-asset-code =
        TXN::Parser::Grammar.parse($asset-code, :rule<asset-code>).so;
}

sub is-valid-asset-quantity(Str:D $asset-quantity --> Bool:D) is export
{
    my Bool:D $is-valid-asset-quantity =
        TXN::Parser::Grammar.parse($asset-quantity, :rule<asset-quantity>).so;
}

sub is-valid-asset-symbol(Str:D $asset-symbol --> Bool:D) is export
{
    my Bool:D $is-valid-asset-symbol =
        TXN::Parser::Grammar.parse($asset-symbol, :rule<asset-symbol>).so;
}

sub is-valid-date(Str:D $date --> Bool:D) is export
{
    my Bool:D $is-valid-date =
        TXN::Parser::Grammar.parse($date, :rule<date>).so;
}

sub is-valid-description(Str:D $description --> Bool:D) is export
{
    my Bool:D $is-valid-description =
        TXN::Parser::Grammar.parse($description, :rule<description>).so;
}

sub is-valid-entry(Str:D $entry --> Bool:D) is export
{
    my Bool:D $is-valid-entry =
        TXN::Parser::Grammar.parse($entry, :rule<entry>).so;
}

sub is-valid-exchange-rate(Str:D $exchange-rate --> Bool:D) is export
{
    my Bool:D $is-valid-exchange-rate =
        TXN::Parser::Grammar.parse($exchange-rate, :rule<xe>).so;
}

sub is-valid-include-line(Str:D $include-line --> Bool:D) is export
{
    my Bool:D $is-valid-include-line =
        TXN::Parser::Grammar.parse($include-line, :rule<include-line>).so;
}

sub is-valid-metainfo(Str:D $metainfo --> Bool:D) is export
{
    my Bool:D $is-valid-metainfo =
        TXN::Parser::Grammar.parse($metainfo, :rule<metainfo>).so;
}

sub is-valid-plus-or-minus(Str:D $plus-or-minus --> Bool:D) is export
{
    my Bool:D $is-valid-plus-or-minus =
        TXN::Parser::Grammar.parse($plus-or-minus, :rule<plus-or-minus>).so;
}

sub is-valid-posting(Str:D $posting --> Bool:D) is export
{
    my Bool:D $is-valid-posting =
        TXN::Parser::Grammar.parse($posting, :rule<posting>).so;
}

sub is-valid-unit-of-measure(Str:D $unit-of-measure --> Bool:D) is export
{
    my Bool:D $is-valid-unit-of-measure =
        TXN::Parser::Grammar.parse($unit-of-measure, :rule<unit-of-measure>).so;
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
