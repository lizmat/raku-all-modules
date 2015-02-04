use v6;
use Test;

my $N = chr(13) ~ chr(10);

my @expected = Array.new(
	{type => 'text', content => "text before$N$N"},
	{type => 'pod' , content => "$N"},
	{type => 'title', content => 'document POD'},
	{type => 'pod' , content => "$N"},
	{type => 'head1', content => 'NAME'},
	{type => 'pod', content => "{$N}Text in name$N$N"},
	{type => 'head1', content => 'SYNOPSIS'},
	{type => 'pod',   content => "$N"},
	{type => 'verbatim', content => "    some verbatim$N    text$N$N"},
	{type => 'head1', content => 'OTHER'},
	{type => 'pod', content => "{$N}real text{$N}more text$N$N"},
	{type => 'verbatim', content => "  verbatim$N      more verb$N$N"},
	{type => 'pod', content => "text$N$N"},
	{type => 'head2', content => "subtitle"},
	{type => 'pod', content => "{$N}subtext$N$N"},
	{type => 'text', content => "{$N}text after$N$N$N"},
	);

plan 5 + 2 * @expected.elems;

use Pod::Parser;
ok 1, 'Loading module succeeded';

my $pp = Pod::Parser.new;
isa_ok $pp, 'Pod::Parser';

my @result = $pp.parse_file('t/files/a.pod');
for 0 .. @expected.elems-1 -> $i {
	is @result[$i]<type>, @expected[$i]<type>, "part $i - type {@expected[$i]<type>}";
	is @result[$i]<content>, @expected[$i]<content>, "part $i - content";
}

is_deeply @result, @expected, 'parse a.pod';

try {
	$pp.parse_file('t/files/two-titles.pod');
	CATCH {
		when X::Pod::Parser {
			is $_.msg, 'TITLE set twice', 'exception on duplicate TITLE';
		}
	}
}

try {
	$pp.parse_file('t/files/unknown-tag.pod');
	CATCH {
		when X::Pod::Parser {
			is $_.msg, 'Unknown tag', 'exception on unknown =tag';
		}
	}
}


done;
