use lib <lib>;
use Testo;

plan 2;

use Benchy;

is-run $*EXECUTABLE,
  :args[|<-Ilib -MBenchy -e>, ｢
      augment class Int {}
      $ = nqp::iseq_s('', '');
      my $x = '2+2'; EVAL $x;
      b 20, { sleep .1 }, { sleep .01 }, { sleep .001 }
  ｣], out => /
    ^
      'Bare:' \s+ <[\d.]>+ 's' \s+
      'Old:'  \s+ <[\d.]>+ 's' \s+
      'New:'  \s+ <[\d.]>+ 's' \s+
      "\x[1b][32m"?
          'NEW'  \s+ 'version is' \s+ <[\d.]>+ <[%x]> \s+ 'faster'
      "\x[1b][0m"? \s+
  /;

group 'return value' => 4 => {
    my $res = (b 20, { sleep .1 }, { sleep .01 }, { sleep .001 }, :silent);
    is $res.keys.sort.list, <bare new old>;
    is $res<bare>, /^ <[\d.]>+ $/, 'bare';
    is $res<new>, /^ <[\d.]>+ $/, 'new';
    is $res<old>, /^ <[\d.]>+ $/, 'old';
}
