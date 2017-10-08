use Sprockets;
use Sprockets::File;
unit class Sprockets::Locator;
has %.paths;

method find-file($name, $ext) {
	my sub rm-trail($str) {
		$str.subst(/\/$/, '');
	}

	for %.paths.kv -> $, $ (:@directories, :%prefixes) {
		my $prefix = (my $p = %prefixes{get-type-for-ext($ext)}) ?? "/$p" !! "";
		for @directories {
			my $dir = "{.&rm-trail}{rm-trail $prefix}/";
			for dir $dir {
				next if .IO.d; # TODO go deeper §§

				my ($f, $fext, $filters) = split-filename($_.Str.substr($dir.chars));
				return Sprockets::File.new(:realpath(~$_), :filters(@$filters))
          if $f eq $name and $fext eq $ext;
			}
		}
	}
}

sub get-type-for-ext($ext) {
	given $ext {
		return 'img' when 'png' | 'gif' | 'jpg' | 'jpeg';

		return 'font' when 'otf' | 'ttf';
	}
	return $ext;
}
