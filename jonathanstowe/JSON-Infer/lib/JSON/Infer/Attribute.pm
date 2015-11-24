
use v6;

=begin pod

=head1 NAME

JSON::Infer::Attribute

=head1 DESCRIPTION

A description of an infered attribute

=head2 METHODS

=over 4

=head3 new-from-value

This is an alternate constructor that will return a new object based
on the name and attributes infered from the valie.

The third argument is the name of the class the attribute was found in
this will be used to generate the names of any new classes found.

=head3 infer-from-value

This does the actual work of infering the type from the value provided.

=head3 process-object

This is used to process an object value returning the
L<JSON::Infer::Class> object.

=head3 name

The name of the attribute as found in the JSON data.

=head3 perl-name

The rules for what a valid Perl identifier can be are more restrictive
than those for JSON attribute names (which can be nearly any string,) this
returns a sanitised version of the JSON name to be used when generating
Perl code.

=head3 has-alternate-name

This is a L<Bool> to indicate whether C<name> and C<perl-name> differ.  
This is used internally when generating a string repreesentation of the
attribute to determine whether the C<json-name> trait is required.


=head3 type-constraint

The infered type constraint name.

=head3 class

Name of the class that this was being constructed for.

=head3 child-class-name

Returns the name of a class that will be used for an object type based on
this attribute.

=head3 is-array

A L<Bool> to indicate whether the attribute is an array or not.

=head3 sigil

This returns the sigil that should be used for the attribute (e.g '$', '@')

=head3 make-attribute

This returns a suitable string representation of the attribute for Perl.

=end pod

use JSON::Infer::Role::Classes;
use JSON::Infer::Role::Types;

class JSON::Infer::Attribute does JSON::Infer::Role::Classes does JSON::Infer::Role::Types {

    method  new-from-value(Str $name, $value, $class, Bool $inner-class = False) returns JSON::Infer::Attribute {

        my $obj = self.new(:$name, :$class, :$inner-class );
        $obj.infer-from-value($value);
        $obj;
    }


    method infer-from-value($value) {

        my $type_constraint;

        given $value {
            when Array {
                $!is-array = True;
                if ?$_.grep(Array|Hash) {
                    my $obj = self.process-object($_);
                    $type_constraint = $obj.name;
                }
                else {
                    $type_constraint = '';
                }
            }
            when Hash {
                my $obj = self.process-object($_);
                $type_constraint = $obj.name;

            }
            default {
                $type_constraint = $_.WHAT.^name;
            }
        }
        $!type-constraint = $type_constraint;
    }

    method process-object($value) {
        require JSON::Infer::Class;
        my $obj = ::('JSON::Infer::Class').new-from-data(self.child-class-name(), $value, True);
        self.add-classes($obj);
        self.add-types($obj);
        $obj;
    }


    has Str $.name is rw;
    has Str $.perl-name is rw;

    has Bool $.is-array = False;
    has Bool $.inner-class = False;

    method sigil() {
        $!is-array ?? '@' !! '$';
    }

    method perl-name() returns Str is rw {
        if not $!perl-name.defined {
            $!perl-name = do if $!name !~~ /^<.ident>$/ {
                my $prefix = $!class.split('::')[*-1].lc;
                $prefix ~ $!name;
            }
            else {
                $!name;
            }
        }
        $!perl-name;
    }

    method has-alternate-name() returns Bool {
        self.perl-name ne $!name;
    }

    has Str $.type-constraint is rw;
    has Str $.class is rw;


    has Str $.child-class-name is rw;

    method child-class-name() returns Str is rw { 
        if not $!child-class-name.defined {
            my Str $name = $!name;
            $name ~~ s:g/_(.)/{ $0.uc }/;
            if self.is-array {
                $name ~~ s/s$//;
            }
            $!child-class-name =  $name.tc;
        }
        $!child-class-name;
    }

    multi method make-attribute(Int $level = 0) returns Str {
        my $indent = "    " x $level;
        my Str $attr-str = $indent ~ "has { self.type-constraint } { self.sigil}.{ self.perl-name }";
        if self.has-alternate-name {
            $attr-str ~= " is json-name('{ self.name }')";

        }
        $attr-str ~ ';';
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
