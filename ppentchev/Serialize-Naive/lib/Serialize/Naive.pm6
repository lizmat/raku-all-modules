unit role Serialize::Naive:ver<0.2.1>:auth<github:ppentchev>;

use v6.c;
use strict;

my $serialize-basic-types = (Str, Str:D, Bool, Bool:D,
    Int, Int:D, UInt, UInt:D, Rat, Rat:D, Any, Any:D);

sub walk-type($type, $value, Sub :$objfunc, :$array-type, :$hash-type, Sub :$warn)
{
	for $serialize-basic-types.values -> $basic {
		next unless $basic === $type;

		# Ah, weirdness...
		if $type === Rat || $type === Rat:D {
			return $value.Rat;
		} else {
			return $value;
		}
	}

	if $type ~~ Positional {
		my $sub = $type.of;
		my $arr-type = $array-type !=== Any?? $array-type!!
		    $type.WHICH ~~ /^ 'Positional[' /?? Array!! $type;
		return $arr-type.new($value.values.map: {
			walk-type($sub, $_, :objfunc($objfunc), :warn($warn))
		});
	}

	if $type ~~ Associative {
		my $sub = $type.of;
		my $h-type = $hash-type !=== Any?? $hash-type!!
		    $type.WHICH ~~ /^ 'Associative[' /?? Hash!! $type;
		return $h-type.new($value.kv.map: -> $k, $v {
			$k => walk-type($sub, $v, :objfunc($objfunc),
			    :array-type($array-type), :hash-type($hash-type),
			    :warn($warn))
		});
	}

	return $objfunc($value, $type, :warn($warn));
}

sub do-deserialize(%data, $type, Sub :$warn)
{
	my %build;
	my Bool %handled;
	for $type.^attributes -> $attr {
		my Str $name = $attr.name;
		$name ~~ s/^ <[$%@]> '!' //;
		my $type = $attr.type;

		next unless %data{$name}:exists;
		%handled{$name} = True;
		my $value = %data{$name};
		%build{$name} := walk-type($type, $value,
		    :objfunc(&do-deserialize), :warn($warn));
	}

	my Str @unhandled = %data.keys.grep: { not %handled{$_}:exists };
	if @unhandled && $warn.defined {
		&$warn("Deserializing " ~ $type.^name ~ ": " ~
		    "unhandled data elements: " ~ @unhandled);
	}
	return $type.new(|%build);
}

method deserialize(%data, Sub :$warn)
{
	return do-deserialize %data, self.WHAT, :warn($warn);
}

sub deserialize($type, %data, Sub :$warn) is export
{
	return do-deserialize %data, $type, :warn($warn);
}

sub do-serialize($obj, $type, Sub :$warn)
{
	my %build;
	for $type.^attributes -> $attr {
		next unless $attr.has_accessor;

		my Str $name = $attr.name;
		$name ~~ s/^ <[$%@]> '!' //;
		my $value = $attr.get_value($obj);
		next unless $value.defined;

		%build{$name} = walk-type($attr.type, $value,
		    :objfunc(&do-serialize),
		    :array-type(Array), :hash-type(Hash),
		    :warn($warn));
	}
	return %build;
}

method serialize(Sub :$warn)
{
	return do-serialize self, self.WHAT, :warn($warn);
}

sub serialize($obj, Sub :$warn) is export
{
	return do-serialize $obj, $obj.WHAT, :warn($warn);
}

=begin pod

=head1 NAME

Serialize::Naive - recursive serialization and deserialization interface

=head1 SYNOPSIS

=begin code
    use Serialize::Naive;

    class Point does Serialize::Naive
    {
        has Rat $.x;
        has Rat $.y;
    }

    class Circle does Serialize::Naive
    {
        has Point $.center;
        has Int $.radius;
    }

    class Polygon does Serialize::Naive
    {
        has Str $.label;
        has Point @.vertices;
    }

    my %data = radius => 5, center => { x => 0.5, y => 1.5 };
    my Circle $c .= deserialize(%data);

    my %coords = $c.center.serialize;
    say "X %coords<x> Y %coords<y>";

    my Polygon $sq .= new(:label("A. Square"),
        :vertices(Array[Point].new(
            Point.new(:x(0.0), :y(0.0)),
            Point.new(:x(1.0), :y(0.0)),
            Point.new(:x(1.0), :y(1.0)),
            Point.new(:x(0.0), :y(1.0)),
    )));
    %data = $sq.serialize;
    say %data;

    %data<weird> = 'ness';
    %data<vertices>[1]<unhand> = 'me';

    say 'Warnings silently ignored';
    $sq .= deserialize(%data);

    say 'Warnings displayed';
    $sq .= deserialize(%data, :warn(&note));
=end code

=head1 DESCRIPTION

This role provides two methods to recursively serialize Perl 6 objects to
Perl 6 data structures and, later, deserialize them back.  No attempt is
made to preserve type information in the serialized data; the caller of
the C<deserialize()> method should take care to pass the proper data
structure for the top-level class, and the inner objects and classes will
be discovered and recursed into automatically.

=head1 METHODS

=begin item1
method serialize

    method serialize()

Return a hash containing key/value pairs for all the public attributes of
the object's class.  Attributes are classified in several categories:

=begin item2
Basic types

The value of the attribute is stored directly as the hash pair value.
=end item2

=begin item2
Typed arrays or hashes

The value of the attribute is stored as respectively an array or a hash
containing the recursively serialized values of the elements.
=end item2

=begin item2
Other classes

The value of the attribute is recursively serialized to a hash using
the same algorithm.
=end item2
=end item1

=begin item1
method deserialize

    method deserialize(%data, Sub :$warn);

Instantiate a new object of the invocant's type, initializing its
attributes with the values from the provided hash.  Any attributes of
composite or complex types are handled recursively in the reverse manner
as the serialization described above.

The optional C<$warn> parameter is a handler for warnings about any
inconsistencies detected in the data.  For the present, the only problem
detected is hash keys that do not correspond to class attributes.
=end item1

=head1 FUNCTIONS

The C<Serialize::Naive> module also exports two functions:

=begin item1
sub serialize

    sub serialize($obj)

Serialize the specified object just as C<$obj.serialize()> would.

=end item1

=begin item1
sub deserialize

    sub deserialize($type, %data, Sub :$warn)

Deserialize an object of the specified type just as
C<$type.deserialize(%data, :warn($warn))> would.

=end item1

=head1 SEE ALSO

L<Serialize::Tiny|https://modules.perl6.org/dist/Serialize::Tiny>

=head1 AUTHOR

Peter Pentchev <L<roam@ringlet.net|mailto:roam@ringlet.net>>

=head1 COPYRIGHT

Copyright (C) 2016  Peter Pentchev

=head1 LICENSE

The Serialize::Naive module is distributed under the terms of
the Artistic License 2.0.  For more details, see the full text of
the license in the file LICENSE in the source distribution.

=end pod
