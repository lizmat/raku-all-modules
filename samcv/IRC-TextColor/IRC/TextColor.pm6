use v6;
=head1 IRC::TextColor
=para
A plugin to style and color text for IRC. It can also convert the ANSIColor text and style from your terminal to IRC Text and style.

my %irc-styles =
	'bold'      => 2.chr,
	'bold_off'  => 2.chr,
	'italic'    => 29.chr,
	'underline' => 31.chr,
	'reset'     => 15.chr,
	'inverse'   => 22.chr,
	'color'     => 3.chr;
my %irc-colors =
	'white'       => '00',
	'black'       => '01',
	'blue'        => '02',
	'green'       => '03',
	'red'         => '04',
	'brown'       => '05',
	'purple'      => '06',
	'orange'      => '07',
	'yellow'      => '08',
	'light_green' => '09',
	'teal'        => '10',
	'light_cyan'  => '11',
	'light_blue'  => '12',
	'pink'        => '13',
	'grey'        => '14',
	'light_grey'  => '15';
my %ansi-style =
	reset         => "0",
	bold          => "1",
	underline     => "4",
	inverse       => "7",
	bold_off      => "22",
	underline_off => "24",
	inverse_off   => "27";
my %ansi-colors =
	black      => "30",
	red        => "31",
	green      => "32",
	yellow     => "33",
	blue       => "34",
#	magenta    => "35",
	purple    => "35",
#	cyan       => "36",
	light_cyan => "36",
	white      => "37",
	default    => "39";
my %ansi-back-colors =
	black   => "40",
	red     => "41",
	green   => "42",
	yellow  => "43",
	blue    => "44",
	magenta => "45",
	#cyan    => "46",
	light_cyan => "46",
	white   => "47",
	default => "49";
sub irc-style-char ( Str $style ) is export {
	return %irc-styles{$style} if %irc-styles{$style};
}
sub irc-color-start ( Str $color ) is export {
	return %irc-styles{'color'} ~ %irc-colors{$color} if %irc-colors{$color};
}
#| a shortened function. Like irc-style-text but you can use shorter versions like
#| C<ircstyle('text', :bold, :green)
sub ircstyle ( Str $text, *%args ) is export {
	my $color = %args.keys ∩ %irc-colors.keys;
	my $style = %args.keys ∩ %irc-styles.keys;
	if any($color.elems, $style.elems) > 1 {
		die "Cannot specify two styles or two colors at the same time.";
	}
	irc-style-text $text, :color($color[0]), :style($style[0]);
}

#| styles and colors text. returns a copy.
#| Colors allowed: white, blue, green, red, brown, purple, orange, yellow, light_green, teal,
#| light_cyan, light_blue, pink, grey, light_grey.
sub irc-style-text ( Str $text is copy, :$style? = 0, :$color? = 0, :$bgcolor? = 0 ) returns Str is export {
	if $color or $bgcolor {
		if $color and $bgcolor {
			$text = %irc-styles<color> ~ %irc-colors{$color} ~ ',' ~ %irc-colors{$bgcolor} ~ $text ~ %irc-styles<reset>;
		}
		elsif %irc-colors{$color} {
			$text = %irc-styles{'color'} ~ %irc-colors{$color} ~ $text ~ %irc-styles{'reset'};
		}
	}
	given $style {
		if %irc-styles{$style} {
			$text = %irc-styles{$style} ~ $text ~ %irc-styles{'reset'};
		}
	}
	return $text;
}
#| Convert ANSI style/colored text from your terminal output to IRC styled/colored text.
#| Supports both foreground and background color, as well as italic, underline and bold.
sub ansi-to-irc (Str $text is copy) is export returns Str {
	my $escape = "\e[";
	my $end = 'm';
	if $text ~~ /$escape/ {
		#say "matched escape";
		my $mescape = 'm' ~ $escape;
		# This is for when there are multiple codes in one block
		# \e[01;10m => \e[01m\e[10m so down below works correctly FIXME
		$text ~~ s:g/($escape \d+ )';'( \d+ m)/$0$mescape$1/;
		# This is to replace leading zeros on numbers so it matches properly FIXME
		$text ~~ s:g/$escape 0 (\d) /$escape$0/;
		for %ansi-colors -> $pair {
			#say "key: {$pair.key} value: {$pair.value}";
			if %irc-colors{$pair.key} {
				#say "key exists";
				my $final = $escape ~ $pair.value ~ $end;
				#say $final.ord;
				my $replaced = irc-color-start($pair.key);
				$text ~~ s:g/$final/$replaced/;
			}
		}
		for %ansi-back-colors -> $pair {
			if %irc-colors{$pair.key} {
				if %irc-colors{$pair.key} {
					my $final = $escape ~ $pair.value ~ $end;
					my $replaced = %irc-styles{'color'} ~ ',' ~ %irc-colors{$pair.key};
					$text ~~ s:g/$final/$replaced/;
				}
			}
		}
		for %ansi-style -> $pair {
			#say "key: {$pair.key} value: {$pair.value}";
			#$text ~~ s:g/$escape 0(\d)/$escape$0/;
			if %irc-styles{$pair.key} {
				my $final = $escape ~ $pair.value ~ $end;
				#say $final.ord.join(', ');
				my $replaced = %irc-styles{$pair.key};
				$text ~~ s:g/$final/$replaced/;
			}
		}
	}
	return $text;
}
