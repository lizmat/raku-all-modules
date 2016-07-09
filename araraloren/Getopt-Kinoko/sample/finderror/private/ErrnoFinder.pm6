
use v6;

use Errno;

# ErrnoFinder
class ErrnoFinder {
	has %!filter;
	has $.path;
	has @!errnos;

	my regex include {
		<.ws> '#' <.ws> 'include' <.ws>
		\< <.ws> $<header> = (.*) <.ws> \> <.ws>
	}

	my regex edefine {
		<.ws> '#' <.ws> 'define' <.ws>
		$<errno> = ('E'\w*) <.ws>
		$<number> = (\d+) <.ws>
		'/*' <.ws> $<comment> = (.*) <.ws> '*/'
	}

	method !filepath($include) {
		if $include ~~ /^\// {
			return $include;
		}
		return $!path ~ '/' ~ $include;
	}

	method find(Str $file, $top = True) {
        return if %!filter{$file}:exists;

        %!filter{$file} = 1;

		my \fio = $file.IO;

		$!path = fio.abspath().IO.dirname if $top && !$!path.defined;

		if fio ~~ :e && fio ~~ :f {
			for fio.lines -> $line {
				if $line ~~ /<include>/ {
					self.find(self!filepath(~$<include><header>), False);
				}
				elsif $line ~~ /<edefine>/ {
					@!errnos.push: Errno.new(
							errno 	=> ~$<edefine><errno>,
							number 	=> +$<edefine><number>,
							comment	=> ~$<edefine><comment>.trim
						);
				}
			}
		}
	}

	method result() {
		@!errnos;
	}
}