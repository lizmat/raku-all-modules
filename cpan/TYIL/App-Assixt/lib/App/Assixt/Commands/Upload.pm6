#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Input;
use App::Assixt::Output;
use CPAN::Uploader::Tiny;
use Config;

unit class App::Assixt::Commands::Upload;

multi method run(
	IO::Path:D $dist,
	Config:D :$config,
) {
	$config<runtime><pause-id> //= $config<pause><id> // ask("PAUSE ID", default => $*USER.Str);
	$config<runtime><pause-password> //= $config<pause><password> // password("PAUSE password");

	my Int $tries = 1;

	while ($tries ≤ $config<pause><tries>) {
		CATCH {
			when $_.payload ~~ / ^ "401 Unauthorized" / {
				err("upload.credentials");

				$config<runtime><pause-id> = ask("PAUSE ID", default => $config<runtime><pause-id>);
				$config<runtime><pause-password> = password("PAUSE password") || $config<runtime><pause-password>;
				$tries++;
			}

			when $_.payload ~~ / ^ "409 Conflict" / {
				err("upload.conflict");

				return;
			}
		}

		say "Attempt #$tries...";

		my CPAN::Uploader::Tiny $uploader .= new(
			user => $config<runtime><pause-id>,
			password => $config<runtime><pause-password>,
			agent => "Assixt/0.5.0",
		);

		if ($uploader.upload($dist.absolute)) {
			# Report success to the user
			out("upload", dist => $dist.basename);

			return;
		}

		$tries++;
	}

	err("upload.gave-up", :$tries);
}

multi method run (
	Str:D $dist,
	Config:D :$config,
) {
	self.run($dist.IO, :$config);
}

multi method run(
	Str @dists,
	Config:D :$config,
) {
	$config<runtime><pause-id> //= $config<pause><id> // ask("PAUSE ID", default => $*USER.Str);
	$config<runtime><pause-password> //= $config<pause><password> // password("PAUSE password");

	for @dists -> $dist {
		self.run(
			$dist.IO.absolute,
			:$config,
		);
	}
}

=begin pod

=NAME    App::Assixt::Commands::Upload
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

assixt upload <dist> [--pause-id=Str] [--pause-password=Str]

=head1 Description

Upload a module distribution to L<PAUSE|https://pause.perl.org/pause/query>, to
make it available through L<CPAN|https://www.cpan.org/>.  Optionally, the PAUSE
ID and password can be given as command-line options. If they're not given,
they will be prompted for.

The PAUSE ID can also be set using the configuration key C<pause.id>. If this
is set to a non-empty Str, the PAUSE ID from the configuration will be used and
won't be prompted for.

=head1 Examples

    assixt upload $HOME/.local/var/assixt/App-Assixt-0.4.0.tar.gz
    assixt upload App-Assixt-0.4.0.tar.gz --pause-id=tyil --pause-password=nice-try

=head1 See also

=item1 C<App::Assixt>
=item1 C<App::Assixt::Commands::Dist>

=end pod

# vim: ft=perl6 noet
