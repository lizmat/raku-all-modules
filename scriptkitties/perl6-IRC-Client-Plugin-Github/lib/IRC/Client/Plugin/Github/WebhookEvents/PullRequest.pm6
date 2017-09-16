#! /usr/bin/env false

use v6.c;

use Config;

unit module IRC::Client::Plugin::Github::WebhookEvents::PullRequest;

our sub IRC::Client::Plugin::Github::WebhookEvents::PullRequest (
	:%payload,
	Config :$config
) is export {
	my Str $user = %payload<sender><login>;
	my Str $repository = %payload<repository><name>;
	my Int $number = %payload<pull_request><number>;
	my Str $title = %payload<pull_request><title>;

	given %payload<action> {
		when "assigned" {
			my Str $assignee = %payload<assignee><login>;

			if ($assignee eq $user) {
				$assignee = "xyrself";
			}

			"$user assigned $assignee to $repository#$number ($title)";
		}
		when "opened" {
			"$user opened PR $repository#$number ($title)";
		}
	}
}
