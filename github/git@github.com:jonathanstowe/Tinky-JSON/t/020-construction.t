#!/usr/bin/env perl6

use v6.c;

use Test;

use Tinky::JSON;

my $json = $*PROGRAM.parent.child('data/ticket.json').slurp;


my $workflow;

lives-ok { 
    $workflow = Tinky::JSON::Workflow.from-json($json) ;
    }, "can make the object okay";

is $workflow.states.elems, 6, "got the expected number of states";
is $workflow.transitions.elems, 11, "got the expected number of transitions";


for $workflow.transitions -> $t {
    ok $workflow.states.grep( {  $t.from ===  $_ }), "from of transition is an existing state";
    ok $workflow.states.grep( {  $t.to ===  $_ }), "to of transition is an existing state";

}

my $workflow2 = Tinky::JSON::Workflow.from-json($json) ;

ok $workflow2.states.map(*.WHICH).none ⊆ $workflow.states.map(*.WHICH).any, "differ";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
