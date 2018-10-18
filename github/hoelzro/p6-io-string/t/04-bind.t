use v6;
use Test;
use IO::String;

plan 8;

my $buf = '';
my $s = IO::String.new(buffer => $buf);
$s.say("Hello");
is $s.buffer, "Hello\n", 'buffer is good after open';
is $buf, '', 'original is unchanged after open';

$s.open($buf, :bind, :a);
$s.say("Bellow");
is $s.buffer, "Bellow\n", 'buffer is good after binding';
is $buf, "Bellow\n", 'original matches buffer after binding';

$s.open($buf, :a);
$s.say("Jello");
is $s.buffer, "Bellow\nJello\n", 'buffer is good after "regular" open';
is $buf, "Bellow\n", 'original is unchanged after "regular" open';

with class { method gist { 'gisted' } }.new -> \c {
    is-deeply $s.say(c, (c, c).Seq, [c, c]), True, '.say returns True';
    is-deeply $s.buffer, "Bellow\nJello\ngisted(gisted gisted)[gisted gisted]\n",
        '.say gists';
}
