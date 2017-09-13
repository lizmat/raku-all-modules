#! /usr/bin/env false

use v6.c;

use Config;

unit module IRC::Client::Plugin::Github::WebhookEvents::Push;

our sub IRC::Client::Plugin::Github::WebhookEvents::Push (
	:%payload,
	Config :$config
) is export {
	say %payload.WHAT;
	my Str $user = %payload<pusher><name>;
	my Int $commits = %payload<commits>.elems;
	my Str $repository = %payload<repository><name>;
	my Str $branch = %payload<ref>.Str.subst("refs/heads", "");
	my Str $old = %payload<before>.Str.substr(0, 7);
	my Str $new = %payload<after>.Str.substr(0, 7);
	my Str $commitString = "commit";

	if ($commits != 1) {
		$commitString ~= "s";
	}

	"$user pushed $commits new $commitString to {$repository}{$branch} ($old..$new)";
}
