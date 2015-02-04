module Form::Field;

use Form::TextFormatting;
use Form::NumberFormatting;
use Form::Types;

# RAKUDO: Field is now a class, because overriding multis doesn't
# work correctly from roles
our class Form::Field::Field {
	has Bool $.block is rw;
	has Int $.width is rw;
	has $.alignment is rw;
	has $.data is rw;
	
	multi method format(Str $data) { ... }

	multi method format(@data) {
		my @output;
		for @data -> $datum {
			@output.push(self.format($datum));
		}
		return @output;
	}

	method align(@lines, $height) {
		if @lines.elems < $height {
			my @extra = (' ' x $.width) xx ($height - @lines.elems);
			given $.alignment {
				when Alignment::top {
					return (@lines, @extra).flat;
				}
				when Alignment::bottom {
					return (@extra, @lines).flat;
				}
				default {
					my @top = (' ' x $.width) xx (@extra.elems div 2);
					my @bottom = @top;
					@extra.elems % 2 and @bottom.push(' ' x $.width);
					return (@top, @lines, @bottom).flat;
				}
			}
		}
		elsif @lines.elems > $height {
			# TODO: we may need to be cleverer about which alignments
			return @lines[^$height];
		}
		else {
			return @lines;
		}
	}
}

our class Form::Field::Text is Form::Field::Field {
	has $.justify is rw;


	multi method format(Str $data) {
		my @lines = Form::TextFormatting::unjustified-wrap(~$data, $.width);

		$.block or @lines = @lines[^1];

		my Callable $justify-function;
		if $.justify == Justify::left {
			$justify-function = &Form::TextFormatting::left-justify;
		}
		elsif $.justify == Justify::right {
			$justify-function = &Form::TextFormatting::right-justify;
		}
		elsif $.justify == Justify::centre {
			$justify-function = &Form::TextFormatting::centre-justify;
		}
		else {
			$justify-function = &Form::TextFormatting::full-justify;
		}
		@lines.=map: { $justify-function($_, $.width, ' ') };

		return @lines;
	}
}

our class Form::Field::Numeric is Form::Field::Field {
	has Int $.ints-width;
	has Int $.fracs-width;

    multi method format(Real $data)
	{
		my ($ints, $fractions) = Form::NumberFormatting::obtain-number-parts(+$data);
		$ints = Form::TextFormatting::right-justify(~$ints, $.ints-width);
		$fractions = Form::TextFormatting::left-justify(~$fractions, $.fracs-width);
		return [ $ints ~ '.' ~ $fractions ];
	}
}

our class Form::Field::Verbatim is Form::Field::Field {
	multi method format(Str $data) {
		my @lines = $data.split("\n");
		$.block or @lines = @lines[^1];
		for @lines -> $line is rw {
			$line = Form::TextFormatting::left-justify($line, $.width, ' ');
		}

		return @lines;
	}
}


# vim: ft=perl6 sw=4 ts=4 noexpandtab
