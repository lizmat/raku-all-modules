use v6;

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

=end pod


class JSON::Infer:ver<0.0.5>:auth<github:jonathanstowe> {


    use JSON::Infer::Class;
    use JSON::Infer::Exception;

    method infer(:$uri!, Str :$class-name = 'My::JSON') returns JSON::Infer::Class {
        my $ret;


        if $uri.defined {

            my $resp =  self.get($uri);

            if $resp.is-success() {

                my $content = self.decode-json($resp.decoded-content());

                $ret = JSON::Infer::Class.new-from-data(:$class-name, :$content);
                $ret.top-level = True;
            }
            else {
                JSON::Infer::Exception.new(:$uri, message => "Couldn't retrieve URI $uri").throw;
            }
        }
        else {
        }

        $ret;
    }


    has $.ua is rw;

    method get(|c) {
        self.ua.get(|c);
    }

    method ua() is rw {
        require HTTP::UserAgent;
        if not $!ua.defined {
            $!ua = ::('HTTP::UserAgent').new( default-headers   => $.headers, useragent => $?PACKAGE.^name ~ '/' ~ $?PACKAGE.^ver);
        }
        $!ua;
    }


    has $.headers is rw;

    method headers() is rw {

        require HTTP::Header;
        if not $!headers.defined {
            $!headers = ::('HTTP::Header').new();
            $!headers.field('Content-Type'  => $!content-type);
            $!headers.field('Accept'  => $!content-type);
        }
        $!headers;
    }


    has Str $.content-type  is rw =  "application/json";

    method decode-json(Str $content) returns Any {
        use JSON::Tiny;
        from-json($content);
    }

}
# vim: expandtab shiftwidth=4 ft=perl6
