#!/usr/bin/perl6

use v6;

# a task test

use Test;
use Coro::Simple;

plan 16;

my @tasks; # a queue of tasks

# function to add some task (on last position)
sub add-task ($block) {
    my $coro = coro $block;
    @tasks.push: $coro( ); # enqueue a generator
}

# to run the things
sub dispatch-now ( ) {
    while ?@tasks {
	my $task = @tasks.shift; # dequeue a task
	@tasks.push: $task if $task( ); # enqueue again if it still alive
    }
}

# add a task and run getting started with it
sub spawn-task ($block) {
    my $coro = coro $block;
    my $task = $coro( );
    @tasks.push: $task if $task( );
    return dispatch-now;
}

# tasks
add-task {
    for ^3 -> $i {
	ok say "Ping -> $i";
	sleep 0.5;
	suspend;
    }
}

add-task {
    for ^5 {
	ok say [~] <<\n WTF? \n\n>>;
	sleep 0.5;
	suspend;
    }
}

# begin to run the tasks
spawn-task {
    for ^8 -> $i {
	ok say "Pong -> $i";
	sleep 0.5;
	suspend;
    }
}

# end of test