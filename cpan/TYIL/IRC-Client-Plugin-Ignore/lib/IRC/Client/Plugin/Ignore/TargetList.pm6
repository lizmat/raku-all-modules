#! /usr/bin/env false

use v6.c;

use IRC::Client;

class IRC::Client::Plugin::Ignore::TargetList
{
	has SetHash $!nicks; #= Convenience SetHash of nicks.
	has SetHash $!users; #= Convenience SetHash of usernames.
	has SetHash $!hosts; #= Convenience SetHash of hosts.

	multi method add-nick(
		Str:D $target where { !$!nicks{$target} },
		--> Str
	) {
		$!nicks{$target}++;

		"Added $target to the list";
	}

	multi method add-nick(
		Str:D $target,
		--> Str
	) {
		"$target is already on the list";
	}

	multi method remove-nick(
		Str:D $target where { $!nicks{$target} },
		--> Str
	) {
		$!nicks{$target}--;

		"Removed $target from the list";
	}

	multi method remove-nick(
		Str:D $target,
		--> Str
	) {
		"$target is not on the list";
	}

	#| Check whether a given message's sender is contained in the IgnoreList.
	method includes(
		IRC::Client::Message:D $event
	) {
		$!nicks{$event.nick} or $!users{$event.username} or $!hosts{$event.host};
	}

	#| Refresh the IgnoreList from a configuration.
	method refresh(
		%lists
	) {
		$!nicks .= new: |%lists<nicks>;
		$!users .= new: |%lists<users>;
		$!hosts .= new: |%lists<hosts>;
	}
}

# vim: ft=perl6 noet
