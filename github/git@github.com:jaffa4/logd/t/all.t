use v6;

use Log::D;
use Log::Empty;
use Test;
plan *;



my $l = Log::Empty.new(); 


ok $l ~~ Log::Empty, "constructor test";


$l = Log::D.new(:w); 

ok $l ~~ Log::D, "constructor test";

$l.notify = True;

#$l.enablew = True;

$l.enable(:w);

$l.allow("f");

$l.remove_ban("f");

$l.remove_allow("f");

$l.o = $*OUT;

$l.w("main","now");

say 'h';

$l.prefix = sub { callframe(2).file~" "~callframe(2).line~" "~$*THREAD.id~" "~DateTime.now~" ";   };

$l.w("end");







done-testing;