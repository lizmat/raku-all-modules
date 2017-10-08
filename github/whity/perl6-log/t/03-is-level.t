use v6;

use Test;
use Log;

my $log = Log.new;

ok($log.is-warn, 'log is warning');
ok($log.is-error, 'log is error');
ok($log.is-info, 'log is info');
nok($log.is-debug, 'log is not debug');
nok($log.is-trace, 'log is not trace');

done-testing;
