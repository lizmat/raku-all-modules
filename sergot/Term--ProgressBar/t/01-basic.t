use v6;
use Test;
plan 2;

use Term::ProgressBar;
use IO::Capture::Simple;

my $bar = Term::ProgressBar.new(count => 100);
my $r;

$r = capture_stdout { $bar.update(50) }
ok($r ~~ m/'[''='+' '+']'/);

$r = capture_stdout { $bar.update(100) }
ok($r ~~ m/'[''='+']'/);
