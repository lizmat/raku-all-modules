unit module Coroutines;

my @coroutines;

enum CoroStatus <still_going done>;

sub async(&coroutine) is export {
    @coroutines.push($(gather {
        &coroutine();
        take CoroStatus::done;
    }));
}

#= must be called from inside a coroutine
sub yield is export {
    take CoroStatus::still_going;
}

#= should be called from mainline code
sub schedule is export {
    return unless +@coroutines;
    my $r = @coroutines.shift;
    if $r.shift ~~ CoroStatus::still_going {
        @coroutines.push($r);
    }
}
