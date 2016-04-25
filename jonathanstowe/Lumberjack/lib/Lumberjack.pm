use v6.c;

=begin pod

=head1 NAME

Lumberjack - A simple logging framework.

=head1 SYNOPSIS

=begin code

use Lumberjack;

# Output to $*ERR by default - in colour!
Lumberjack.dispatchers.append: Lumberjack::Dispatcher::Console.new(:colours);

class MyClass does Lumberjack::Logger {
	method start() {
       self.log-info("Starting ...");
       ...
   }

   method do-stuff() {
      self.log-debug("Doing stuff ...");
      ...
      if $something-went-wrong {
         self.log-error("Something went wrong");
      }
   }
   method stop() {
       ...
       self.log-info("Stopped.");
   }
}

MyClass.log-level = Lumberjack::Debug;


=end code

=head1 DESCRIPTION

This is more of a sketch for a logging framework, or perhaps even a
logging framework framework. It provides the minimum interface that
classes can consume a role to provide themselves logging facilities
and set a class wide logging level and have the messages delivered to
dispatchers which can do what they want with the messages and specify
the levels of messages that they want to handle.

It doesn't mandate any particular configuration format as the setup is
entirely programmatic, I foresee that people providing their own higher
level configuration driven things on top of this.

I'm sure this doesn't yet have all the features to support all the
requirements people, but it is released with the basic interface
complete so it can actually be used.

The approach taken reflects a patten that I have found useful in large
object oriented programmes, where having the logging methods on a class
means that you have the means to make log messages wherever you have
an instance of the class without having to obtain a separate logger
object.

There are a couple of simple log dispatchers included which should get
you started, but I would envisage that more useful ones may be provided
as separate modules, though they are sufficiently simple to implement
you can provide your own as required.

=head1 METHODS

The main C<Lumberjack> class operates as if all the methods and attributes
are 'static', that is to say they are wrapped under the hood to be invoked
against a single instance that is created the first time it is needed. 

=head2 method log

    method log(Message $message)

This injects the L<Lumberjack::Message|#Lumberjack::Message> into the
dispatch mechanism, it is typically called by the methods provided by
the role L<Lumberjack::Logger|#Lumberjack::Logger> though you may call
this directly if you wish to create your own message and/or dispatch 
the message outside of any particular class.

=head2 all-messages

This is a Supply that reflects all of the messages that traverse the
system, before they are filtered for dispatch. In normal usage this
is used internally to feed the dispatch mechanism, but can be tapped
to provide a feed for an external logging mechanism for instance.

=head2 fatal-messages

This is a Supply derived from C<all-messages> that only has the messages
at level C<Fatal>.

=head2 error-messages

This is a Supply derived from C<all-messages> that only has the messages
at level C<Error>.

=head2 warn-messages

This is a Supply derived from C<all-messages> that only has the messages
at level C<Warn>.

=head2 info-messages

This is a Supply derived from C<all-messages> that only has the messages
at level C<Info>.

=head2 debug-messages

This is a Supply derived from C<all-messages> that only has the messages
at level C<Debug>.

=head2 trace-messages

This is a Supply derived from C<all-messages> that only has the messages
at level C<Trace>.

=head2 filtered-messages 

This is a Supply that is filtered to be only those that will be candidates
for dispatch.  To be a candidate the C<level> of the message must be 
equal to or of higher "severity" (lower numerical value,) than the C<log-level>
of the class the message is for, or (if the class is unknown,) the 
C<default-log-level>. This is tapped internally to feed the dispatchers, but
you could tap this yourself if you want to send the filtered messages to an
alternative logging system.

=head2 default-log-level

This is the default level that is used to filter the messages when the
class of the message is unknown (or has no level set.) It may also be
used to set a default on new messages when the level isn't supplied
(but this is almost certainly not what you want to do.) The default
is C<Info>.

=head2 dispatchers

This is an Array of objects that have the role
L<Lumberjack::Dispatcher|#Lumberjack::Dispatcher> role. These should be
object instances and not names or type objects.  The rationale behind
making them objects rather than types is so that multiple dispatchers of
the same type can be used with a different configuration each handling
messages for different log levels or for different classes. An example
might be a dispatcher that writes to a file, where an instance might
log C<Debug> messages to a C<debug.log> and a separate instance logs
the C<Error> messages to an C<error.log>.

=head2 sub format-message

    sub format-message(Str $format, Message $message, :&date-formatter = &default-date-formatter, Int :$callframes) returns Str is export(:FORMAT)

