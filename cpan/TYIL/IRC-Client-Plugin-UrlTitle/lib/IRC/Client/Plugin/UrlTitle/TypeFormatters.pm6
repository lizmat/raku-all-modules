#! /usr/bin/env false

use v6.c;

use HTTP::UserAgent;
use IRC::TextColor;
use IRC::Client::Plugin::UrlTitle::TypeFormatters::HTML;

unit module IRC::Client::Plugin::UrlTitle::TypeFormatters;

subset HtmlType of Str where * ~~ /^text\/html/;

#| Generic formatter, used when the Content-Type isn't matched with any
#| specific types.
multi sub format-type(
	HTTP::Response:D $response,
	Str:D $content-type,
	--> Str
) is export {
	my %headers = $response.header.hash;
	my Real $size = %headers<Content-Length>[0].Int;

	my Str @suffixes = ("", "K", "M");
	my Int $suffix-indice = 0;

	while (1000 < $size && $suffix-indice ≤ @suffixes.end) {
		$size /= 1000;
		$size .= round(.1);

		$suffix-indice++;
	}

	"$content-type, {$size}@suffixes[$suffix-indice]B"
}

# Content specific formatting
multi sub format-type(HTTP::Response:D $r, HtmlType:D $ --> Str) is export { format-html($r) }

# vim: ft=perl6 noet
