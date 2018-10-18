use v6;

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
