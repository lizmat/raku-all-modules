use Test;
use SeqSplitter;

is ^10 .pull-while(True).List, ^10 .List;
is ^10 .skip-while(True).List, ();
is ^10 .pull-until(False), ^10 .pull-while(True);
is ^10 .skip-until(False), ^10 .skip-while(True);

my Sequence $s1 = ^10 .pull-while(* < 5);
is $s1.List, ^5 .List;
is $s1.List, (5 ..^ 10).List;

my Sequence $s2 = ^10 .pull;
is $s2.List, (0);
is $s2.List, (1 ..^ 10).List;

my Sequence $s3 = ^10 .pull: 5;
is $s3.List, ^5 .List;
is $s3.List, (5 ..^ 10).List;

my Sequence $s4 = ^10 .pull: *;
is $s4.List, ^10 .List;
is $s4.List, ();

my Sequence $s5 = ^10 .pull.pull;
is $s5.List, (0, 1);
is $s5.List, (2 ..^ 10).List;

my Sequence $s6 = ^10 .pull.skip.pull;
is $s6.List, (0, 2);
is $s6.List, (3 ..^ 10).List;

my Sequence $s7 = ^10 .pull-while(* < 2).skip-until(3).pull-until: 5;
is $s7.List, (0, 1, 3, 4);
is $s7.List, (5 ..^ 10).List;

my $s8 = ^10 .skip-until(3);
my $s9 = ^10 .skip-until(3).pull(*);

is $s8.List, $s9.List;
is $s8.List, $s9.List;

is ^10 .skip.pull.skip.pull.skip.pull.List, (1, 3, 5);

done-testing
