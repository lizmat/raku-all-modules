use Concurrent::Progress;
use Test;
use Test::Scheduler;

{
    my $*SCHEDULER = Test::Scheduler.new;
    my $prog = Concurrent::Progress.new(min-interval => 1);
    my @reports;
    my $done;
    $prog.Supply.tap: { @reports.push($_) }, done => { $done = True };
    $*SCHEDULER.advance;

    $prog.increment;
    is @reports.elems, 1, 'Got a report after initial increment';
    given @reports[0] {
        is .value, 1, 'First increment produces value of 1';
    }

    $*SCHEDULER.advance-by(0.5);
    $prog.increment;
    is @reports.elems, 1, 'Second report in less than a second causes no report';

    $*SCHEDULER.advance-by(1);
    is @reports.elems, 2, 'Once the second tick hits, report delivered';
    given @reports[1] {
        is .value, 2, 'Report now has value of 2';
    }

    $*SCHEDULER.advance-by(1);
    is @reports.elems, 2, 'Another second later, no more reports sent';

    $*SCHEDULER.advance-by(0.1);
    $prog.increment;
    is @reports.elems, 3, 'Next report comes immediately because none in the last second';
    given @reports[2] {
        is .value, 3, 'Report now has value of 3';
    }

    $*SCHEDULER.advance-by(0.1);
    $prog.increment;
    $*SCHEDULER.advance-by(0.2);
    $prog.increment;
    is @reports.elems, 3, 'Two more increments in the next 0.3 seconds cause no emits';
    $*SCHEDULER.advance-by(0.6);
    is @reports.elems, 4, 'When next second tick comes, report can be sent';
    given @reports[3] {
        is .value, 5, 'Report now has value of 5';
    }
}

{
    my $*SCHEDULER = Test::Scheduler.new;
    my $prog = Concurrent::Progress.new(min-interval => 1, :!auto-done);
    my @reports;
    my $done;
    $prog.Supply.tap: { @reports.push($_) }, done => { $done = True };
    $*SCHEDULER.advance;

    $prog.set-target(50);
    is @reports.elems, 1, 'Got a report after setting target';
    given @reports[0] {
        is .value, 0, 'First report has 0 as value';
        is .target, 50, 'First report has correct target';
    }

    $*SCHEDULER.advance-by(0.5);
    $prog.add(10);
    is @reports.elems, 1, 'Add in less than a second causes no report';

    $*SCHEDULER.advance-by(0.25);
    $prog.add(10);
    is @reports.elems, 1, 'Another in less than a second causes no report';

    $*SCHEDULER.advance-by(0.25);
    is @reports.elems, 2, 'After we reach 1 second from start, get a report';
    given @reports[1] {
        is .value, 20, 'Second report has correct value';
        is .target, 50, 'Second report has correct target';
    }

    $*SCHEDULER.advance-by(0.25);
    $prog.add(20);
    is @reports.elems, 2, 'Another add 0.25 seconds later causes no output';

    $*SCHEDULER.advance-by(0.25);
    $prog.add(10);
    is @reports.elems, 3, 'Add that brings us to the target causes early output';
    given @reports[2] {
        is .value, 50, 'Third report has correct value';
        is .target, 50, 'Third report has correct target';
    }

    $*SCHEDULER.advance-by(0.5);
    is @reports.elems, 3, 'No accidental output leakage later';
}

done-testing;
