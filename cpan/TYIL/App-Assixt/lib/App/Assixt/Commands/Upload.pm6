#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Input;
use Config;
use Dist::Helper::Meta;
use Config;
use File::Temp;
use File::Which;
use MIME::Base64;

unit module App::Assixt::Commands::Upload;

multi sub assixt(
	"upload",
	Str $dist,
	Config:D :$config,
) is export {
	# Get the meta info
	my $tempdir = tempdir;

	die "'tar' is not available on this system" unless which("tar");

	run « tar xzf "$dist" -C "$tempdir" »;

	$config<runtime><pause-id> //= $config<pause><id> // ask("PAUSE ID", default => $*USER.Str);
	$config<runtime><pause-password> //= $config<pause><password> // password("PAUSE password");

	my %meta = get-meta($tempdir.IO.add($dist.IO.extension("", :parts(2)).basename).absolute);
	my $distname = "{%meta<name>.subst("::", "-", :g)}-{%meta<version>}";

	# Set authentication
	my $hash = MIME::Base64.encode-str("{$config<runtime><pause-id>}:{$config<runtime><pause-password>}");
	my $submitvalue = " Upload this file from my disk ";

	my $curl = run «
		curl
		-i -s
		-H "Authorization: Basic $hash"
		-F "HIDDENNAME={$config<runtime><pause-id>.uc}"
		-F "CAN_MULTIPART=1"
		-F "pause99_add_uri_uri="
		-F "pause99_add_uri_subdirtext=Perl6"
		-F "pause99_add_uri_upload=$dist"
		-F "pause99_add_uri_httpupload=@$dist"
		-F "SUBMIT_pause99_add_uri_httpupload=$submitvalue"
		https://pause.perl.org/pause/authenquery
	», :out, :err;

	my @curl-out = $curl.out.lines(:close);

	# Check if it all worked out
	my %http-status;

	for @curl-out -> $line {
		if ($line ~~ m:i/HTTP\/\d\.\d\s(\d+)\s(.+)/) {
			%http-status =
				code => $0,
				message => $1
				;

			last;
		}
	}

	if (!%http-status) {
		note "Could not find HTTP status in curl response";

		my @curl-err = $curl.err.lines(:close);

		for @curl-err -> $line {
			note $line.indent(2);
		}

		exit 1;
	}

	if (%http-status<code> ne "200") {
		note "Upload for {%meta<name>} failed: {%http-status<message>}";

		exit 2;
	}

	# Report success to the user
	say "Uploaded {%meta<name>}:ver<{%meta<version>}> to CPAN";
}

multi sub assixt(
	"upload",
	Str @dists,
	Config:D :$config,
) is export {
	$config<runtime><pause-id> //= $config<pause><id> // ask("PAUSE ID", default => $*USER.Str);
	$config<runtime><pause-password> //= $config<pause><password> // password("PAUSE password");

	for @dists -> $dist {
		assixt(
			"upload",
			$dist.IO.absolute,
			:$config,
		);
	}
}
