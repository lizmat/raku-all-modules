#! /usr/bin/env false

use v6.c;

use HTML::Entity;
use HTML::Parser::XML;
use HTTP::UserAgent;

unit module IRC::Client::Plugin::UrlTitle::TypeFormatters::HTML;

#| Format the response with the title of the HTML page.
sub format-html(
	HTTP::Response:D $response,
	--> Str
) is export {
	my HTML::Parser::XML $parser .= new;
	$parser.parse($response.content);

	my $head = $parser.xmldoc.root.elements(:TAG<head>, :SINGLE);
	return "No title tag" if $head ~~ Bool;

	my $title-tag = $head.elements(:TAG<title>, :SINGLE);
	return "No title tag" if $title-tag ~~ Bool;

	decode-entities($title-tag.contents[0].text);
}

# vim: ft=perl6 noet
