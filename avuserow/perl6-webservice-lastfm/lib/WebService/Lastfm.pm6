use v6;

use JSON::Tiny;
use Digest::MD5;
use LWP::Simple;
use URI::Encode;
# use HTTP::UserAgent

class X::WebService::Lastfm is Exception {
	has $.code;
	has $.text;
	method message() {
		"Last.fm API error $.code: $.text"
	}
}

class WebService::Lastfm {
	has $.api-key;
	has $.api-secret;

	has $.endpoint = 'http://ws.audioscrobbler.com/2.0/';

#	has $.ua = HTTP::UserAgent.new();

	#= Common parameters we want on all requests, factored out from request()
	# and write()
	method !expand-params($method, %args) {
		%args<method> = $method;
		%args<format> = 'json';
		%args<api_key> = $.api-key;
	}

	#= Convert a hash to a query-string-like format (k=v&k2=v2)
	method !to-params(*%args) {
		return join "&", %args.map({
			join "=", uri_encode(.key), uri_encode(.value),
		});
	}

	my sub check-errors($result) {
		if $result<error> {
			X::WebService::Lastfm.new(
				code => $result<error>,
				text => $result<message>,
			).throw;
		}
	}

	method !sign-params(%args) {
		my $raw = '';
		for %args.keys.sort -> $k {
			next if $k eq 'format';
			$raw ~= "$k%args{$k}";
		}
		$raw ~= $.api-secret;
		return Digest::MD5.md5_hex($raw);
	}

	method request($method, *%args) {
		self!expand-params($method, %args);
		my $url = $.endpoint ~ '?' ~ self!to-params(|%args);

		my $result = from-json(LWP::Simple.get($url));
		# my $result = from-json($.ua.get($url).content.decode);
		check-errors($result);
		return $result;
	}

	method write($method, *%args) {
		self!expand-params($method, %args);
		%args<api_sig> = self!sign-params(%args);
		my $params = self!to-params(|%args);

		my $url = $.endpoint ~ '?' ~ self!to-params(|%args);
		my $result = from-json(LWP::Simple.post($url));
		# my $result = from-json($.ua.post($url).content.decode);
		check-errors($result);
		return $result;
	}
}
