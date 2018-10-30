#!/usr/bin/perl6

use v6;

# a task test

use Test;
use Coro::Simple;

plan 1;

my @tasks;

sub add-task ($block) {
    my $coro = coro $block;
    @tasks.push: $coro( );
}

sub dispatch-now ( ) {
    while ?@tasks {
	my $task = @tasks.shift;
	@tasks.push: $task if $task( );
    }
    True;
}

# add a task and run getting started with it
sub spawn-task ($block) {
    my $coro = coro $block;
    my $task = $coro( );
    @tasks.push: $task if $task( );
    ok dispatch-now;
}

# tasks
add-task {
    for ^3 -> $i {
	say "Ping -> $i";
	suspend;
    }
}

add-task {
    for ^5 {
	say [~] <<\n WTF? \n\n>>;
	suspend;
    }
}

spawn-task {
    for ^8 -> $i {
	say "Pong -> $i";
	suspend;
    }
}

# end of test