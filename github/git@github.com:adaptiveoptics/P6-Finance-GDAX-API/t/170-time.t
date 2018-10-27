use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::Time', 'Finance::GDAX::API::Time useable';
use Finance::GDAX::API::Time;

ok (my $time = Finance::GDAX::API::Time.new), 'instatiated';

can-ok($time, 'get');

if $do-online-tests {
    $time.debug = True; # Make sure this is set to 1 or you'll use live data

    ok (my $result = $time.get), 'can get current time';
    is $result.WHAT, (Hash), 'get returns hash';
    ok $result<iso>,   'ISO time key defined';
    ok $result<epoch>, 'epoch time defined';
}
done-testing;
