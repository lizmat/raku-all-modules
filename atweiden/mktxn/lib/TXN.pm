use v6;
use TXN::Parser;
unit module TXN;

sub emit(Str:D $journal, Int :$date-local-offset, Bool :$json)
{
    # perform parse with given options
    my %a;
    %a<date-local-offset> = $date-local-offset if $date-local-offset;
    %a<json> = $json if $json;
    my @txn = TXN::Parser.parse($journal, |%a).made;

    if $json
    {
        use JSON::Tiny;
        to-json(@txn);
    }
    else
    {
        @txn;
    }
}

multi sub from-txn(
    Str:D $content,
    Int :$date-local-offset,
    Bool :$json
) is export
{
    # resolve include directives in transaction journal
    my Str:D $journal = TXN::Parser.preprocess($content);

    my %a;
    %a<date-local-offset> = $date-local-offset if $date-local-offset;
    %a<json> = $json if $json;

    emit($journal, |%a);
}

multi sub from-txn(
    Str:D :$file!,
    Int :$date-local-offset,
    Bool :$json
) is export
{
    # resolve include directives in transaction journal
    my Str:D $journal = TXN::Parser.preprocess(:$file);

    my %a;
    %a<date-local-offset> = $date-local-offset if $date-local-offset;
    %a<json> = $json if $json;

    emit($journal, |%a);
}

# vim: ft=perl6
