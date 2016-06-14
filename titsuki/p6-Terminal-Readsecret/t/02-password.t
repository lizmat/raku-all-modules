use v6;
use Test;
use Terminal::Readsecret;

subtest {
    my $timeout = timespec.new(tv_sec => 1, tv_nsec => 0);
    throws-like { getsecret("password", $timeout) }, Exception, message => 'timeout waiting for user';
}, 'timeout';

done-testing;
