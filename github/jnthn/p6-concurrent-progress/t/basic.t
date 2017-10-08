use Concurrent::Progress;
use Test;

{
    my $prog = Concurrent::Progress.new;
    my @reports;
    my $done;
    $prog.Supply.tap: { @reports.push($_) }, done => { $done = True };

    $prog.increment;
    is @reports.elems, 1, 'Got a report after increment';
    nok $done, 'Not done yet';
    given @reports[0] {
        is .value, 1, 'First increment produces value of 1';
        ok .target === Int, 'No target set means target is Int type object';
        ok .percent === Int, 'No target set means percent is Int type object';
    }

    $prog.increment;
    is @reports.elems, 2, 'Got a second report after increment';
    nok $done, 'Not done yet';
    given @reports[1] {
        is .value, 2, 'Second increment produces value of 2';
        ok .target === Int, 'No target set means target is still Int type object';
        ok .percent === Int, 'No target set means percent is still Int type object';
    }

    $prog.add(3);
    is @reports.elems, 3, 'Got a third report after add';
    nok $done, 'Not done yet';
    given @reports[2] {
        is .value, 5, 'Add of 3 produces value of 5 after 2 increments';
        ok .target === Int, 'No target set means target is still Int type object';
        ok .percent === Int, 'No target set means percent is still Int type object';
    }

    $prog.set-value(10);
    is @reports.elems, 4, 'Got a fourth report after set-value';
    nok $done, 'Not done yet';
    given @reports[3] {
        is .value, 10, 'Value is 10 after set-value of 10';
        ok .target === Int, 'No target set means target is still Int type object';
        ok .percent === Int, 'No target set means percent is still Int type object';
    }
}

{
    my $prog = Concurrent::Progress.new;
    my @reports;
    my $done;
    $prog.Supply.tap: { @reports.push($_) }, done => { $done = True };

    $prog.set-target(25);
    is @reports.elems, 1, 'Got a report when setting target';
    nok $done, 'Not done yet';
    given @reports[0] {
        is .value, 0, 'Value is 0 on initial report after setting target';
        is .target, 25, 'Target is correctly set';
        is .percent, 0, 'Percentage is correctly calculated';
    }

    $prog.increment;
    is @reports.elems, 2, 'Got second report after increment';
    nok $done, 'Not done yet';
    given @reports[1] {
        is .value, 1, 'Value is 1 after increment';
        is .target, 25, 'Target is still correctly set';
        is .percent, 4, 'Percentage is still correctly calculated';
    }

    $prog.add(23);
    is @reports.elems, 3, 'Got third report after add';
    nok $done, 'Not done yet';
    given @reports[2] {
        is .value, 24, 'Value is 24 after adding 23';
        is .target, 25, 'Target is still correctly set';
        is .percent, 96, 'Percentage is still correctly calculated';
    }

    $prog.increment;
    is @reports.elems, 4, 'Got fourth report after add';
    ok $done, 'We *are* done now the target is hit';
    given @reports[3] {
        is .value, 25, 'Value is 25 after another increment';
        is .target, 25, 'Target is still correctly set';
        is .percent, 100, 'Percentage is still correctly calculated';
    }
}

done-testing;
