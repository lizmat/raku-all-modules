use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;
use File::Temp;

use-ok 'Finance::GDAX::API', 'Finance::GDAX::API useable';
use Finance::GDAX::API;

ok my $api = Finance::GDAX::API.new, 'API instantiates';
does-ok $api, Finance::GDAX::API::URL;
can-ok $api, 'key';
can-ok $api, 'secret';
can-ok $api, 'passphrase';
can-ok $api, 'signed';
can-ok $api, 'method';
can-ok $api, 'path';
can-ok $api, 'body';
can-ok $api, 'timestamp';
can-ok $api, 'timeout';
can-ok $api, 'error';
can-ok $api, 'response-code';

can-ok $api, 'save-secrets-to-environment';
can-ok $api, 'body-json';

my ($fn, $fh) = tempfile;
$fh.say: "key:testkey";
$fh.say: "secret:testsecret";
$fh.say: "passphrase:testpassphrase";
$fh.flush;
ok $api.external_secret( filename => $fn ), 'External secret in file';
$fh.close;
is $api.key, 'testkey', 'External secret file key';
is $api.secret, 'testsecret', 'External secret file secret';
is $api.passphrase, 'testpassphrase', 'External secret file passphrase';

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;

cmp-ok $api.timestamp, '<=', time, 'Timestamp looks like timestamp';
is $api.get-url, 'https://api-public.sandbox.gdax.com', 'sandbox is default URL';

ok ($api.body = %( name => 'Test Name', pregnant => False, children => @['John', 'Cindy'] )), 'body sets';
ok my $json = $api.body-json, 'Call to body-json';
ok (my %json-test = $api.from_json($json)), 'JSON converts back to hash';
cmp-ok %json-test<name>, 'eq', 'Test Name', 'JSON name key/val compares';
cmp-ok %json-test<pregnant>, '==', False, 'JSON pregnant bool key/val compares';
cmp-ok %json-test<children>, '~~', ['John', 'Cindy'], 'JSON child list key/val compares';

ok ($api.key = 'keytest'), 'key set';
ok ($api.secret = 'secrettest'), 'secret set';
ok ($api.passphrase = 'passphrasetest'), 'passphrase set';
is $api.key, 'keytest', 'key retrieves good';
is $api.secret, 'secrettest', 'secret retrieves good';
is $api.passphrase, 'passphrasetest', 'passphrase retrieves good';
ok $api.save-secrets-to-environment, 'secrets saved to environment varables';
is %*ENV<GDAX_API_KEY>, 'keytest', 'key verified saved to environment';
is %*ENV<GDAX_API_SECRET>, 'secrettest', 'secret verified saved to environment';
is %*ENV<GDAX_API_PASSPHRASE>, 'passphrasetest', 'passphrase verified saved to environment';
$api = Finance::GDAX::API.new;
is $api.key,        %*ENV<GDAX_API_KEY>, 'Environment var GDAX_API_KEY default val works';
is $api.secret,     %*ENV<GDAX_API_SECRET>, 'Environment var GDAX_API_SECRET default val works';
is $api.passphrase, %*ENV<GDAX_API_PASSPHRASE>, 'Environment var GDAX_API_PASSPRASE default val works';

$helper.set-environment;

if $do-online-tests {
    subtest {
	plan 4;
	is ($api.signature.chars %% 4), True, 'Signature divisible by 4';
	
	$api.method = 'GET';
	$api.path = 'products';
	$api.add-to-url('BTC-USD');
	$api.add-to-url('ticker');
	ok my $data = $api.send, 'Get response from GDAX BTC-USD ticker';
	warn "ERROR: " ~ $api.error if $api.error;
	is $data<price>:exists, True, 'Got back a hash keyed with price';
	cmp-ok $data<price>, '>', 0, 'Got back a price that looks ok';
	say $data;
	
    }, 'GDAX_API_* Environment variables tested';
}

done-testing;
