use v6;
use TXN::Parser;
unit module TXN;

multi sub emit(
    Str:D $content,
    Bool :$json,
    *%opts (Int :$date-local-offset)
)
{
    my @txn = TXN::Parser.parse($content, |%opts).made;
    emit(:@txn, :$json);
}

multi sub emit(
    Str:D :$file!,
    Bool :$json,
    *%opts (Int :$date-local-offset)
)
{
    my @txn = TXN::Parser.parsefile($file, |%opts).made;
    emit(:@txn, :$json);
}

multi sub emit(:@txn!, Bool:D :$json! where *.so)
{
    # stringify DateTimes in preparation for JSON serialization
    loop (my Int $i = 0; $i < @txn.elems; $i++)
    {
        @txn[$i]<header><date> = ~@txn[$i]<header><date>;
    }

    use JSON::Tiny;
    to-json(@txn);
}

multi sub emit(:@txn!, Bool :$json)
{
    @txn;
}

multi sub from-txn(
    Str:D $content,
    *%opts (Int :$date-local-offset, Bool :$json)
) is export
{
    emit($content, |%opts);
}

multi sub from-txn(
    Str:D :$file!,
    *%opts (Int :$date-local-offset, Bool :$json)
) is export
{
    emit(:$file, |%opts);
}

# vim: ft=perl6
