# Test::Scheduler

An implementation of the Perl 6 `Scheduler` role that uses virtualized time.

## Synopsis

```
use Test;
use Test::Scheduler;

sub timeout($source, $timeout) {
    supply {
        whenever $source -> $value {
            state $values++;
            emit $value;

            my $last-values = $values;
            whenever Promise.in($timeout) {
                if $last-values == $values {
                    die "Timed out";
                }
            }
        }
    }
}

{
    my $*SCHEDULER = Test::Scheduler.new;
    my $test-source = supply {
        for 1, 2, 5 {
            whenever Promise.in($_) {
                emit 'badger';
            }
        }
    }
    my $timed-out = timeout($test-source, 2);
    my @received;
    my $died = False;
    $timed-out.tap:
        { @received.push($_) },
        quit => { $died = True }

    is @received, [], 'No values yet';

    $*SCHEDULER.advance-by(1);
    is @received, ['badger'], 'one value after 1s';
    nok $died, 'No timeout yet';

    $*SCHEDULER.advance-by(1);
    is @received, ['badger', 'badger'], 'Two value after 2s';
    nok $died, 'No timeout yet';

    $*SCHEDULER.advance-by(1);
    is @received, ['badger', 'badger'], 'Still two value after 3s';
    nok $died, 'Still not timed out yet';

    $*SCHEDULER.advance-by(1);
    is @received, ['badger', 'badger'], 'Still two value after 4s';
    ok $died, 'And have timed out';
}

done-testing;
```
