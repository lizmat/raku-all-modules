module Form;

use Form::TextFormatting;
use Form::Grammar;
use Form::Actions;
use Form::Field;

sub form(*@args --> Str) is export {
	my @lines;
	my $result = '';

	my $actions = Form::Actions.new;

	while @args.elems {
		my $format = @args.shift;
		my $f = Form::Grammar.parse($format, :actions($actions));
		$f or die "form: error: argument '$format' is not a valid format string";
		my $nonliteral-field-count = $f.ast.grep( { $_ ~~ Form::Field::Field } ).elems;
		if @args.elems < $nonliteral-field-count {
			die "Insufficient number of data arguments ({@args.elems}) provided for format template '$format' which requires $nonliteral-field-count";
		}

		my @data;
		for ^$nonliteral-field-count {
			@data.push(@args.shift);
		}

		my @formatted;

		for @($f.ast) {
			when Str {
				@formatted.push([$_]);
			}
			when Form::Field::Field {
				@formatted.push([.format(@data.shift)]);
			}
		}

		my $most-lines = ([max] @formatted.map: *.elems);
		# RAKUDO: used to use $flines is rw and just overwrite in place that way
		# But it doesn't seem to work at the moment
		for @($f.ast) Z (0..*) -> $field, $index {
			if @formatted[$index].elems < $most-lines {
				if $field ~~ Form::Field::Field {
					@formatted[$index] = $field.align(@formatted[$index], $most-lines);
				}
				elsif $field ~~ Str {
					@formatted[$index] = $field xx $most-lines;
				}
			}
		}

		for ^$most-lines -> $line-number {
			my $line;
			for @formatted {
				$line ~= $_[$line-number];
			}
			$result ~= $line ~ "\n";
		}
	}

	return $result;
}

# vim: ft=perl6 sw=4 ts=4 noexpandtab

