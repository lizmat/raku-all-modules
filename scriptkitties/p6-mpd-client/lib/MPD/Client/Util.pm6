#! /usr/bin/env false

use v6.c;

use MPD::Client::Exceptions::SocketException;
use MPD::Client::Grammars::AckLine;
use MPD::Client::Grammars::ResponseLine;

unit module MPD::Client::Util;

#| Get the latest MPD response as a Hash.
sub mpd-response (
	IO::Socket::INET $socket
	--> Hash
) is export {
	my %response;

	for $socket.lines() -> $line {
		if ($line eq "OK") {
			last;
		}

		my $match;

		if ($match = MPD::Client::Grammars::AckLine.parse($line)) {
			%response<error> = $match<message>;
			last;
		}

		if ($match = MPD::Client::Grammars::ResponseLine.parse($line)) {
			%response{$match<key>} = $match<value>;
		}
	}

	%response;
}

#| Check wether the latest response on the MPD socket is OK.
sub mpd-response-ok (
	%response
	--> Bool
) is export {
	%response
		==> transform-response-strings(["error"])
		==> my %transformed-response
		;

	%transformed-response<error> eq "";
}

#| Send a boolean value $state for the given $option to the MPD $socket.
multi sub mpd-send (
	Str $option,
	Bool $state,
	IO::Socket::INET $socket
	--> Hash
) is export {
	mpd-send($option, $state ?? "1" !! "0", $socket);
}

#| Send an array of @values for the given $option to the MPD $socket.
multi sub mpd-send (
	Str $option,
	Array @values,
	IO::Socket::INET $socket
	--> Hash
) is export {
	mpd-send($option, @values.join(" "), $socket);
}

#| Send any $value for the given $option to the MPD $socket.
multi sub mpd-send (
	Str $option,
	Any $value,
	IO::Socket::INET $socket
	--> Hash
) is export {
	mpd-send($option ~ " " ~ $value.Str, $socket);
}

multi sub mpd-send (
	Str $message,
	IO::Socket::INET $socket
	--> Hash
) is export {
	$socket
		==> mpd-send-raw($message)
		==> mpd-response()
		;
}

#| Send a raw command to the MPD socket.
sub mpd-send-raw (
	Str $message,
	IO::Socket::INET $socket
	--> IO::Socket::INET
) is export {
	$socket.put($message);

	$socket;
}

#| Transform a hashed response from MPD to have all @bools be native perl Bool
#| objects.
sub transform-response-bools (
	@bools,
	%input
	--> Hash
) is export {
	my %response = %input;

	for @bools -> $bool {
		if (!defined(%response{$bool})) {
			%response{$bool} = False;

			next;
		}

		%response{$bool} = (%response{$bool} eq "1" ?? True !! False);
	}

	%response;
}

#| Transform a hashed response from MPD to have all @ints be native perl Int
#| objects.
sub transform-response-ints (
	@ints,
	%input
	--> Hash
) is export {
	my %response = %input;

	for @ints -> $int {
		if (!defined(%response{$int})) {
			%response{$int} = 0;

			next;
		}

		%response{$int} = %response{$int}.Real;
	}

	%response;
}

#| Transform a hashed response from MPD to have all @reals be native perl Real
#| objects.
sub transform-response-reals (
	@reals,
	%input
	--> Hash
) is export {
	my %response = %input;

	for @reals -> $real {
		if (!defined(%response{$real})) {
			%response{$real} = 0.0;

			next;
		}

		%response{$real} = %response{$real}.Real;
	}

	%response;
}

#| Transform a hashed response from MPD to have all @strings be native perl Str
#| objects.
sub transform-response-strings (
	@strings,
	%input
	--> Hash
) is export {
	my %response = %input;

	for @strings -> $string {
		if (!defined(%response{$string})) {
			%response{$string} = "";

			next;
		}

		%response{$string} = %response{$string}.Str;
	}

	%response;
}
