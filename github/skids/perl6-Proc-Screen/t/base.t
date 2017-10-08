use v6;
use lib <blib/lib lib>;
use File::Temp;

use Test;
if qx{screen -version} ~~ /<!before [4\.0<[01]>|4\.1\D]><[4..9]>\./ {
  plan 11;
}
else {
  plan 1;
  ok 1, "Skipping tests since 'screen' not installed or not in path or < 4.02";
  exit;
}

use Proc::Screen;
ok 1, "Used Proc::Screen and lived";
my $s;
lives-ok { $s = Proc::Screen.new }, "Instantiated a Proc::Screen and lived";
isa-ok $s, Proc::Screen, "...and actually got one." ;
lives-ok { $s.start }, "Ran screen -d -m";
lives-ok { $s.await-ready }, "screen -d -m completed and PID delivered";
isa-ok $s.command(|<register . OHAI>), Promise, "screen -X ran";
my ($fn, $fh) = |tempfile;
$s.command("writebuf", $fn);
$s.await-ready;
is $fh.slurp-rest, "OHAI", "Verified .command method is working";
ok $s.query("info") ~~ /\d+\,\d+/, "Verified sync .query method is working";
my $o;
$s.query("info", :out($o));
$s.await-ready;
ok $o ~~ /\d+\,\d+/, "Verified async .query method is working";
lives-ok {$s.DESTROY}, "Can DESTROY by hand";
($fn, $fh) = |tempfile;
my $p = $fh.watch.head(1).Promise;
$s = Proc::Screen.new(:shell[$*EXECUTABLE,
                      $*SPEC.catdir($*PROGRAM-NAME.IO.dirname,
                      "args.t"), "arg1", "arg2"]
                      :rc["logfile $fn", "logfile flush 0", "deflog on"]);
$s.start;
$s.await-ready;
await $p;
is $fh.slurp-rest.chomp, "arg1 arg2", ":shell works";
