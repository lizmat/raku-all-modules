use lib 'lib';
use Test;
use Games::TauStation::DateTime;

plan +my @dates = (
    ^100  .map("198.18/05:4" ~ *.fmt("%02d") ~ " GCT"),
    ^1000 .map({
                (^1000 .pick.fmt: '%03d')
        ~ '.' ~ (^100  .pick.fmt: '%02d')
        ~ '/' ~ (^100  .pick.fmt: '%02d')
        ~ ':' ~ (^1000 .pick.fmt: '%03d') ~ ' GCT'}),
    «'100.18/05:407 GCT' '000.18/05:407 GCT' '100.99/99:999 GCT'»
).flat;
is GCT.new($_), $_, $_ for @dates;
