use v6;
use Test;

use lib 'lib';

use Term::ProgressBar;
use IO::Capture::Simple;

subtest {
    my $bar = Term::ProgressBar.new(count => 100);
    my $r;

    $r = capture_stdout { $bar.update(50) }
    like($r, rx/ '[' '='+ ' '+ ']' /, 'update(50)');

    $r = capture_stdout { $bar.update(100) }
    like($r, rx/ '[' '='+ ']' /, 'update(100)');
}, 'default bar style';

subtest {
    my $bar = Term::ProgressBar.new(count => 100, :p);
    my $r;

    $r = capture_stdout { $bar.update(50) }
    like($r, rx/ '[' '='+ ' '+ ']  50%' /, 'update(50)');

    $r = capture_stdout { $bar.update(100) }
    like($r, rx/ '[' '='+ ']  100%' /, 'update(100)');
}, 'with percent at end';

subtest {
    my $bar = Term::ProgressBar.new(count => 100, :t);
    my $r;

    $r = capture_stdout { $bar.update(50) }
    like($r, rx/ '[' '='+ ' '+ ']  eta ' <[ 0..9 \. ]>+ 's' /, 'update(50)');

    $r = capture_stdout { $bar.update(100) }
    like($r, rx/ '[' '='+ ']  eta 0s' /, 'update(100)');
}, 'with eta at end';

done-testing;
