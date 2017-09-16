#! /usr/bin/env false

use v6.c;

use Bailador;
use Config;
use IRC::Client;
use IRC::Client::Plugin::Github::WebhookEvents::IssueComment;
use IRC::Client::Plugin::Github::WebhookEvents::Issues;
use IRC::Client::Plugin::Github::WebhookEvents::PullRequest;
use IRC::Client::Plugin::Github::WebhookEvents::Push;
use JSON::Fast;

class IRC::Client::Plugin::Github does IRC::Client::Plugin
{
	has Config $.config;

	method irc-connected($)
	{
		start {
			# Set up the web hook for Github notification POSTs
			post "/" => sub {
				my Str $event = request.headers<X_GITHUB_EVENT>.subst("_", " ").wordcase().subst(" ", "");
				my Str $module = "IRC::Client::Plugin::Github::WebhookEvents::$event";

				if (::{"&{$module}"} ~~ Nil) {
					if ($!config.get("debug", False)) {
						say "No such module: $module";
					}

					return "";
				}

				my %json = from-json(request.body);

				# Make sure there are channels configured to notify
				my Str $repo-config-key = "github.webhook.repos.{%json<repository><full_name>.subst("/", "-")}.channels";
				my Str @channels = $!config.get($repo-config-key) || $!config.get("github.webhook.channels", []).unique;

				if (@channels.elems lt 1) {
					if ($!config.get("debug", False)) {
						say "No channels configured for {%json<repository><full_name>} ($repo-config-key)";
					}

					return "";
				}

				# Call the module
				my Str $message = ::{"&{$module}"}(
					config => $!config,
					payload => %json
				);

				# Send the message to all channels
				for @channels {
					$.irc.send(
						:where($_)
						:text($message)
						:notice($!config.get("github.webhook.message-style", "") eq "notice")
					);
				}

				# Return an empty string as http response
				"";
			};

			# Configure Bailador
			set("host", $!config.get("github.webhook.host", "0.0.0.0"));
			set("port", $!config.get("github.webhook.port", 8000));

			# Start Bailador
			baile();
		};
	}
}