This is a utility subroutine that is only exported when the C<:FORMAT>
import adverb is applied to the use of C<Lumberjack> It provides a simple
formatting of the messages with C<sprintf> like directives supplied in
C<$format>. C<$callframes> indicates the number of frames to be skipped in
the backtrace to find the frame we are interested in. C<&date-formatter>
is a subroutine that accepts a DateTime and returns a formatted string
(the default is RFC2822-like.)  The Format directives are:

=head3 %D

The formatted date, using the provided date-formatter or the default.

=head3 %P

The Process ID of this process.

=head3 %C

The class name of the the class from the Message.

=head3 %L

The logging level of the message.

=head3 %M

The text of the message.

=head3 %N

The program name.

=head3 %N

The current file, derived from the backtrace (thus C<$callframes> may need adjustment)

=head3 %l

The line number in the current file, derived from the backtrace.

=head3 %S

The current subroutine or method name, derived from the backtrace.

=head1 Lumberjack::Message

Objects of this class represent the messages that are passing through the
logger, in the simplest case where one is using the methods provided by
the role L<Lumberjack::Logger|#Lumberjack::Logger> then these objects will
be created for you with sensible defaults. You are free to create them
yourself if you want other values than the defaults or you can sub-class
to provide different attributes if you have different requirements and
the dispatchers that you are using would make use of them.

The messages themselves contain the information required to determine
whether they will becomes candidates for dispatch and select which 
dispatchers (if any,) they will be sent to.

The messages can be smart matched against items of the enum
L<Lumberjack::Level|#Lumberjack::Level>.

=head2 class

This is the type object of the class that the message
is for and will be populated by the logging methods of the
L<Lumberjack::Logger|#Lumberjack::Logger> role.  If it is populated
it will be used in two ways. firstly if it is a C<Lumberjack::Logger>
the C<log-level> "class method" will be used to determine whether the
message should be dispatched, that is if the level of the message is of a
higher or equal "severity" than the C<log-level> it will be dispatched,
secondly it will be used to select which dispatchers it will be handed
to by smart matching against the C<classes> of the dispatcher.

=head2 level

This is the L<Lumberjack::Level|#Lumberjack::Level> representing
the level or severity of the message, it will be checked against
the C<log-level> of C<class> if available, or the C<default-log-level>
to determine whether the message should be a candidate for dispatch.
If this is not provided to the constructor for the message object then
it will be set to the C<default-log-level> which is probably not what
you want. The helpers in L<Lumberjack::Logger|#Lumberjack::Logger> take
care of that for you however.

=head2 backtrace

This is a list of Backtrace::Frame object that represents the execution
context when the log message is constructed, it can be used by the
dispatcher to provide information about the call site.  It will be
populated for you when the message is created, however if you are
sending a message, for example, about a caught exception you can supply
a backtrace that came from elsewhere (though you may need to adjust the
frames that the dispatcher examines accordingly.)

=head2 message

This is the only required field of the message that there is no
default for, and represents the free text payload of the log
message.

=head2 when

This is the DateTime when the Message was created, a dispatcher
is free to use this in generating a log entry.

=head1 Lumberjack::Dispatcher

This is role that must be consumed by your dispatcher classes,
it defines the interface for dispatch and for the selection
of the the messages that is will handle. The actual dispatchers
should be instances of your classes and can have any configuration
required for them to work.

There are two simple dispatcher classes provided in the module 
and others might be found in the module ecosystem.

Whilst you are free to implement the dispatcher however you wish
you should bear in mind that if you require a C<BUILD> method and
wish to populate the C<levels> and C<classes> attributes then
you have to provide for them in your signaturem such as:

=begin code

    submethod BUILD(:$my-parameter, :$!classes, :$!levels) {
        ...
    }

=end code

This is unfortunately necessary because a default BUILD for the
role won't be called if a class provides one.

=head2 method log

    method log(Message $message)

This is stubbed in the role and C<must> be provided by a composing class.
It is provided with the selected messages and is entirely free to do
whatever it wants to implement.

=head2 levels

The value of this attribute is smart matched against the C<level>
attribute of a message to determine whether this dispatcher should receive
it, it can be a single value of L<Lumberjack::Level|#Lumberjack::Level>,
an C<any> Junction of one or more of those values, a subroutine that
will take a level as an argument an return a Bool or any other object
that will smart match against a C<level>.  The default is C<Any>.

