use v6;

=begin pod

=head1 NAME

Lumberjack::Message::JSON - role to allow Lumberjack::Message to serialise/deserialise as JSON

=head1 SYNOPSIS

=begin code

use Lumberjack;
use Lumberjack::Message::JSON;

my $message = Lumberjack::Message.new(message => 'this is a message');
$message does Lumberjack::Message::JSON;

my $str = $message.to-json;

...

my $new-message = (Lumberjack::Message but Lumberjack::Message::JSON).from-json($str);

# Alternatively the derived type can be provided as a constant:

constant JSONMessage = (Lumberjack::Message but Lumberjack::Message::JSON);

...

=end code

=head1 DESCRIPTION

This is used by L<Lumberjack::Dispatcher::Proxy>,
L<Lumberjack::Application::PSGI> and L<Lumberjack::Application::WebSocket>
to serialise and deserialise the L<Lumberjack::Message> to/from JSON
for transport over HTTP or websockets.

It is implemented as role that can be mixed at run-time to existing
Message objects and to create a derived type to un-marshal to (see
the SYNOPSIS.)

Itself it uses C<JSON::Class> to provide C<to-json> and C<from-json>
and provides custom marshallers and un-marshallers to ensure that the
data is rendered meaningful in JSON.

The JSON will be something like:

=begin code
{
   "backtrace" : [
      {
         "file" : "-e",
         "line" : 1,
         "subname" : "<unit>",
         "code" : {}
      }
   ],
   "message" : "this is a test",
   "class" : {
      "log-level" : 2,
      "is-logger" : false,
      "name" : "Any"
   },
   "level" : 2,
   "when" : "2016-04-12T00:18:34.435650+01:00"
}

=end code

Which reflects the L<Lumberjack::Message> fairly closely.  There may of course
be more backtrace frames.

The 'class' object in the JSON when de-serialised may cause a temporary type
to be created with the name provided if the type is not available on the 
target system, if "is-logger" is true then it will have the C<Lumberjack::Logger>
applied and the log-level set. This is done so that the message will
appear the same as one created on the local system for a message received
from a remote logger.

=end pod

use Lumberjack;
use JSON::Class;

role Lumberjack::Message::JSON does JSON::Class {

    has Bool $!been-monkeyed;

    sub marshal-class($v) {
        if $v ~~ Lumberjack::Logger {
            {
                name => $v.^name,
                log-level => $v.log-level.Int,
                is-logger    => True
            };
        }
        else {
            {
                name => $v.^name,
                log-level => Lumberjack.default-level.Int,
                is-logger    => False
            };
        }
    }

    sub unmarshal-class($v) {
        my $class = (try require ::($v<name>));

        my $t = ::($v<name>);
        if !$t && $t ~~ Failure {
            $class := Metamodel::ClassHOW.new_type(name => $v<name>);
            $class.^add_parent(Any);
            if $v<is-logger> {
                $class.^add_role(Lumberjack::Logger);
            }
            $class.^compose;
        }
        if $class ~~ Lumberjack::Logger {
            $class.log-level = Lumberjack::Level($v<log-level>);
        }
        $class;
    }


    method !add-marshallers() {
        my $when = self.^attributes.grep({$_.name eq '$!when'}).first;
        trait_mod:<is>($when, marshalled-by => 'Str');
        trait_mod:<is>($when, unmarshalled-by => -> $v { DateTime.new($v) });
        my $class = self.^attributes.grep({$_.name eq '$!class'}).first;
        trait_mod:<is>($class, marshalled-by => &marshal-class);
        trait_mod:<is>($class, unmarshalled-by => &unmarshal-class);
        my $level = self.^attributes.grep({ $_.name eq '$!level' }).first;
        trait_mod:<is>($level, marshalled-by => -> $v { $v.Int });
        trait_mod:<is>($level, unmarshalled-by => -> $v { Lumberjack::Level($v) });
    }

    method to-json( --> Str ) {
        self does JSON::Class;    
        self!add-marshallers;
        self.JSON::Class::to-json;
    }
    method from-json($json --> Lumberjack::Message::JSON ) {
        self!add-marshallers;
        (self but JSON::Class).JSON::Class::from-json($json);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
