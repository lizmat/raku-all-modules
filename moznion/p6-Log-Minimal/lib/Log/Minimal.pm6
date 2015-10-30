use v6;
use Terminal::ANSIColor;

unit class Log::Minimal;

our enum LogLevel <MUTE DEBUG INFO WARN CRITICAL ERROR>;

our $colors = {
    INFO     => 'green',
    DEBUG    => 'red on_white',
    WARN     => 'black on_yellow',
    CRITICAL => 'black on_red',
    ERROR    => 'red on_black',
};

has LogLevel $.default-log-level is rw = DEBUG;
has Bool $.escape-whitespace is rw = True;
has Bool $.autodump is rw = False;
has Bool $.color is rw = %*ENV<LM_COLOR> ?? True !! False;
has Str $.env-debug is rw = "LM_DEBUG";
has Int $.default-trace-level is rw = 0;
has Sub $.print is rw; # (DateTime :$time, Str :$messages, Str :$trace); <== not yet implemented...
has Sub $.die is rw; # (DateTime :$time, Str :$messages, Str :$trace); <== not yet implemented...
has Int $.timezone is rw = Nil;

method critf(*@text) {
    self!log(CRITICAL, False, False, @text);
}

method warnf(*@text) {
    self!log(WARN, False, False, @text);
}

method infof(*@text) {
    self!log(INFO, False, False, @text);
}

method debugf(*@text) {
    my Bool $env-debug = %*ENV{$.env-debug} ?? True !! False;
    if $env-debug && DEBUG.value >= $.default-log-level.value {
        self!log(DEBUG, False, False, @text);
    }
}

method errorf(*@text) {
    temp $.default-log-level = DEBUG;
    self!log(ERROR, False, True, @text);
}

method critff(*@text) {
    self!log(CRITICAL, True, False, @text);
}

method warnff(*@text) {
    self!log(WARN, True, False, @text);
}

method infoff(*@text) {
    self!log(INFO, True, False, @text);
}

method debugff(*@text) {
    my Bool $env-debug = %*ENV{$.env-debug} ?? True !! False;
    if $env-debug && DEBUG.value >= $.default-log-level.value {
        self!log(DEBUG, True, False, @text);
    }
}

method errorff(*@text) {
    temp $.default-log-level = DEBUG;
    self!log(ERROR, True, True, @text);
}

method !log(LogLevel $log-level, Bool $full-trace, Bool $die, *@text) {
    if $.default-log-level.value == 0 || $log-level.value < $.default-log-level.value {
        # NOP: disabled by log level
        return;
    }

    my $time;
    if $.timezone.defined {
        $time = DateTime.now(:timezone($.timezone));
    } else {
        $time = DateTime.now;
    }

    my $trace = '';
    if $full-trace {
        my @bts = ();
        my $i = $.default-trace-level + 4;
        loop {
            my $bt = callframe($i++);
            @bts.push($bt);
        }
        CATCH {
            when 'ctxcaller needs an MVMContext' {
                $trace = 'at ' ~ @bts[0..*-2].map(-> $bt {sprintf('%s line %s', $bt.file, $bt.line)}).join(', ');
            }
        }
    } else {
        my $bt = callframe($.default-trace-level + 3);
        $trace = sprintf('at %s line %s', $bt.file, $bt.line);
    }

    my $messages = '';
    if (@text == 1 && defined @text[0]) {
        $messages ~= $.autodump ?? @text[0].perl !! @text[0];
    } elsif (@text >= 2)  {
        $messages = sprintf(@text.shift, $.autodump ?? map { .perl }, @text !! @text);
    }

    if ($.escape-whitespace) {
        $messages = $messages.subst(/\x0d/, '\r', :g);
        $messages = $messages.subst(/\x0a/, '\n', :g);
        $messages = $messages.subst(/\x09/, '\t', :g);
    }

    if ($.color) {
        $messages = colored($messages, $colors{$log-level.key});
    }

    if ($die) {
        self!die(:$time, :$log-level, :$messages, :$trace);
    } else {
        self!print(:$time, :$log-level, :$messages, :$trace);
    }
}

our class Log::Minimal::Error is Exception {
    has Str $.message;
    has DateTime $.time;
    has LogLevel $.log-level;
    has Str $.messages;
    has Str $.trace;

    method new(DateTime :$time, LogLevel :$log-level, Str :$messages, Str :$trace) {
        return self.bless(
            time      => $time,
            log-level => $log-level,
            messages  => $messages,
            trace     => $trace,
            message   => "$time [$log-level] $messages $trace",
        );
    }

    method message(Exception:D:) returns Str:D {
        return $!message;
    }

    method backtrace(Exception:D:) returns Backtrace:D {
        return Backtrace.new();
    }
}

method !print(DateTime :$time, LogLevel :$log-level, Str :$messages, Str :$trace) {
    if $.print {
        $.print.(:$time, :$log-level, :$messages, :$trace);
        return;
    }

    note "$time [$log-level] $messages $trace";
}

method !die(DateTime :$time, LogLevel :$log-level, Str :$messages, Str :$trace) {
    if $.die {
        $.die.(:$time, :$log-level, :$messages, :$trace);
        return;
    }

    Log::Minimal::Error.new(:$time, :$log-level, :$messages, :$trace).die;
}

=begin pod

=head1 NAME

Log::Minimal - Minimal and customizable logger for perl6

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Log::Minimal is a minimal and customizable logger for perl6.
This logger provides logging functions  according to logging level with line (or stack) trace.

This package is perl6 port of Log::Minimal of perl5.

=head1 METHODS