=head2 classes

The value of this attribute is smart matched against the C<class>
attribute of a message to determine (along with the matching of level,)
whether this dispatcher should receive it.  It can be a class type object,
a Junction of one or more type objects, a subroutine that will take the
type object as an argument and return a Bool or anything else that could
conceivably smart match a class type object.

=head1 Lumberjack::Logger

This is role that provides a convenient interface to the logging
functionality that can be consumed by any class. The advantage of
using the role rather than accessing the C<log> method of C<Lumberjack>
directly is that you don't need to worry about constructing the message
and so forth.

=head2 method log-level

        method log-level() returns Level is rw

This is a "class method" (that is setting the value will apply to all
instances of the class,)  it is the value that is compared to the C<level>
of a message to determine whether the message that should be dispatched
(contingent of course on there being a suitable dispatcher that would
accept it.)  Two special values of L<Lumberjack::Level|#Lumberjack::Level>
are provided which may be used here as well as the standard values:
C<All> which will cause all messages to be dispatched, and C<Off> which
will cause no messages to be dispatched whatever the severity.

=head2 method log

        multi method log(Message $message)
        multi method log(Level $level, Str $message)

This method sends a message to be considered for dispatch.  They may
be suitable if, for example, the C<level> of the method needs to be
calculated or the message is actually being sent on behalf of some other
object or process. For most cases however the level specific helpers
will probably be more convenient.

=head2 method log-trace

        method log-trace(Str() $message)

This will send a message at level C<Trace> with the the supplied
C<message>. It will be sent for dispatch if the applicable C<log-level>
is C<All> or C<Trace>.

=head2 method log-trace

        method log-debug(Str() $message)

This will send a message at level C<Debug> with the supplied C<message>
it will be sent for dispatch if the applicable C<log-level> is C<Debug>¸
C<Trace> or C<All>.

=head2 method log-info

        method log-info(Str() $message)

This will send a message at level C<Info> with the supplied C<message>. It
will be sent for dispatch if the applicable C<log-level> is C<Info>,
C<Debug>, C<Trace> or C<All>.

=head2 method log-warn

        method log-warn(Str() $message)

This will send a message at level C<Warn> with the supplied C<message>. It
will be sent for dispatch at levels C<Warn>, C<Info>, C<Debug>, C<Trace>
or C<All>.

=head2 method log-error

        method log-error(Str() $message)

This will send a message at level C<Error> with the supplied
C<message>. It will be sent for dispatch at all applicable levels except
C<Fatal> or C<Off>.

=head2 method log-fatal

        method log-fatal(Str() $message)

This will send a message at level C<Fatal> with the supplied C<message>. It will
always be sent for dispatch except if the applicable level is C<Off>. Despite 
its name the behaviour does not differ from the other levels, if you wish to
actually exit the program you should do this in your own code.

=head1 Lumberjack::Level

This is an enumeration who's values represent the dispatch levels for logging
messages. The naming is vaguely related to those used by C<syslog> and are
suggestive of the frequency and "severity" of the messages (and thus the
kind of use they may have,) but don't imply any particular behaviour, any
specific or particular interpretation is the responsibility of the consumer
of the messages. A dispatcher implementation is of course free to interpret
them as it wishes.

The two "pseudo-levels" C<All> and C<Off> should never be present in a message
but can be used to indicate "get all messages" or "get no messages" respectively.

The descriptions below are typical or suggested but not mandate uses of the
levels.

Listed in decreasing "severity" (which is increasing numeric value,):

=head2 Off

No messages will be sent. 

=head2 Fatal

The most severe and hopefully least frequent messages. This does
not imply any specific behaviour despite its name.

=head2 Error

Messages that should probably receive attention from a human.

=head2 Warn

Events that are unexpected or unwanted but not serious
enough to merit immediate attention.

=head2 Info

This is the default level and should probably be used for all expected
messages that can occur during normal operation.

=head2 Debug

Possibly verbose and detailed messages that will only be of use to
developers.

=head2 Trace

The most high frequency messages.

=head2 All

All messages will be sent.

=head1 Lumberjack::Dispatcher::Console

This is a simple dispatcher implementation that will output directly to
the supplied STDIO handle (by default C<$*ERR>,) Output can be coloured
to reflect the log level of the messages displayed (and you can if wish
alter the colours you use.) As well as the configuration attributes
described below you can set C<classes> and C<levels> as described for
L<Lumberjack::Dispatcher|#Lumberjack::Dispatcher>/

