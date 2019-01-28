use v6.c;

unit class Test::Declare::Expectations;

use Test::Declare::Comparisons;

sub make-rough($rv) {
    $rv.isa('Test::Declare::Comparisons::Roughly')
        ?? $rv
        !! Test::Declare::Comparisons::Roughly.new(rhs=>$rv)
}

has $.stdout;
has $.stderr;

has $.return-value;
has $.mutates;

has $.lives;
has $.dies;
has $.throws;

submethod BUILD(:$stdout, :$stderr, :$return-value, :$mutates, :$!lives, :$!dies, :$!throws) {
    if $stdout {
        $!stdout = make-rough($stdout);
    }
    if $stderr {
        $!stderr = make-rough($stderr);
    }
    if $return-value {
        $!return-value = make-rough($return-value);
    }
    if $mutates {
        $!mutates = make-rough($mutates);
    }
}
