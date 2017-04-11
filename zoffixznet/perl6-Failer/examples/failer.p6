use lib <lib>;
use Failer;

sub do-stuff { fail "meow" }

sub meows {
    $*CWD = no-fail do-stuff;  # leaves $*CWD untouched; returns unhandled Failure
    my $foo = do-stuff ∨-fail; # returns unhandled Failure

    my $f = Failure.new;
    say so-fail $f; # like regular `so`, but leaves Failure unhandled
    say de-fail $f; # like regular `defined`, but leaves Failure unhandled
}

say meows.handled