=head2 colour

A boolean "adverb" indicating whether display should be coloured or not.
The default is False (Output is not coloured,)

=head2 handle

This is an IO::Handle to which output will be made, the default is
the STDERR handle C<$*ERR>, but you can use C<$*OUT> or some other
handle opened to a sufficiently display-like device.

=head2 format

This is a format string for the output of the messages, the directives
are described for the subroutine C<format-message> above.  The default
is "%D [%L] %C %S : %M" which outputs: 

   <date> [<Level>] <class> <method> : <message>  

If you supply your own format you probably at least want to use "%M"
to output the text of the message.

=head2 callframes

This is the number of callframes back from the top where the details of
the actual callsite of the logging call that you are interesed in and is
used to find the execution context of the logging message.  The default is
4 which works well for using the L<Lumberjack::Logger|#Lumberjack::Logger>
helper methods, but if you are creating your own Message objects and
find that the subroutine name, line number and file or wrong then you
may want to adjust this.

=head2 colours

This is colour map from the log-level of the message to a colour expressed
as an integer in the range 0x10 .. 0xE7 (from the ANSI 256 colour set,)
the default is roughly what I would expect ranging from Bluish for the
least serious messages to Reddish for the most serious. You are free to
supply your own as a hash keyed on the log level.  If you do so you should
supply all of them.

=head1 Lumberjack::Dispatcher::File

This is a very simple dispatcher implementation that outputs to a file, 
it always appends to the end of the file and offers no facilities for
rotation, truncation or any other things you might expect from a more
sophisticated log appender, it is anticipated that anything with more
features would emerge in the modules ecosystem. 

As well as the configuration attributes below, the C<classes> and
C<levels> of C<Lumberjack::Dispatcher> can be provided when creating
the instance.

=head2 file

This should be the path to the file which will have the log messages
written to, an exception will be thrown if it can't be opened or if
it isn't writeable. The file will be opened in append mode. If this
isn't provided then C<handle> must be.

=head2 handle

This can be provided as an alternative to C<file> and should be an
IO::Handle opened for writing that will be used to write the log
messages, if this is provided it will be preferred to C<file> but
if neither is provided then an exception will be thrown.

=head2 format

This is a format string for the output of the messages, the directives
are described for the subroutine C<format-message> above.  The default
is "%D [%L] %C %S : %M" which outputs: 

   <date> [<Level>] <class> <method> : <message>  

If you supply your own format you probably at least want to use "%M"
to output the text of the message.

=head2 callframes

This is the number of callframes back from the top where the details of
the actual callsite of the logging call that you are interesed in and is
used to find the execution context of the logging message.  The default is
4 which works well for using the L<Lumberjack::Logger|#Lumberjack::Logger>
helper methods, but if you are creating your own Message objects and
find that the subroutine name, line number and file or wrong then you
may want to adjust this.

=end pod

use Staticish;

class Lumberjack is Static {

    class Message { ... };

    has Supplier $!supplier;
    has Supply   $.all-messages;

    enum Level <Off Fatal Error Warn Info Debug Trace All> does role {
        multi method ACCEPTS(Message $m) {
            $m.level == self;
        }
    };

    has Supply $.fatal-messages;
    has Supply $.error-messages;
    has Supply $.warn-messages;
    has Supply $.info-messages;
    has Supply $.debug-messages;
    has Supply $.trace-messages;


    has Level $.default-level is rw = Error;

    class Message {
        has Mu                  $.class;
        has Level               $.level;
        has Backtrace::Frame    @.backtrace;
        has Str                 $.message is required;
        has DateTime            $.when;

        multi method ACCEPTS(Level $l) {
            $!level == $l;
        }

        method Numeric() {
            $!level;
        }

        submethod BUILD(:$!class, Level :$!level, :@!backtrace, Str :$!message!) is hidden-from-backtrace {
            if not $!level.defined {
                $!level = Lumberjack.default-level;
            }
            if not @!backtrace.elems {
                @!backtrace = (Backtrace.new.list);
            }
            $!when = DateTime.now;
        }
        method gist {
            "{$!when} [{ $!level.Str.uc }] { $!message }";
        }

    }

    method log(Message $message) is hidden-from-backtrace {
        $!supplier.emit($message);
    }

