use v6;
use XHTML::Writer :ALL;

constant NL = "\n";

my @tags = <div p span b code>;

sub random-name () {
	(|('A'..'Z'), |('a'..'z')).pick((3..10).pick).join('')
}

my int $max-rec = 15;
my int $element-counter = 5000;

sub recurser (int $rec-limit is copy) {
	$element-counter--;
	$rec-limit--;
	with @tags.pick {
		my $named-args = ::('&' ~ .Str).signature.params.grep(*.named)>>.name;
		my $arguments = $named-args.pick((1..5).pick).map({ $_.substr(1) ~ '=>"' ~ random-name() ~ '"' }).join(', ');
		my $children = "";
		if $rec-limit > 0 {
			$children = recurser($rec-limit) xx ((0..$rec-limit).pick) if $element-counter > 0;
			$children = any(|$children) ?? ', ' ~ $children.join(', ') !! '';
		}
		NL ~ ("    " x $max-rec - 1 - $rec-limit) ~ .Str ~ "($arguments$children)" 
	}
}

put "use v6; use XHTML::Writer :ALL;";
put "note (now - BEGIN now).fmt('%.4f s');";
put recurser($max-rec);
