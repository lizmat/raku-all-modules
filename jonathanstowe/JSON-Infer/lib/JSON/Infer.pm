use v6.c;

=begin pod

=head1 NAME

JSON::Infer - Infer Moose Classes from JSON objects

=head1 SYNOPSIS

=begin code


# Use the script to do it simply:
# Create the modules in the directory "foo"

p6-json-infer --uri=http://api.mixcloud.com/spartacus/party-time/ --out-dir=foo --class-name=Mixcloud::Show

# Or do it in your own code:

use JSON::Infer;

my $obj = JSON::Infer.new()
my $ret = $obj.infer(uri => 'http://api.mixcloud.com/spartacus/party-time/', class-name => 'Mixcloud::Show');

say $ret.make-class; # Print the class definition

=end code


=head1 DESCRIPTION

JSON is nearly ubiquitous on the internet, developers love it for making
APIs.  However the webservices that use it for transfer of data rarely
have a machine readable specification that can be turned into code so
developers who want to consume these services usually have to make the
client definition themselves.

This module aims to provide a way to generate Perl 6 classes that can represent
the data from a JSON source.  The structure and the types of the data is
inferred from a single data item so the accuracy may depend on the
consistency of the data.

=head2 METHODS

=head3 infer

This accepts a single path and returns a L<JSON::Infer::Class>
object, if there is an error retrieving the data or parsing the response
it will throw an exception.

It requires the following named arguments:

=head4 uri

This is the uri that will be used to retrieve the content.  It will need
to be some protocol scheme that is understood by L<HTTP::UserAgent>. This
is required.

=head4 class-name

This is the name that will be used for the generated class, any child
classes that are discovered will parsing the attributes will have a name
based on this and the name of the attribute. If it is not supplied the
default is C<My::JSON> will be used.

=head3 ua

The L<HTTP::UserAgent> that will be used. 

=head3 headers

Returns the default set of headers that will be applied to the
HTTP::UserAgent object.

=head3 content-type

This is the content type that we want to use.  The default is
"application/json".


=head2 JSON::Infer::Class

This holds the infered definition of a class to be generated from
JSON input.

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


=head2 JSON::Infer::Attribute

A description of an infered attribute

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

use JSON::Fast;
use HTTP::UserAgent;

class JSON::Infer:ver<0.0.14>:auth<github:jonathanstowe> {

    
    role Classes        { ... }
    role Types          { ... }
    class Attribute     { ... }
    class Class         { ... }
    class Type          { ... }

    class X::Infer is Exception {
        has Str         $.message is rw;
        has Str         $.uri is rw;
        has Exception   $.inner-exception is rw;
    }


    role Entity {
        has Str $.name is rw;
    }

    class  Type does Entity {
        has Str     $.subtype-of is rw handles(has-subtype => 'defined');
        has Bool    $.array is rw = False;
        has Class   $.of-class is rw;
    }
    
    role Classes {
        has @.classes is rw;

        method  add-classes(Mu:D $object) {

            if $object.does($?ROLE) {
                for $object.classes -> $class {
                    if !?@!classes.grep({$class.name eq $_.name}) {
                        @!classes.push($class);
                    }
                }
            }
            if  $object ~~ Class {
                @!classes.push($object);
            }
        }
    }


    role Types {
        has @.types is rw;
        method  add-types(Mu:D $object ) {
            if $object.does($?ROLE) {
                for $object.types -> $type {
                    @!types.push($type);
                }
            }

            if $object ~~ Type {
                @!types.push($object);
            }
        }
    }

    class Class does Classes does Types {

        has Bool $.inner-class = False;

        multi method new-from-data(:$class-name, :$content, Bool :$inner-class = False) returns Class {
            self.new-from-data($class-name, $content, $inner-class);
        }

        multi method new-from-data(Str $name, $data, $inner-class = False ) returns Class {
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


        method new-attribute(Str $name, $value) returns Attribute {

            my $new = Attribute.new-from-value($name, $value, $!name, $!inner-class);
            self.add-attribute($new);
            $new;
        }

        has Str $.name is rw;

        has Bool $.top-level is rw = False;

        has Attribute %.attributes is rw;

        method add-attribute(Attribute $attr) {
            %!attributes{$attr.name} = $attr;
            self.add-classes($attr);
            self.add-types($attr);
        }

        multi method make-class(Int $level  = 0) returns Str {
            my $indent = "    " x $level;
            my Str $ret;

            if $!top-level {
                $ret ~= "\n{ $indent }use JSON::Name;\n{ $indent }use JSON::Class;\n";
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


    class Attribute does Classes does Types {

        method  new-from-value(Str $name, $value, $class, Bool $inner-class = False) returns Attribute {
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
            my $obj = Class.new-from-data(self.child-class-name(), $value, True);
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

    proto method infer(|c) { * }

    multi method infer(Str:D :$uri!, Str :$class-name = 'My::JSON') returns Class {
        my $ret;
        my $resp =  self.get($uri);
        if $resp.is-success() {
            my $json = $resp.decoded-content();
            $ret = self.infer(:$json, :$class-name);
        }
        else {
            X::Infer.new(:$uri, message => "Couldn't retrieve URI $uri").throw;
        }
        $ret;
    }

    multi method infer(Str:D :$file!, :$class-name = 'My::JSON') returns Class {
        my $io = $file.IO;
        if $io.e {
            self.infer(file => $io, :$class-name);
        }
        else {
            X::Infer.new(uri => $file, message => "File $file does not exist").throw;
        }
    }

    multi method infer(IO::Path:D :$file!, :$class-name = 'My::JSON') returns Class {
        my $json = $file.slurp();
        self.infer(:$json, :$class-name);
    }

    multi method infer(Str:D :$json!, Str :$class-name = 'My::JSON') returns Class {
        my $content = self.decode-json($json);
        my $ret = Class.new-from-data(:$class-name, :$content);
        $ret.top-level = True;
        $ret;
    }


    has $.ua is rw;

    method get(|c) {
        self.ua.get(|c);
    }

    method ua() is rw {
        if not $!ua.defined {
            $!ua = HTTP::UserAgent.new( default-headers   => $.headers, useragent => $?PACKAGE.^name ~ '/' ~ $?PACKAGE.^ver);
        }
        $!ua;
    }


    has $.headers is rw;

    method headers() is rw {

        if not $!headers.defined {
            $!headers = HTTP::Header.new();
            $!headers.field('Content-Type'  => $!content-type);
            $!headers.field('Accept'  => $!content-type);
        }
        $!headers;
    }


    has Str $.content-type  is rw =  "application/json";

    method decode-json(Str $content) returns Any {
        from-json($content);
    }

}
# vim: expandtab shiftwidth=4 ft=perl6
