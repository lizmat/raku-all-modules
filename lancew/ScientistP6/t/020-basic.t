use lib 'lib';

use Scientist;
use Test;

plan 8;

my $test = Scientist.new(
    experiment => 'Tree',
    try        => sub {99},
    use        => sub {88},
);

is $test.experiment, 'Tree', 'Experiment is set correctly';

$test.experiment = 'Fauna';
is $test.experiment, 'Fauna', 'Able to change the experiment name';

my $result = $test.run;
is $result, 88, 'Run() Returns correct value';

ok $test.result<mismatched>, 'Mismatched identified correctly';

$test.try = sub{88};
$result = $test.run;
ok !$test.result<mismatched>, 'Match identified correctly';

$test.try = sub { return {a=>'alpha', b=>'beta', c => [1,2,3,4,5] } };
$test.use = sub { return { c => [1,2,3,4,5], a=>'alpha', b=>'beta' } };
$result = $test.run;
ok !$test.result<mismatched>, 'Complex data match identified correctly';

ok $test.result<candidate><duration>.Real > 0, 'Candidate Duration returned > 0';
ok $test.result<control><duration>.Real > 0, 'Control Duration returned > 0';
