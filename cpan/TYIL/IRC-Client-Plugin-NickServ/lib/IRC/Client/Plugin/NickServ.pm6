#! /usr/bin/env false

use v6.c;

use Config;
use IRC::Client;

#| The IRC::Client::Plugin to deal with NickServ interaction.
class IRC::Client::Plugin::NickServ does IRC::Client::Plugin
{
	has Config $.config;

	#| Identify with NickServ. This is done on IRC code 376 (end of MOTD),
	#| since this is what most servers accept as the earliest time to start
	#| interacting with the server.
	method irc-n376($e)
	{
		# Extract the config parameters
		my Str $nick = $!config<nickserv><nickname>
			// $!config<bot><nickname>;
		my Str $pass = $!config<nickserv><password>;

		# Send the identify command
		$e.irc.send-cmd: "NS identify $nick $pass";
	}
}

# vim: ft=perl6 noet
