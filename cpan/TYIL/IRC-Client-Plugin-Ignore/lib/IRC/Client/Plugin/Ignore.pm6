#! /usr/bin/env false

use v6.c;

use Config;
use IRC::Client;
use IRC::Client::Plugin::Ignore::TargetList;

constant TargetList = IRC::Client::Plugin::Ignore::TargetList;

#| Implement an ignore list into IRC::Client.
class IRC::Client::Plugin::Ignore does IRC::Client::Plugin
{
	has Config $.config is rw; #= The global configuration object.

	my Str $prefix;
	my TargetList $ignore-list;
	my TargetList $admin-list;

	subset IgnoredMessage where {
		$ignore-list.includes($_)
	}

	subset AdminMessage where {
		$admin-list.includes($_)
	}

	method TWEAK
	{
		$admin-list .= new;
		$ignore-list .= new;

		# Load the configuration into optimized SetHash objects.
		self!refresh;
	}

	# Ignore all channel notices from nicks on the ignore list.
	multi method irc-notice-channel(IgnoredMessage $e) { self!ignored($e) }
	multi method irc-privmsg-channel(IgnoredMessage $e) { self!ignored($e) }
	multi method irc-to-me(IgnoredMessage $e) { self!ignored($e) }

	#| Enable admins to add nicks to the ignore list.
	multi method irc-privmsg-channel(AdminMessage $ where * ~~ /"$prefix" ignore \s+ $<target>=\S+/) { $ignore-list.add-nick(~$<target>) }
	multi method irc-to-me(AdminMessage $ where * ~~ /"$prefix" ignore \s+ $<target>=\S+/) { $ignore-list.add-nick(~$<target>) }

	#| Enable admins to remove nicks from the ignore list.
	multi method irc-privmsg-channel(AdminMessage $ where * ~~ /"$prefix" unignore \s+ $<target>=\S+/) { $ignore-list.remove-nick(~$<target>) }
	multi method irc-to-me(AdminMessage $ where * ~~ /"$prefix" unignore \s+ $<target>=\S+/) { $ignore-list.remove-nick(~$<target>) }

	#| Output a debug message to STDERR when a message is being ignored and
	#| `debug` is set in the Config.
	method !ignored(
		IRC::Client::Message:D $e
	) {
		note "{$e.nick} is being ignored" if $.config<debug>;

		Nil;
	}

	#| Update the lists used throughout this module.
	method !refresh()
	{
		$admin-list.refresh($.config.get("admin", %()));
		$ignore-list.refresh($.config.get("ignore", %()));

		$prefix = $!config.get("bot.prefix", ".");
	}
}

# vim: ft=perl6 noet
