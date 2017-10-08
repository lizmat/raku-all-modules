use v6;
use Test;
use Terminal::Readsecret;

subtest {
    my Timespec $timeout .= new(tv-sec => 1, tv-nsec => 0);
    throws-like { getsecret("password", $timeout) }, Exception, message => 'timeout waiting for user';
}, 'timeout';

done-testing;
