use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::Account', 'Finance::GDAX::API::Account useable';
use Finance::GDAX::API::Account;

ok my $account = Finance::GDAX::API::Account.new, 'Account instantiates';
can-ok $account, 'get-all';
can-ok $account, 'get';
can-ok $account, 'history';
can-ok $account, 'holds';
 
if $do-online-tests {
    $account.debug = True; # Make sure this is set to 1 or you'll use live data

    subtest {
	plan 9;
	ok (my @response = $account.get-all), 'get_all accounts list';
	my $rc = $account.response-code;
	note 'ERROR: ' ~ $account.error if $account.error;
	is $rc, 200, 'Good 200 response code from accounts list';
	is @response.WHAT, (Array), 'get_all accounts returned an array';
	my $found;
	my $account_id;
	for @response.values -> $obj {
	    if ($obj<currency> eq 'BTC') {
		$found = 1;
		$account_id = $obj<id>;
		last;
	    }
	}
	ok $found, 'get_all accounts returns a BTC account';
	
	ok ($account.id = $account_id), 'Assigning ID';
	ok my $info = $account.get, 'get BTC account';
	ok $info<balance>.defined, 'BTC account has balance defined';
	
	my $history = $account.history;
	is $history.WHAT, (Array), 'get BTC account history is an array';
	my $holds = $account.holds;
	is $history.WHAT, (Array), 'get BTC account holds is an array';
    }
}

done-testing;

