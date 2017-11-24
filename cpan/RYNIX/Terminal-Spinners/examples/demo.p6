#!/usr/bin/env perl6
use v6.c;
use Terminal::Spinners;

sub MAIN() {
    my $classic = Spinner.new: type => 'classic';
    my $promise = start sleep 2; # promise of your long running process
    until $promise.status {
        $classic.next; # prints the next spinner frame
    }

    say '';

    my $bounce = Spinner.new: type => 'bounce';
    $promise = start sleep 2; # promise of your long running process
    until $promise.status {
        $bounce.next; # prints the next spinner frame
    }

    say '';

    my $hash-bar = Bar.new; # defaults to the apt-get style hash bar
    $hash-bar.show: 0e0; # print a 0% progress bar
    for 1e0 .. 3000e0 {
        my $percent = $_ * 100e0 / 3000e0; # calculate a percentage as type Num
        sleep 0.0002; # do iterative work here
        $hash-bar.show: $percent; # print the progress bar and percent
    }

    say '';

    my $equals-bar = Bar.new: type => 'equals',
                              length => 50; # choose the equals type with custom length
    $equals-bar.show: 0e0; # print a 0% progress bar
    for 1e0 .. 3000e0 {
        my $percent = $_ * 100e0 / 3000e0; # calculate a percentage as type Num
        sleep 0.0002; # do iterative work here
        $equals-bar.show: $percent; # print the progress bar and percent
    }

    say '';
}
