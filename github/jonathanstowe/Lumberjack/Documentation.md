NAME
====

Lumberjack - A simple logging framework.

SYNOPSIS
========

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

DESCRIPTION
===========

This is more of a sketch for a logging framework, or perhaps even a logging framework framework. It provides the minimum interface that classes can consume a role to provide themselves logging facilities and set a class wide logging level and have the messages delivered to dispatchers which can do what they want with the messages and specify the levels of messages that they want to handle.

It doesn't mandate any particular configuration format as the setup is entirely programmatic, I foresee that people providing their own higher level configuration driven things on top of this.

I'm sure this doesn't yet have all the features to support all the requirements people, but it is released with the basic interface complete so it can actually be used.

The approach taken reflects a patten that I have found useful in large object oriented programmes, where having the logging methods on a class means that you have the means to make log messages wherever you have an instance of the class without having to obtain a separate logger object.

There are a couple of simple log dispatchers included which should get you started, but I would envisage that more useful ones may be provided as separate modules, though they are sufficiently simple to implement you can provide your own as required.

METHODS
=======

The main `Lumberjack` class operates as if all the methods and attributes are 'static', that is to say they are wrapped under the hood to be invoked against a single instance that is created the first time it is needed. 

method log
----------

    method log(Message $message)

This injects the [Lumberjack::Message](#Lumberjack::Message) into the dispatch mechanism, it is typically called by the methods provided by the role [Lumberjack::Logger](#Lumberjack::Logger) though you may call this directly if you wish to create your own message and/or dispatch  the message outside of any particular class.

all-messages
------------

This is a Supply that reflects all of the messages that traverse the system, before they are filtered for dispatch. In normal usage this is used internally to feed the dispatch mechanism, but can be tapped to provide a feed for an external logging mechanism for instance.

fatal-messages
--------------

This is a Supply derived from `all-messages` that only has the messages at level `Fatal`.

error-messages
--------------

This is a Supply derived from `all-messages` that only has the messages at level `Error`.

warn-messages
-------------

This is a Supply derived from `all-messages` that only has the messages at level `Warn`.

info-messages
-------------

This is a Supply derived from `all-messages` that only has the messages at level `Info`.

debug-messages
--------------

This is a Supply derived from `all-messages` that only has the messages at level `Debug`.

trace-messages
--------------

This is a Supply derived from `all-messages` that only has the messages at level `Trace`.

filtered-messages 
------------------

This is a Supply that is filtered to be only those that will be candidates for dispatch. To be a candidate the `level` of the message must be  equal to or of higher "severity" (lower numerical value,) than the `log-level` of the class the message is for, or (if the class is unknown,) the  `default-log-level`. This is tapped internally to feed the dispatchers, but you could tap this yourself if you want to send the filtered messages to an alternative logging system.

default-log-level
-----------------

This is the default level that is used to filter the messages when the class of the message is unknown (or has no level set.) It may also be used to set a default on new messages when the level isn't supplied (but this is almost certainly not what you want to do.) The default is `Info`.

dispatchers
-----------

This is an Array of objects that have the role [Lumberjack::Dispatcher](#Lumberjack::Dispatcher) role. These should be object instances and not names or type objects. The rationale behind making them objects rather than types is so that multiple dispatchers of the same type can be used with a different configuration each handling messages for different log levels or for different classes. An example might be a dispatcher that writes to a file, where an instance might log `Debug` messages to a `debug.log` and a separate instance logs the `Error` messages to an `error.log`.

sub format-message
------------------

    sub format-message(Str $format, Message $message, :&date-formatter = &default-date-formatter, Int :$callframes) returns Str is export(:FORMAT)

This is a utility subroutine that is only exported when the `:FORMAT` import adverb is applied to the use of `Lumberjack` It provides a simple formatting of the messages with `sprintf` like directives supplied in `$format`. `$callframes` indicates the number of frames to be skipped in the backtrace to find the frame we are interested in. `&date-formatter` is a subroutine that accepts a DateTime and returns a formatted string (the default is RFC2822-like.) The Format directives are:

### %D

The formatted date, using the provided date-formatter or the default.

### %P

The Process ID of this process.

### %C

The class name of the the class from the Message.

### %L

The logging level of the message.

### %M

The text of the message.

### %N

The program name.

### %N

The current file, derived from the backtrace (thus `$callframes` may need adjustment)

### %l

The line number in the current file, derived from the backtrace.

### %S

The current subroutine or method name, derived from the backtrace.

Lumberjack::Message
===================

Objects of this class represent the messages that are passing through the logger, in the simplest case where one is using the methods provided by the role [Lumberjack::Logger](#Lumberjack::Logger) then these objects will be created for you with sensible defaults. You are free to create them yourself if you want other values than the defaults or you can sub-class to provide different attributes if you have different requirements and the dispatchers that you are using would make use of them.

The messages themselves contain the information required to determine whether they will becomes candidates for dispatch and select which  dispatchers (if any,) they will be sent to.

The messages can be smart matched against items of the enum [Lumberjack::Level](#Lumberjack::Level).

class
-----

This is the type object of the class that the message is for and will be populated by the logging methods of the [Lumberjack::Logger](#Lumberjack::Logger) role. If it is populated it will be used in two ways. firstly if it is a `Lumberjack::Logger` the `log-level` "class method" will be used to determine whether the message should be dispatched, that is if the level of the message is of a higher or equal "severity" than the `log-level`  it will be dispatched, secondly it will be used to select which dispatchers it will be handed to by smart matching against the `classes` of the dispatcher.

level
-----

This is the [Lumberjack::Level](#Lumberjack::Level) representing the level or severity of the message, it will be checked against the `log-level` of `class` if available, or the `default-log-level` to determine whether the message should be a candidate for dispatch. If this is not provided to the constructor for the message object then it will be set to the `default-log-level` which is probably not what you want. The helpers in [Lumberjack::Logger](#Lumberjack::Logger) take care of that for you however.

backtrace
---------

This is a Backtrace object that represents the execution context when the log message is constructed, it can be used by the dispatcher to provide information about the call site. It will be populated for you when the message is created, however if you are sending a  message, for example, about a caught exception you can supply a backtrace that came from elsewhere (though you may need to adjust the frames that the dispatcher examines accordingly.)

message
-------

This is the only required field of the message that there is no default for, and represents the free text payload of the log message.

when
----

This is the DateTime when the Message was created, a dispatcher is free to use this in generating a log entry.

Lumberjack::Dispatcher
======================

This is role that must be consumed by your dispatcher classes, it defines the interface for dispatch and for the selection of the the messages that is will handle. The actual dispatchers should be instances of your classes and can have any configuration required for them to work.

There are two simple dispatcher classes provided in the module  and others might be found in the module ecosystem.

Whilst you are free to implement the dispatcher however you wish you should bear in mind that if you require a `BUILD` method and wish to populate the `levels` and `classes` attributes then you have to provide for them in your signaturem such as:

        submethod BUILD(:$my-parameter, :$!classes, :$!levels) {
            ...
        }

This is unfortunately necessary because a default BUILD for the role won't be called if a class provides one.

method log
----------

    method log(Message $message)

This is stubbed in the role and `must` be provided by a composing class. It is provided with the selected messages and is entirely free to do whatever it wants to implement.

levels
------

The value of this attribute is smart matched against the `level` attribute of a message to determine whether this dispatcher should receive it, it can be a single value of [Lumberjack::Level](#Lumberjack::Level), an `any` Junction of one or more of those values, a subroutine that will take a level as an argument an return a Bool or any other object that will smart match against a `level`. The default is `Any`.

classes
-------

The value of this attribute is smart matched against the `class` attribute of a message to determine (along with the matching of level,) whether this dispatcher should receive it. It can be a class type object, a Junction of one or more type objects, a subroutine that will take the type object as an argument and return a Bool or anything else that could conceivably smart match a class type object.

Lumberjack::Logger
==================

This is role that provides a convenient interface to the logging functionality that can be consumed by any class. The advantage of using the role rather than accessing the `log` method of `Lumberjack` directly is that you don't need to worry about constructing the message and so forth.

method log-level
----------------

    method log-level() returns Level is rw

This is a "class method" (that is setting the value will apply to all instances of the class,) it is the value that is compared to the `level` of a message to determine whether the message that should be dispatched (contingent of course on there being a suitable dispatcher that would accept it.) Two special values of [Lumberjack::Level](#Lumberjack::Level) are provided which may be used here as well as the standard values: `All` which will cause all messages to be dispatched, and `Off` which will cause no messages to be dispatched whatever the severity.

method log
----------

    multi method log(Message $message)
    multi method log(Level $level, Str $message)

This method sends a message to be considered for dispatch. They may be suitable if, for example, the `level` of the method needs to be calculated or the message is actually being sent on behalf of some other object or process. For most cases however the level specific helpers will probably be more convenient.

method log-trace
----------------

    method log-trace(Str() $message)

This will send a message at level `Trace` with the the supplied `message`. It will be sent for dispatch if the applicable `log-level` is `All` or `Trace`.

method log-trace
----------------

    method log-debug(Str() $message)

This will send a message at level `Debug` with the supplied `message` it will be sent for dispatch if the applicable `log-level` is `Debug`¸ `Trace` or `All`.

method log-info
---------------

    method log-info(Str() $message)

This will send a message at level `Info` with the supplied `message`. It will be sent for dispatch if the applicable `log-level` is `Info`, `Debug`, `Trace` or `All`.

method log-warn
---------------

    method log-warn(Str() $message)

This will send a message at level `Warn` with the supplied `message`. It will be sent for dispatch at levels `Warn`, `Info`, `Debug`, `Trace` or `All`.

method log-error
----------------

    method log-error(Str() $message)

This will send a message at level `Error` with the supplied `message`. It will be sent for dispatch at all applicable levels except `Fatal` or `Off`.

method log-fatal
----------------

    method log-fatal(Str() $message)

This will send a message at level `Fatal` with the supplied `message`. It will always be sent for dispatch except if the applicable level is `Off`. Despite  its name the behaviour does not differ from the other levels, if you wish to actually exit the program you should do this in your own code.

Lumberjack::Level
=================

This is an enumeration who's values represent the dispatch levels for logging messages. The naming is vaguely related to those used by `syslog` and are suggestive of the frequency and "severity" of the messages (and thus the kind of use they may have,) but don't imply any particular behaviour, any specific or particular interpretation is the responsibility of the consumer of the messages. A dispatcher implementation is of course free to interpret them as it wishes.

The two "pseudo-levels" `All` and `Off` should never be present in a message but can be used to indicate "get all messages" or "get no messages" respectively.

The descriptions below are typical or suggested but not mandate uses of the levels.

Listed in decreasing "severity" (which is increasing numeric value,):

Off
---

No messages will be sent. 

Fatal
-----

The most severe and hopefully least frequent messages. This does not imply any specific behaviour despite its name.

Error
-----

Messages that should probably receive attention from a human.

Warn
----

Events that are unexpected or unwanted but not serious enough to merit immediate attention.

Info
----

This is the default level and should probably be used for all expected messages that can occur during normal operation.

Debug
-----

Possibly verbose and detailed messages that will only be of use to developers.

Trace
-----

The most high frequency messages.

All
---

All messages will be sent.

Lumberjack::Dispatcher::Console
===============================

This is a simple dispatcher implementation that will output directly to the supplied STDIO handle (by default `$*ERR`,) Output can be coloured to reflect the log level of the messages displayed (and you can if wish alter the colours you use.) As well as the configuration attributes described below you can set `classes` and `levels` as described for [Lumberjack::Dispatcher](#Lumberjack::Dispatcher)/

colour
------

A boolean "adverb" indicating whether display should be coloured or not. The default is False (Output is not coloured,)

handle
------

This is an IO::Handle to which output will be made, the default is the STDERR handle `$*ERR`, but you can use `$*OUT` or some other handle opened to a sufficiently display-like device.

format
------

This is a format string for the output of the messages, the directives are described for the subroutine `format-message` above. The default is "%D [%L] %C %S : %M" which outputs: 

    <date> [<Level>] <class> <method> : <message>

If you supply your own format you probably at least want to use "%M" to output the text of the message.

callframes
----------

This is the number of callframes back from the top where the details of the actual callsite of the logging call that you are interesed in and is used to find the execution context of the logging message. The default is 4 which works well for using the [Lumberjack::Logger](#Lumberjack::Logger) helper methods, but if you are creating your own Message objects and find that the subroutine name, line number and file or wrong then you may want to adjust this.

colours
-------

This is colour map from the log-level of the message to a colour expressed as an integer in the range 0x10 .. 0xE7 (from the ANSI 256 colour set,) the default is roughly what I would expect ranging from Bluish for the least serious messages to Reddish for the most serious. You are free to supply your own as a hash keyed on the log level. If you do so you should supply all of them.

Lumberjack::Dispatcher::File
============================

This is a very simple dispatcher implementation that outputs to a file,  it always appends to the end of the file and offers no facilities for rotation, truncation or any other things you might expect from a more sophisticated log appender, it is anticipated that anything with more features would emerge in the modules ecosystem. 

As well as the configuration attributes below, the `classes` and `levels` of `Lumberjack::Dispatcher` can be provided when creating the instance.

file
----

This should be the path to the file which will have the log messages written to, an exception will be thrown if it can't be opened or if it isn't writeable. The file will be opened in append mode. If this isn't provided then `handle` must be.

handle
------

This can be provided as an alternative to `file` and should be an IO::Handle opened for writing that will be used to write the log messages, if this is provided it will be preferred to `file` but if neither is provided then an exception will be thrown.

format
------

This is a format string for the output of the messages, the directives are described for the subroutine `format-message` above. The default is "%D [%L] %C %S : %M" which outputs: 

    <date> [<Level>] <class> <method> : <message>

If you supply your own format you probably at least want to use "%M" to output the text of the message.

callframes
----------

This is the number of callframes back from the top where the details of the actual callsite of the logging call that you are interesed in and is used to find the execution context of the logging message. The default is 4 which works well for using the [Lumberjack::Logger](#Lumberjack::Logger) helper methods, but if you are creating your own Message objects and find that the subroutine name, line number and file or wrong then you may want to adjust this.