    role Logger {
        my Level $level;

        method log-level() returns Level is rw {
            $level;
        }

        proto method log(|c) is hidden-from-backtrace { * }

        multi method log(Message $message) is hidden-from-backtrace {
            Lumberjack.log($message);
        }

        multi method log(Level $level, Str $message) is hidden-from-backtrace {
            my @backtrace = Backtrace.new.list;
            my $class = $?CLASS;
            my $mess = Message.new(:$level, :$message, :@backtrace, :$class);
            samewith $mess;
        }

        method log-trace(Str() $message) is hidden-from-backtrace {
            self.log(Trace, $message);
        }

        method log-debug(Str() $message) is hidden-from-backtrace {
            self.log(Debug, $message);
        }

        method log-info(Str() $message) is hidden-from-backtrace {
            self.log(Info, $message);
        }

        method log-warn(Str() $message) is hidden-from-backtrace {
            self.log(Warn, $message);
        }

        method log-error(Str() $message) is hidden-from-backtrace {
            self.log(Error, $message);
        }

        method log-fatal(Str() $message) is hidden-from-backtrace {
            self.log(Fatal, $message);
        }
    }

    role Dispatcher {
        has Mu $.levels   = Level;
        has Mu $.classes; 

        method log(Message $message) {
            ...
        }
    }

    has Dispatcher @.dispatchers;

    has Supply $.filtered-messages; 

    submethod BUILD() {
        $!supplier       = Supplier.new;
        $!all-messages   = $!supplier.Supply;
        $!fatal-messages = $!all-messages.grep(Fatal);
        $!error-messages = $!all-messages.grep(Error);
        $!warn-messages  = $!all-messages.grep(Warn);
        $!info-messages  = $!all-messages.grep(Info);
        $!debug-messages = $!all-messages.grep(Debug);
        $!trace-messages = $!all-messages.grep(Trace);
        $!filtered-messages = supply {
            whenever $!all-messages -> $m {
                my $filter-level = do if $m.class ~~ Logger {
                    $m.class.log-level;
                }
                else {
                    $!default-level;
                }
                if $m.level <= $filter-level {
                    emit $m;
                }
            }
        }

        $!filtered-messages.tap(-> $message {
            for @!dispatchers -> $dispatcher {
                if ($message.level ~~ $dispatcher.levels) && ($message.class ~~ $dispatcher.classes) {
                    $dispatcher.log($message);
                }
            }
        });
    }

    sub default-date-formatter(DateTime $date-time) returns Str {
        use DateTime::Format::RFC2822;
        DateTime::Format::RFC2822.new.to-string($date-time);
    }

    sub format-message(Str $format, Message $message, :&date-formatter = &default-date-formatter, Int :$callframes) returns Str is export(:FORMAT) {
        my $message-frame = $callframes.defined ?? $message.backtrace[$callframes] !! $message.backtrace[*-1];
        my %expressions =   D => { date-formatter($message.when) },
						    P => { $*PID },
                            C => { $message.class.^name },
                            L => { $message.level.Str },
                            M => { $message.message },
                            N => { $*PROGRAM-NAME },
                            F => { $message-frame.file },
                            l => { $message-frame.line },
                            S => { $message-frame.subname };
        $format.subst(/'%'(<{%expressions.keys}>)/, -> $/ { %expressions{~$0}.() }, :g);
    }

    class Dispatcher::Console does Dispatcher {
        has Bool        $.colour = False;
        has IO::Handle  $.handle = $*ERR;
        has Str         $.format = "%D [%L] %C %S : %M"; 
        has Int         $.callframes = 4;
        has Int         %.colours   = Trace => 23,
                                      Debug => 21,
                                      Info  => 40,
                                      Warn  => 214,
                                      Error => 202,
                                      Fatal => 196;

        method log(Message $message) {
            my $format = $!colour ?? "\e[38;5;{%!colours{$message.level}}m{$!format}\e[0m" !! $!format;
            $!handle.say: format-message($format, $message, callframes => $!callframes);
        }
    }

    class Dispatcher::File does Dispatcher {
        has Str         $.file;
        has IO::Handle  $.handle;
        has Int         $.callframes = 4;
        has Str         $.format = "%D [%L] %C %S : %M"; 

        class X::NoFile is Exception {
            has Str $.message = "One of file or handle must be provided";
        }

        method log(Message $message) {
            if not $!handle.defined {
                if $!file.defined {
                    $!handle = $!file.IO.open(:a);
                }
                else {
                    X::NoFile.new.throw;
                }
            }
            $!handle.say: format-message($!format, $message, callframes => $!callframes);
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
