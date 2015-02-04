use v6;
class Pod::Parser;

use Pod::Parser::Common;

=begin pod

=head1 NAME

Pod::Parser - parsing files with POD in them (Perl 6 syntax)

=head1 WARNING

The generated data structure is not final yet

  use Pod::Parser;
  my $pp = Pod::Parser.new;
  my @data = $pp.parse_file('path/to/file.pod');

or

  my $pod = 'path/to/file.pod'.IO.slurp;
  my @data = $pp.parse($pod);

=head2 Example

  use Pod::Parser;
  my $pp = Pod::Parser.new;
  my @data = $pp.parse_file('path/to/file.pod');
  CATCH {
    when X::Pod::Parser {
      warn $_;
      return;
    }
  }

=end pod

my $in_pod = 0;
my $in_verbatim = 0;
my $pod = '';
my $verbatim = '';
my $text = '';

has $.depth is rw = 0;
has @.data;
has $.title is rw;

method parse (Str $string) {
	@.data = ();
	$.title = '';

	my @lines = $string.split("\n");
	for @lines -> $row {
		if $row ~~ m/^\=begin \s+ pod \s* $/ {
			$in_pod = 1;
			self.include_text;
			next;
		}
		if $row ~~ m/^\=end \s+ pod \s* $/ {
			$in_pod = 0;
			self.end_pod;
			next;
		}

		if $in_pod {
			if $row ~~ m/^ \=TITLE \s+ (.*) $/ {
				self.end_pod;
				self.set_title($0.Str);
				next;
			}
			if $row ~~ m/^ \=(head<[12345]>) \s+ (.*) $/ {
				self.end_pod;
				self.head($0.Str, $1.Str);
				next;
			}
			# TODO implement the following tags:
			if $row ~~ m/^\=over \s+ (\d+) \s* $/ {
				self.over($0.Str);
				next;
			}
			if $row ~~ m/^\=item \s+ (.*) $/ {
				self.item($0.Str);
				next;
			}
			if $row ~~ m/^\=back\s*/ {
				self.back;
				next;
			}
			if $row ~~ m/^\=begin\s+code\s*$/ {
				next;
			}
			if $row ~~ m/^\=end\s+code\s*$/ {
				next;
			}

			# TODO special exception for Perl5-ism?
			#if $row ~~ m/^\=cut\s*/ {
			#	next;
			#}
			# TODO: what about '=head' or '=MMMMMM'  or  '=begin usage' ?

			if $row ~~ m/^ \= / {
				X::Pod::Parser.new(msg => "Unknown tag", text => $row).throw;
			}

			if $row ~~ m/^\s+\S/ {
				self.include_pod;
				$in_verbatim = 1;
			}

			if $in_verbatim {
				if $row ~~ m/^\S/ {
					self.include_verbatim;
				} else {
					$verbatim ~= "$row\n";
					next;
				}
			}
			$pod ~= "$row\n";
			next;
		}

		$text ~= "$row\n";
	}

	# after ending all the rows:
	if $in_pod {
		X::Pod::Parser.new(msg => 'file ended in the middle of a pod', text => '').throw;
	}
	self.include_text;

	return self.data;
}

method over($text) {
	self.include_pod;
	self.depth++;
	self.data.push({ type => 'over', content => $text });
	return;
}

method item($text) {
	self.include_pod;
	self.data.push({ type => 'item', content => $text });
}

method back() {
	self.include_pod;
	self.depth--;
}

method set_title($text) {
	X::Pod::Parser.new(msg => 'TITLE set twice', text => $text).throw if self.title;
	X::Pod::Parser.new(msg => 'No value given for TITLE', text => $text).throw if $text !~~ /\S/;
	#X::Pod::Parser.new(msg => 'No POD should be before TITLE', text => $text).throw if self.data;

	$.title = $text;
	self.data.push({ type => 'title', content => $text });
	return;
}

method head($type, $text) {
	self.data.push({ type => $type, content => $text });
	return;
}

method include_text () {
	if $text ne '' {
		self.data.push({ type => 'text', content => $text });
		$text = '';
	}
}

method end_pod() {
	if $in_verbatim {
		self.include_verbatim;
	} else {
		self.include_pod;
	}
	return;
}
method include_pod () {
	if $pod ne '' {
		self.data.push({ type => 'pod', content => $pod });
		$pod = '';
	}
	return;
}

method include_verbatim () {
	if $verbatim ne '' {
		self.data.push({ type => 'verbatim', content => $verbatim });
		$verbatim = '';
	}
	$in_verbatim = 0;
	return;
}



method parse_file (Str $filename) {
	my $string = slurp($filename);
	self.parse($string);
}

# vim: ft=perl6
