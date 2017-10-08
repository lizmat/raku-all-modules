#!perl6

use Test;

use EventSource::Server;

my $supply = <1 2 3>.Supply.map( -> $data { EventSource::Server::Event.new(type => 'message', :$data ) } );

my $e = EventSource::Server.new(:$supply);

ok  $e ~~ Callable, "the object is Callable";
can-ok $e, 'out-supply';
can-ok $e, 'headers';
can-ok $e, 'emit';

my $count = 0;
for $e.out-supply.list -> $m {
    $count++;
    isa-ok $m, utf8;
    my $mess = $m.decode;
    like $mess, rx/'event: message'/;
    like $mess, rx/'data: '$count/;
    last if $count == 3;
}

is $count, 3, "and we got three messages";

done-testing;




# vim: ft=perl6 ts=4 sw=4 expandtab
