#! /usr/bin/env false

use v6.c;

use Bailador;
use Config;
use IRC::Client;
use IRC::Client::Plugin::Github::WebhookEvents::Push;

class IRC::Client::Plugin::Github does IRC::Client::Plugin
{
	has Config $.config;

	method irc-connected($)
	{
		start {
			# Set up the web hook for Github notification POSTs
			post "/" => sub {
				my Str $event = request.headers<X_GITHUB_EVENT>.wordcase;
				my Str $module = "IRC::Client::Plugin::Github::WebhookEvents::$event";

				if (::{"&{$module}"} ~~ Nil) {
					if ($!config.get("debug", False)) {
						say "No such module: $module";
					}

					return;
				}

				::{"&{$module}"}(
					irc => $.irc,
					config => $!config,
					request => request
				);
			};

			# Configure Bailador
			set("host", $!config.get("github.webhook.host", "0.0.0.0"));
			set("port", $!config.get("github.webhook.port", 8000));

			# Start Bailador
			baile();
		};
	}
}
