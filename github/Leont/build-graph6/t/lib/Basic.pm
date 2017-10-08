use v6;

unit class Basic;

use Build::Graph;
use Shell::Command;

also does Build::Graph::Plugin;

method get-command(Str:D $command) {
	given $command {
		when 'spew' {
			sub ($target, $source, *%) { @*collector.push($target); mkpath($target.IO.dirname); spurt($target, $source) };
		}
		when 'noop' {
			sub ($target, *%) { @*collector.push($target) };
		}
	}
}

method get-trans(Str:D $trans) {
	given $trans {
		when 's-ext' {
			sub ($orig, $repl, $source) {
				return $source.subst(/ <.after \.> $orig $/, $repl);
			}
		}
	}
}

