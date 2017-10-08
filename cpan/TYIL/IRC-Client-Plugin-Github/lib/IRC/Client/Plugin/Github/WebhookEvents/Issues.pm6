#! /usr/bin/env false

use v6.c;

use Config;

unit module IRC::Client::Plugin::Github::WebhookEvents::Issues;

our sub IRC::Client::Plugin::Github::WebhookEvents::Issues (
	:%payload,
	Config :$config
) is export {
	my $user = %payload<sender><login>;
	my $repository = %payload<repository><name>;

	given %payload<action> {
		when "labeled" {
			my $label = %payload<label><name>;
			my $issue-number = %payload<issue><number>;
			my $issue-title = %payload<issue><title>;

			"$user added the '$label' label to $repository#$issue-number ($issue-title)";
		}
		when "opened" {
			my $issue-number = %payload<issue><number>;
			my $issue-title = %payload<issue><title>;

			"$user opened issue $repository#$issue-number ($issue-title)";
		}
	}
}
