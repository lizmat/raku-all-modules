
use v6;
use Errno;
use PubFunc;
use NIException;

role Downloader {
	method get(Str $uri) {
		X::NotImplement.new().throw();
	}
}

#| use %URI% represent uri and %FILE% represent file
class Downloader::Command does Downloader {
	has $.command;

	state %COMMAND = %(
		wget 	=> 'wget -q "%URI%" -O "%FILE%"',
		curl 	=> 'curl -s "%URI%" -o "%FILE%"',
	);

	method get(Str $uri) {
		my $tf = getTempFilename();

		my $cmd = self!generate-command($uri, $tf, $!command);

		try {
			shellExec($cmd, :quite);
			CATCH {
				default {
					note "Command '" ~ $cmd ~ "' failed.";
					$tf.IO.unlink;
					...
				}
			}
		}
		my $str = $tf.IO.slurp;

		$tf.IO.unlink;

		return $str;
	}

	method !generate-command(Str $uri, Str $file, $data) {
		my $cmd;

		if $data ~~ /wget||curl/ {
			$cmd = %COMMAND{$data};
		}
		else {
			$cmd = $data;
		}
		$cmd = $cmd.subst("%URI%", $uri);
		$cmd = $cmd.subst("%FILE%",$file);
		$cmd;
	}
}

class Downloader::Module does Downloader {
	# NOT IMPL
}

#| read from local cache
class Downloader::Cache does Downloader {
	method get(Str $file) {
		self!parsefile($file);
	}

	method !parsefile(Str $file) {
		my Errno @errnos = [];

		for $file.IO.lines -> $line {
			if $line ~~ /^errno\:(.*)\, number\:(.*)\, comment\:(.*)/ {
				@errnos.push: Errno.new(
					errno	=> ~$0,
					number	=> ~$1,
					comment	=> ~$2
				);
			}
		}

		@errnos;
	}
}
