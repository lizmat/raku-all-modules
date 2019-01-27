use v6.c;
use Test;
use FINALIZER <class-only>;

plan 1;

my @order;

sub dbiconnect($string) {
    LEAVE @order.push: "leaving $string";
    my $dbh = $string;
    FINALIZER.register: { @order.push: "leaving registered with $dbh" }
    $dbh
}

LEAVE @order.push: "leaving program";
{
    LEAVE @order.push: "leaving outer";
    {
        use FINALIZER;
        my $dbh = dbiconnect("frobnicate");
        @order.push: "doing stuff with $dbh";
    }
}

END is-deeply @order, [
  "leaving frobnicate",
  "doing stuff with frobnicate",
  "leaving registered with frobnicate",
  "leaving outer",
  "leaving program",
], 'Did all of the things happen in the correct order';

# vim: ft=perl6 expandtab sw=4
