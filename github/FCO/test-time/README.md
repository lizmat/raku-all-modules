[![Build Status](https://travis-ci.org/FCO/test-time.svg?branch=master)](https://travis-ci.org/FCO/test-time)

Test::Time
==========

Use **Test::Scheduler** to use on your tests, not only Promises, but **sleep**, **now** and time.

```perl6
    my $started = now;
    $*SCHEDULER = mock-time :auto-advance;

    sleep 10;
    say "did it passed { now - $started } seconds?";
    unmock-time;

    say "No, just passed { now - $started } seconds!";

    #`{{{
    Output:
        did it passed 10.0016178 seconds?
        No, just passed 0.07388266 seconds!
    }}}
```

Or you can use `$*SCHEDULER.advance-by: 10` as you would when using **Test::Scheduler**

