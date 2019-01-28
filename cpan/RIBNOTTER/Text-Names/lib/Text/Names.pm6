use v6;

unit module Text::Names;
#This code is under MIT license 

grammar LINE {
	token TOP { ^ <name> \s+ <probability> \s+ <cumulative> \s+ <rank> \s* $ }
	token real { \d+[\.\d+]? }
	token probability  { <real> }
	token cumulative  { <real> }
	token rank { \d+ }
	token name { \w+ }
}

sub get-name($filename) {
	state %buffer;
	if $_ = %buffer{$filename}.?pop() {
		return $_;	
	} else {
		%buffer{$filename} = get-names($filename, $*buffer-size // 1);
		return %buffer{$filename}.pop();
	}
}

sub get-names($filename, Int $count) {
	my @selected = (90.023.rand() for 1..$count).sort();
	my $file = open($filename);

	my @names = gather { 
		while $_ = $file.get() and @selected.elems > 0 {
			.chomp;
			my $match = LINE.parse( $_ );
			if $match<cumulative> > @selected[0] {
				@selected.shift();
				take ((~$match<name>).tclc);
			}
		}
	};
	@names.=pick: *; #prevent most popular from being first
	@names.=eager; #return a calculated list so the caching actually works 

	$file.close();
	return @names;

}

#| generate and return a single female first name 
sub get-female() is export  {
	return get-name(%?RESOURCES{"dist.female.first"}.absolute("/"));
}

#| generate and return a single male first name 
sub get-male() is export  {
	return get-name(%?RESOURCES{"dist.male.first"}.absolute("/"));
}

#|(generate and return a single last name. Note that the capitalization 
# of the last name may be incorrect for some names like "McDonald" because
# the data source file I have has the names in all caps
# )
sub get-last() is export  {
	return get-name(%?RESOURCES{"dist.all.last"}.absolute("/"));
}

#|(Gender means what type of name you want (vs the main identities which people
#could have). Note that `both` means both male and female names not names which
#are normally considered normal for male and female persons. There is no support
#for generating only the latter kind of name. 
#)
enum Gender is export ( male => "male", female => "female", both => "both" );
constant %REVERSE_GENDER = Map("male" => male, "female" => female, "both" => both);

#|(Generate a single first name of a given gender. Gender is supplied by which
#may be "male", "female", or "both". The default is "both". If you dislike magic
#strings you can use the enum types of male, female, and both.
#)
multi sub get-first(Str $gender) is export  {
	say("hello");
	get-first %REVERSE_GENDER{$gender}

}
#|(Generate a single first name. See the documentation for the string for more
#details.) 
multi sub get-first(Gender $gender=both) is export  {
	given $gender {
			when male {get-male()}
			when female {get-female()}
			when both {rand > .5 ?? get-female() !! get-male()}	
		};
}

#|(Generate a full name of a given gender. The gender argument works the same
#as for the get-first function)
multi sub get-full(Str $gender ) is export  {
	get-full %REVERSE_GENDER{$gender};
}
multi sub get-full(Gender $gender=both) is export  {
	my $first = get-first($gender);
	my $last = get-last();
	return "$first $last";

}

