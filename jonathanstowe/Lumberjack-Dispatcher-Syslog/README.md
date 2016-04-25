# Lumberjack::Dispatcher::Syslog

A Syslog dispatcher for the Lumberjack logger

[![Build Status](https://travis-ci.org/jonathanstowe/Lumberjack-Dispatcher-Syslog.svg?branch=master)](https://travis-ci.org/jonathanstowe/Lumberjack-Dispatcher-Syslog)

## Synopsis

```perl6

    use Lumberjack;
    use Lumberjack::Dispatcher::Syslog;

    # Add the syslog dispatcher
    Lumberjack.dispatchers.append: Lumberjack::Dispatcher::Syslog.new;

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

```

## Description

This provides a dispatcher for
[Lumberjack](https://github.com/jonathanstowe/Lumberjack) which allows
you to log to your system's `syslog` facility, this may log to various
log files in, for instance, `/var/log` depending on the configuration
of the syslog daemon. Because the actual logging daemon being used
may differ from system to system (there is syslog-ng, rsyslog, syslog
"classic" etc,) you will need to refer to the local documentation or
a system administrator to determine the actual logging behaviour. Some
systems may for instance just drop "debug" or "trace" messages in the
default configuration (or put them in separate files.)

## Installation

Assuming you have got a working installation of Rakudo perl 6 you
should be able to install this with panda:

    panda install Lumberjack::Dispatcher::Syslog

Or if you have a local clone of the code:

    panda install .

Though I haven't tested with it, I see no reason that "zef" or any other
installer that may come along shouldn't work equally well.

## Support

This in itself is very simple, it is likely that the configuration of
the syslog itself is more of a challenge and you should refer to the
configuration or documentation of the local syslog installation in
the first instance if things aren't being logged as you expect. You
may also want to check the documentation for Lumberjack itself as
well as Log::Syslog::Native which this uses to send the messages.

If you have any problems or suggestions for the module itself then
please feel free to post at https://github.com/jonathanstowe/Lumberjack-Dispatcher-Syslog/issues

## License and copyright

This is free software. Please see the LICENSE file in the repository.

	© Jonathan Stowe, 2016

