# Proc::Async::Timeout

Run a command asynchronos with a timeout. When the timeout is hit
`X::Proc::Async::Timeout` is thrown and the command is killed.

[![Build Status](https://travis-ci.org/gfldex/perl6-proc-async-timeout.svg?branch=master)](https://travis-ci.org/gfldex/perl6-proc-async-timeout)

## SYNOPSIS

```
use v6.c;

use Proc::Async::Timeout;

my $s = Proc::Async::Timeout.new('find', '/home', :enc<latin-1>);

$s.stdout.lines.tap: { .say if .lc.contains(any <gfldex peppmeyer>) }
$s.stderr.tap: { Nil }

await $s.start: timeout => 2;

CATCH { 
    when X::Proc::Async::Timeout {
        say "cought: ", .^name;
        say "reporting: ", .Str;
    }
    when X::Promise::Broken ^ X::Proc::Async::Timeout {
        say "something else when wrong";
    }
}

# OUTPUT:
# cought: X::Proc::Async::Timeout+{X::Promise::Broken}
# reporting: ⟨sleep⟩ timed out after 2 seconds.
```

## Methods

Proc::Async::Timeout.start(:$timeout, |c --> Promise:D)

Executes the stored command and sets a timeout. All additional arguments are
forwarded to `Proc::Async.start`. If the timeout is hit before the command
finished `X::Proc::Async::Timeout` is thrown.

## LICENSE

All files (unless noted otherwise) can be used, modified and redistributed
under the terms of the Artistic License Version 2. Examples (in the
documentation, in tests or distributed as separate files) can be considered
public domain.

ⓒ2017 Wenzel P. P. Peppmeyer
