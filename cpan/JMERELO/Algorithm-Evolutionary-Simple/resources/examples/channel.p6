#!/usr/bin/env perl6

# An example of using concurrent evaluation with channels

use v6;

use Algorithm::Evolutionary::Simple;

my $length = 16;
my Channel $channel-pop .= new;
my Channel $channel-batch = $channel-pop.Supply.batch( elems => 2).Channel;
my Channel $output .= new;

my $count = 0;
$channel-pop.send( random-chromosome($length).list ) for ^11;

my $pairs = start react whenever $channel-batch -> @pair {
    if ( $count++ < 100 ) {
	say "In Channel 2: ", @pair;
	$output.send(  $_ => max-ones($_)  ) for @pair;
	my @new-chromosome = crossover( @pair[0], @pair[1] );
	$channel-pop.send( $_.list ) for @new-chromosome;
    } else {
	say "Closing channel";
	$channel-pop.close;
    }
}

await $pairs;
loop {
    if my $item = $output.poll {
	$item.say;
    } else {
	$output.close;
    }
    if $output.closed  { last };
}

