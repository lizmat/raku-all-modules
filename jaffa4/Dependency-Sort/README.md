# Dependency-Sort
This is a Perl6 module. It serialises a list of dependencies or it performs a topological sort on directed graph.

Example:
```
my %h; # this represents one node
my %g;
%h<itemid> = 1; # itemid should be unique for each rach
%g<itemid> = 2;
%h<name>   = '1';
%g<name>   = '2';

my %j  = ( "itemid", 3, "name", 3 );
my %j4 = ( "itemid", 4, "name", 4 );

my $s = Dependency::Sort.new();

$s.add_dependency( %h, %g ); # this means %h depends on %g
$s.add_dependency( %h, %j );

$s.add_dependency( %j, %j4 );
$s.add_dependency( %j, %g );

$s.add_dependency( %g, %j );


if !$s.serialise  # returns false if there is an error
{
  die $s.error_message; # the error message, meaning circular reference
}
else
{ # list of nodes in result... starting with independent ones.. then less dependent ones
  say $s.result.perl; # prints independent ones first
}
```
