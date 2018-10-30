[![Build Status](https://travis-ci.org/moznion/p6-Log-Minimal.svg?branch=master)](https://travis-ci.org/moznion/p6-Log-Minimal)

NAME
====

Log::Minimal - Minimal and customizable logger for perl6

SYNOPSIS
========

    use Log::Minimal;
    my $log = Log::Minimal.new;

    $log.critf('foo'); # 2010-10-20T00:25:17Z [CRITICAL] foo at example.p6 line 12;
    $log.warnf("%d %s %s", 1, "foo", $uri);
    $log.infof('foo');
    $log.debugf("foo"); # print if %*ENV<LM_DEBUG> is true value

    # with full stack trace
    $log.critff("%s","foo"); # 2010-10-20T00:25:17Z [CRITICAL] foo at lib/Example.pm6 line 10, example.p6 line 12
    $log.warnff("%d %s %s", 1, "foo", $uri);
    $log.infoff('foo');
    $log.debugff("foo"); # print if %*ENV<LM_DEBUG> is true value

    # die with formatted message
    $log.errorf('foo');
    $log.errorff('%s %s', $code, $message);

DESCRIPTION
===========

Log::Minimal is a minimal and customizable logger for perl6. This logger provides logging functions according to logging level with line (or stack) trace.

This package is perl6 port of Log::Minimal of perl5.

METHODS
=======

critf(Log::Minimal:D: ($message:Str|$format:Str, *@list));
----------------------------------------------------------

    $log.critf("could't connect to example.com");
    $log.critf("Connection timeout timeout:%d, host:%s", 2, "example.com");

Display CRITICAL messages. When two or more arguments are passed to the method, the first argument is treated as a format of sprintf.

warnf(Log::Minimal:D: ($message:Str|$format:Str, *@list));
----------------------------------------------------------

Display WARN messages.

infof(Log::Minimal:D: ($message:Str|$format:Str, *@list));
----------------------------------------------------------

Display INFO messages.

debugf(Log::Minimal:D: ($message:Str|$format:Str, *@list));
-----------------------------------------------------------

Display DEBUG messages, if %*ENLM_DEBUG is true value.

critff(Log::Minimal:D: ($message:Str|$format:Str, *@list));
-----------------------------------------------------------

    $log.critff("could't connect to example.com");
    $log.critff("Connection timeout timeout:%d, host:%s", 2, "example.com");

Display CRITICAL messages with stack trace.

warnff(Log::Minimal:D: ($message:Str|$format:Str, *@list));
-----------------------------------------------------------

Display WARN messages with stack trace.

infoff(Log::Minimal:D: ($message:Str|$format:Str, *@list));
-----------------------------------------------------------

Display INFO messages with stack trace.

debugff(Log::Minimal:D: ($message:Str|$format:Str, *@list));
------------------------------------------------------------

Display DEBUG messages with stack trace, if %*ENLM_DEBUG is true value.

errorf(Log::Minimal:D: ($message:Str|$format:Str, *@list));
-----------------------------------------------------------

die with formatted $message

    $log.errorf("critical error");

errorff(Log::Minimal:D: ($message:Str|$format:Str, *@list));
------------------------------------------------------------

die with formatted $message with stack trace

CUSTOMIZATION
=============

`%*ENV<LM_DEBUG>` and `$.env-debug`
-----------------------------------

%*ENLM_DEBUG must be true if you want to print debugf and debugff messages.

You can change variable name from LM_DEBUG to arbitrary string which is specified by `$.env-debug` in use instance.

    use Log::Minimal;

    my $log = Log::Minimal.new(:env-debug('FOO_DEBUG'));

    %*ENV<LM_DEBUG>  = True;
    %*ENV<FOO_DEBUG> = False;
    $log.debugf("hello"); # no output

    %*ENV<FOO_DEBUG> = True;
    $log.debugf("world"); # print message

`%*ENV<LM_COLOR>` and `$.color`
-------------------------------

`%*ENV<LM_COLOR>` is used as default value of `$.color`. If you want to colorize logging message, you specify true value into `%*ENV<LM_COLOR>` or `$.color` of instance.

    use Log::Minimal;

    my $log = Log::Minimal.new;
    %*ENV<LM_COLOR>  = True;
    $log.infof("hello"); # output colorized message

or

    use Log::Minimal;

    my $log = Log::Minimal.new;
    $log.color = True;
    $log.infof("hello"); # output colorized message

`$.print`
---------

To change the method of outputting the log, set `$.print` of instance.

    my $log = Log::Minimal.new;
    $log.print = sub (:$time, :$log-level, :$messages, :$trace) {
        note "[$log-level] $messages $trace"; # without time stamp
    }
    $log.critf('foo'); # [CRITICAL] foo at example.p6 line 12;

default is

    sub (:$time, :$log-level, :$messages, :$trace) {
        note "$time [$log-level] $messages $trace";
    }

`$.die`
-------

To change the format of die message, set `$.die` of instance.

    my $log = Log::Minimal.new;
    $log.print = sub (:$time, :$log-level, :$messages, :$trace) {
        die "[$log-level] $messages"; # without time stamp and trace
    }
    $log.errorf('foo');

default is

    sub (:$time, :$log-level, :$messages, :$trace) {
        Log::Minimal::Error.new(message => "$time [$log-level] $messages $trace").die;
    }

`$.default-log-level`
---------------------

Level for output log.

    my $log = Log::Minimal.new;
    $log.default-log-level = Log::Minimal::WARN;
    $log.infof("foo"); # print nothing
    $log.warnf("foo"); # print

Support levels are DEBUG, INFO, WARN, CRITICAL, Error and MUTE. These levels are exposed by enum (e.g. Log::Minimal::DEBUG). If MUTE is set, no output except `errorf` and `errorff`. Default log level is DEBUG.

`$.autodump`
------------

Serialize message with `.perl`.

    my $log = Log::Minimal.new;
    $log.warnf("%s", {foo => 'bar'}); # foo\tbar

    temp $log.autodump = True;
    warnf("dump is %s", {foo=>'bar'}); # :foo("bar")

`$.default-trace-level`
-----------------------

This variable determines how many additional call frames are to be skipped. Defaults to 0.

`$.escape-whitespace`
---------------------

If this value is true, whitespace other than space will be represented as [\n\t\r]. Defaults to True.

`$.timezone`
------------

Default, this value is Nil means Log::Minimal determines timezone automatically from your environment.

If you specify this value, Log::Minimal uses that timezone.

    my $timezone = DateTime.new('2015-12-24T12:23:00+0900').timezone; # <= 32400
    my $log = Log::Minimal.new(:$timezone);
    $log.critff("%s","foo"); # 2010-10-20T00:25:17+09:00 [CRITICAL] foo at lib/Example.pm6 line 10, example.p6 line 12

SEE ALSO
========

[Log::Minimal of perl5](https://metacpan.org/pod/Log::Minimal)

COPYRIGHT AND LICENSE
=====================

    Copyright 2015 moznion <moznion@gmail.com>

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

And original perl5's Log::Minimal is

    This software is copyright (c) 2013 by Masahiro Nagano <kazeburo@gmail.com>.

    This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