=head2 critf(Log::Minimal:D: ($message:Str|$format:Str, *@list));

  $log.critf("could't connect to example.com");
  $log.critf("Connection timeout timeout:%d, host:%s", 2, "example.com");

Display CRITICAL messages.
When two or more arguments are passed to the method,
the first argument is treated as a format of sprintf.

=head2 warnf(Log::Minimal:D: ($message:Str|$format:Str, *@list));

Display WARN messages.

=head2 infof(Log::Minimal:D: ($message:Str|$format:Str, *@list));

Display INFO messages.

=head2 debugf(Log::Minimal:D: ($message:Str|$format:Str, *@list));

Display DEBUG messages, if %*ENV<LM_DEBUG> is true value.

=head2 critff(Log::Minimal:D: ($message:Str|$format:Str, *@list));

  $log.critff("could't connect to example.com");
  $log.critff("Connection timeout timeout:%d, host:%s", 2, "example.com");

Display CRITICAL messages with stack trace.

=head2 warnff(Log::Minimal:D: ($message:Str|$format:Str, *@list));

Display WARN messages with stack trace.

=head2 infoff(Log::Minimal:D: ($message:Str|$format:Str, *@list));

Display INFO messages with stack trace.

=head2 debugff(Log::Minimal:D: ($message:Str|$format:Str, *@list));

Display DEBUG messages with stack trace, if %*ENV<LM_DEBUG> is true value.

=head2 errorf(Log::Minimal:D: ($message:Str|$format:Str, *@list));

die with formatted $message

  $log.errorf("critical error");

=head2 errorff(Log::Minimal:D: ($message:Str|$format:Str, *@list));

die with formatted $message with stack trace

=head1 CUSTOMIZATION

=head2 C<%*ENV<LM_DEBUG>> and C<$.env-debug>

%*ENV<LM_DEBUG> must be true if you want to print debugf and debugff messages.

You can change variable name from LM_DEBUG to arbitrary string which is specified by C<$.env-debug> in use instance.

  use Log::Minimal;

  my $log = Log::Minimal.new(:env-debug('FOO_DEBUG'));

  %*ENV<LM_DEBUG>  = True;
  %*ENV<FOO_DEBUG> = False;
  $log.debugf("hello"); # no output

  %*ENV<FOO_DEBUG> = True;
  $log.debugf("world"); # print message

=head2 C<%*ENV<LM_COLOR>> and C<$.color>

C<%*ENV<LM_COLOR>> is used as default value of C<$.color>. If you want to colorize logging message, you specify true value into C<%*ENV<LM_COLOR>> or C<$.color> of instance.

  use Log::Minimal;

  my $log = Log::Minimal.new;
  %*ENV<LM_COLOR>  = True;
  $log.infof("hello"); # output colorized message

or

  use Log::Minimal;

  my $log = Log::Minimal.new;
  $log.color = True;
  $log.infof("hello"); # output colorized message

=head2 C<$.print>

To change the method of outputting the log, set C<$.print> of instance.

  my $log = Log::Minimal.new;
  $log.print = sub (:$time, :$log-level, :$messages, :$trace) {
      note "[$log-level] $messages $trace"; # without time stamp
  }
  $log.critf('foo'); # [CRITICAL] foo at example.p6 line 12;

default is

  sub (:$time, :$log-level, :$messages, :$trace) {
      note "$time [$log-level] $messages $trace";
  }

=head2 C<$.die>

To change the format of die message, set C<$.die> of instance.

  my $log = Log::Minimal.new;
  $log.print = sub (:$time, :$log-level, :$messages, :$trace) {
      die "[$log-level] $messages"; # without time stamp and trace
  }
  $log.errorf('foo');

default is

  sub (:$time, :$log-level, :$messages, :$trace) {
      Log::Minimal::Error.new(message => "$time [$log-level] $messages $trace").die;
  }

=head2 C<$.default-log-level>

Level for output log.

  my $log = Log::Minimal.new;
  $log.default-log-level = Log::Minimal::WARN;
  $log.infof("foo"); # print nothing
  $log.warnf("foo"); # print

Support levels are DEBUG, INFO, WARN, CRITICAL, Error and MUTE. These levels are exposed by enum (e.g. Log::Minimal::DEBUG).
If MUTE is set, no output except C<errorf> and C<errorff>.
Default log level is DEBUG.

=head2 C<$.autodump>

Serialize message with C<.perl>.

  my $log = Log::Minimal.new;
  $log.warnf("%s", {foo => 'bar'}); # foo\tbar

  temp $log.autodump = True;
  warnf("dump is %s", {foo=>'bar'}); # :foo("bar")

=head2 C<$.default-trace-level>

This variable determines how many additional call frames are to be skipped.
Defaults to 0.

=head2 C<$.escape-whitespace>

If this value is true, whitespace other than space will be represented as [\n\t\r].
Defaults to True.

=head2 C<$.timezone>

Default, this value is Nil means Log::Minimal determines timezone automatically
from your environment.

If you specify this value, Log::Minimal uses that timezone.

  my $timezone = DateTime.new('2015-12-24T12:23:00+0900').timezone; # <= 32400
  my $log = Log::Minimal.new(:$timezone);
  $log.critff("%s","foo"); # 2010-10-20T00:25:17+09:00 [CRITICAL] foo at lib/Example.pm6 line 10, example.p6 line 12

=head1 SEE ALSO

L<Log::Minimal of perl5|https://metacpan.org/pod/Log::Minimal>

=head1 COPYRIGHT AND LICENSE

    Copyright 2015 moznion <moznion@gmail.com>

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

And original perl5's Log::Minimal is

    This software is copyright (c) 2013 by Masahiro Nagano <kazeburo@gmail.com>.

    This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=end pod

