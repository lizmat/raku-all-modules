use v6;
use Finance::GDAX::API;

class GDAXTestHelper
{
    has Str $.key        is rw;
    has Str $.secret     is rw;
    has Str $.passphrase is rw;

    method get-environment() {
	my $api = Finance::GDAX::API.new;
	if %*ENV<GDAX_EXTERNAL_SECRET>:exists {
	    $api.external_secret(filename => %*ENV<GDAX_EXTERNAL_SECRET>);
	}
	if %*ENV<GDAX_EXTERNAL_SECRET_FORK>:exists {
	    note 'Forking external program - you may need to enter something that won\'t show up here';
	    $api.external_secret(filename => %*ENV<GDAX_EXTERNAL_SECRET_FORK>, fork => True);
	}
	if ($api.key and $api.secret and $api.passphrase) {
	    $.key = $api.key;
	    $.secret = $api.secret;
	    $.passphrase = $api.passphrase;
	} else {
	    $.key = %*ENV<GDAX_API_KEY> if %*ENV<GDAX_API_KEY>:exists;
	    $.secret = %*ENV<GDAX_API_SECRET> if %*ENV<GDAX_API_SECRET>:exists;
	    $.passphrase = %*ENV<GDAX_API_PASSPHRASE> if %*ENV<GDAX_API_PASSPHRASE>:exists;
	}
    }

    method set-environment() {
	%*ENV<GDAX_API_KEY> = $.key;
	%*ENV<GDAX_API_SECRET> = $.secret;
	%*ENV<GDAX_API_PASSPHRASE> = $.passphrase;
	%*ENV<GDAX_EXTERNAL_SECRET>:delete;
	%*ENV<GDAX_EXTERNAL_SECRET_FORK>:delete;
    }

    method do-online-tests() {
	return ($.key and $.secret and $.passphrase) ?? True !! False;
    }

    method check-error($object) {
	if $object.error {
	    note $object.error ~ " on URL \"" ~ $object.get-url ~ "\"";
	    return False;
	} else {
	    return True;
	}
    }
    
}

