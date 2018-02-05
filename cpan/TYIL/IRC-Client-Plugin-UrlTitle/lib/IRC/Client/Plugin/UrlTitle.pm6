#! /usr/bin/env false

use v6.c;

use HTML::Parser::XML;
use HTTP::UserAgent;
use IRC::Client;
use IRC::TextColor;
use URL::Find;

#| An IRC::Client plugin to post the title of webpages which are referenced in
#| IRC channel messages
class IRC::Client::Plugin::UrlTitle does IRC::Client::Plugin
{
	has HTTP::UserAgent $!ua;

	#| Set up the class variables.
	method TWEAK
	{
		# Instantiate the HTTP::UserAgent
		$!ua .= new;
		$!ua.timeout = 10;
	}

	#| Check every message for possible URLs. The original event will be passed
	#| along for other plugins to handle as well.
	method irc-privmsg-channel(
		$e, #= The IRC event which triggered this method.
	) {
		# Get all URLs in the message
		my @urls = find-urls($e.text);

		@urls.race(:batch).map: {
			$e.irc.send(
				where => $e.channel,
				text => self!format-text($^url, self!resolve($^url)),
			);
		};

		$.NEXT;
	}

	#| Resolve a given $url to the title tag, if possible.
	method !resolve(
		Str $url, #= The URL to try and resolve
		--> Str
	) {
		try {
			CATCH {
				return irc-style-text(~$_, :color<red>);
			}

			my $response = $!ua.get($url);

			if ($response.is-success) {
				my HTML::Parser::XML $parser .= new;
				$parser.parse($response.content);

				my $head = $parser.xmldoc.root.elements(:TAG<head>, :SINGLE);
				return "No title tag" if $head ~~ Bool;

				my $title-tag = $head.elements(:TAG<title>, :SINGLE);
				return "No title tag" if $title-tag ~~ Bool;

				return $title-tag.contents[0].text;
			}

			return irc-style-text($response.status-line, :color<yellow>),
		}
	}

	#| Apply formatting to the output text sent back to the IRC channel.
	method !format-text(
		Str:D $url,     #= The URL being checked
		Str:D $message, #= The message containing the title
		--> Str
	) {
		irc-style-text($url, :color<blue>) ~ ": " ~ $message;
	}
}

# vim: ft=perl6 noet
