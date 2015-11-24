
use v6;

=begin pod

=head1 NAME

JSON::Infer::Class

=head1 DESCRIPTION

This holds the infered definition of a class to be generated from
JSON input.

=head2 METHODS

=head3 attribute name

This is the name of the class.

=head3 attribute attributes

This is a L<Hash> of the L<JSON::Infer::Attribute> discovered in the object
keyed by the name of the attribute.

=head3 attribute top-level

This is a L<Bool> that indicates whether the class is the first one
encountered.  It will be set by C<infer> method of L<JSON::Infer> on
the class that it will return.

This is used internally by C<make-class> to determine whether it should
add any preamble that might be required.

=head3 method new-from-data

    multi method new-from-data(:$class-name, :$content) returns JSON::Infer::Class
    multi method new-from-data(Str $name, $data ) returns JSON::Infer::Class

This returns a L<JSON::Infer::Class> constructed from the provided
reference.

=head3 method populate-from-data

    method populate-from-data(JSON::Class:D: $datum)

This performs the actual inference from a single record.

=head3 method new-attribute

    method new-attribute(Str $name, $value) returns JSON::Infer::Attribute 

This creates a new attribute with the supplied name and its type infered
from the supplied C<$value> and adds it to the class, returning the
new L<JSON::Infer::Attribute>.

=head3 method add-attribute

    method add-attribute(JSON::Infer::Attribute $attr)

Add the attribute to this class, along with any classes that may have been
discovered

=head3 method make-class

    multi method make-class(Int $level  = 0) returns Str

This returns the string representation of the class that has been
constructed. The argument C<$level> indicates the depth within the
nested structure and controls the indentation.

=head3 method file-path

    method file-path() returns Str

This creates the suggested file path that can be used to save the output
of C<make-class>.  

=end pod

use JSON::Infer::Role::Classes;
use JSON::Infer::Role::Types;

class JSON::Infer::Class does JSON::Infer::Role::Classes does JSON::Infer::Role::Types {

    use JSON::Infer::Attribute;

    has Bool $.inner-class = False;

    multi method new-from-data(:$class-name, :$content, Bool :$inner-class = False) returns JSON::Infer::Class {
        self.new-from-data($class-name, $content, $inner-class);
    }

    multi method new-from-data(Str $name, $data, $inner-class = False ) returns JSON::Infer::Class {

        my $obj = self.new(:$name, :$inner-class);

        my @data;

        given $data {
            when Array {
                @data = $data.list;
            }
            default {
                @data.push($data);
            }
        }

        for @data -> $datum {
            $obj.populate-from-data($datum);
        }

        $obj;
    }


    method populate-from-data($datum) {

        for $datum.kv -> $attr, $value {
            if not %!attributes{$attr}:exists {
                my $new = self.new-attribute($attr, $value);
            }
        }
    }


    method new-attribute(Str $name, $value) returns JSON::Infer::Attribute {

        my $new = JSON::Infer::Attribute.new-from-value($name, $value, $!name, $!inner-class);
        self.add-attribute($new);
        $new;
    }

    has Str $.name is rw;

    has Bool $.top-level is rw = False;

    has JSON::Infer::Attribute %.attributes is rw;

    method add-attribute(JSON::Infer::Attribute $attr) {
        %!attributes{$attr.name} = $attr;
        self.add-classes($attr);
        self.add-types($attr);
    }

    multi method make-class(Int $level  = 0) returns Str {
        my $indent = "    " x $level;

        my Str $ret;

        if $!top-level {
            $ret ~= "{ $indent }use JSON::Class;\n{ $indent }use JSON::Name;\n";

        }

        $ret ~= $indent ~ "class { self.name } does JSON::Class \{";
        my $next-level = $level + 1;

        for self.classes -> $class {
            $ret ~= "\n" ~ $class.make-class($next-level);
        }

        for self.attributes.kv -> $name, $attr {
            $ret ~= "\n" ~ $attr.make-attribute($next-level) ;
        }

        $ret ~= "\n$indent\}";
        $ret;
    }

    method file-path() returns Str {
        my $path = $*SPEC.catfile($!name.split('::'));
        $path ~= '.pm';
        $path;
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
