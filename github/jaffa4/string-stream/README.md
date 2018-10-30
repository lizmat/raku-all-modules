# String::Stream

Stream into a string or from a string. Use print, say to direct output into a string.


## Usage


	my $t = String::Stream.new(); # for both input and output

	print $t: "something";
 

	say $t: "something else";

	$*IN = Stream.new("puccini");
	
	my $out = say prompt "composer> "; # $out will contain puccini.
	
	print $t.buffer;
	somethingsomething else

## Similar module

	https://github.com/sergot/IO-Capture-Simple




