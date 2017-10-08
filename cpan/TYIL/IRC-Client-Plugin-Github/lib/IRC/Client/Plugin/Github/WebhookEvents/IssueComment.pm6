#! /usr/bin/env false

use v6.c;

use Config;

unit module IRC::Client::Plugin::Github::WebhookEvents::IssueComment;

our sub IRC::Client::Plugin::Github::WebhookEvents::IssueComment (
	:%payload,
	Config :$config
) is export {
	my Str $user = %payload<sender><login>;
	my Str $repository = %payload<repository><name>;
	my Int $number = %payload<issue><number>;
	my Str $issue-author = %payload<issue><user><login>;
	my Str $title = %payload<issue><title>;
	my Str $assignee = %payload<issue><assignee><login> // "";

	if ($assignee ne "") {
		$assignee = " [@$assignee]";
	}

	given %payload<action> {
		when "created" {
			"$user commented on $repository#$number by $issue-author ($title)$assignee"
		}
	}
}
