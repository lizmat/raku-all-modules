use v6.d;
use lib './build-tools/lib';
use Test;
use OOPTest;
use OO::Plugin;
use OO::Plugin::Manager;

plan 29;

# $got is a completion promise from event dispatcher
sub events-ok ( Promise:D $got, %expected, Str:D $message ) {
    # note $got, " // ", $got.result;
    # note "<<< RESULT: ", $got.result
    #             .map( *.result )
    #             .map( { ":" ~ $_[0].name ~ "($_[1])" } )
    #             .join(", ");
    my %got = $got.result
                .map( *.result )
                .map( { $_[0].name => $_[1] } );
    is-deeply %got, %expected, $message;
}

role TestEvt {
    multi method on-event ( 'test-event1' ) {
        pass "event1 on " ~ self.short-name;
        sleep .1;
        42
    }
    multi method on-event ( 'test-event2' ) {
        pass "event2 on " ~ self.short-name;
        self.short-name
    }
}

role Plug1Role {
    multi method on-event ( 'test-event1' ) {
        pass "event1 handled individually and slowly by " ~ self.name;
        sleep 1;
        -42
    }

    multi method on-event( 'test-event3', Int:D $n ) {
        # Only handled by this role
        pass "event3 is being handled";
        "$n × 10 = {$n × 10}"
    }
}

my %params =
    count => 10,
    default-roles => TestEvt,
    roles => {
        1 => Plug1Role,
    },
    ;

gen-plugins( %params );

my $mgr = OO::Plugin::Manager.new: :!debug, :event-workers(3), :ev-dispatcher-timeout(1);
$mgr.initialize;

my @ep;
my $l = Lock.new;
my @complete-order;
@ep.push: $mgr.event( 'test-event1' ).then( {
    # pass "event1 completed by all handlers";
    # diag "test-event1 is completed: " ~ $_.result.map( *.result ).map({ $_[0].^name ~ ":" ~ $_[1] });
    $l.protect: { @complete-order.push: "event1" };
    events-ok $_,
                {:P0(42), :P1(-42), :P2(42), :P3(42), :P4(42), :P5(42), :P6(42), :P7(42), :P8(42), :P9(42), },
                "returns from event1 handlers";
} );
@ep.push: $mgr.event( 'test-event2' ).then( {
    # pass "event2 completed by all handlers";
    # diag "test-event2 is completed: " ~ $_.result.map( *.result ).map({ $_[0].^name ~ ":" ~ $_[1] });
    # P1 doesn't define test-event2 handler, thus it is missing in the list
    $l.protect: { @complete-order.push: "event2" };
    events-ok $_,
                {:P0<P0.0>, :P2<P2.2>, :P3<P3.3>, :P4<P4.4>, :P5<P5.5>, :P6<P6.6>, :P7<P7.7>, :P8<P8.8>, :P9<P9.9>, },
                "returns from event2 handlers";
} );
await @ep;

# They're done in reverse order due to sleeps in event1 handlers.
is-deeply @complete-order, [<event2 event1>], "event completion order";

sleep 1.5; # Make sure event dispatcher will shutdown – see ev-dispatcher-timeout parameter above

await $mgr.event( 'test-event3', 42 ).then( {
    is $_.result.elems, 1, "event3: one result returned";
    my $ev-result = $_.result[0].result;
    is $ev-result[0].name, "P1", "event3 single result comes from P1";
    is $ev-result[1], "42 × 10 = 420", "event3 result: as expected";
} );

await $mgr.event( 'test-noevent' ).then( {
    pass "no handlers for dispatched noevent is ok";
    is $_.result.elems, 0, "0 results for noevent";
} );

$mgr.finish;

pass "manager finished";

done-testing;

# vim: ft=perl6
