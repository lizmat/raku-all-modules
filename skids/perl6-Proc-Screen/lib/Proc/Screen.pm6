=NAME Proc::Screen:: - create and/or manipulate GNU screen sessions

=begin SYNOPSIS
=begin code

  use Proc::Screen;

  # Start a new screen session
  my $s = Proc::Screen.new();
  $s.start;

  # Send a command to the session (this one dumps a screenshot to a file)
  $s.command("hardcopy","/tmp/foobar.txt");

  # Query for information about the session syncronously
  $s.query("info").say;

  # Query for information about the session asyncronously
  my $out;
  $s.query("info", :$out).then({ "Screen info: $out".say });

=end code
=end SYNOPSIS

#| Each instance of Proc::Screen corresponds to one screen "session."
unit class Proc::Screen:auth<skids>:ver<0.0.1> is Proc::Async;

use File::Temp;

my %tokill;
my Lock $tokill_lock;
BEGIN { # Because --doc runs END }
  $tokill_lock = Lock.new;
}
# TODO: make this a rw proxy that does a fixup on %tokill
has $.remain = False; # Leave the session running after we exit

sub close-all {
  $tokill_lock.protect: {
    for %tokill.kv -> $session-id, ($path, $remain) {
      run $path, '-q', '-S', "$session-id", '-X', 'quit'
        unless $remain;
    }
    # Also clean up any "dead" sessions
    for %tokill.kv -> $session-id, ($path, $remain) {
      run $path, '-q', '-wipe', "$session-id"
        unless $remain;
    }
    # TODO: handle any zombie problems or whatnot
  }
}

END { close-all }

# It turns out there is no clean way to do this.
#
# We run "screen -d -m" which disowns, leaving us no idea of the eventual PID,
# which is part of the name we need to later manipulate the session.  So, we
# hijack the .screenrc using the -c commandline option, and send some commands
# to get the $PID from screen's environment, put it in screen's paste buffer
# and from there dump it into a temporary file, from which we can read it.
#
# TODO: tighten up security on the tempfile if File::Temp starts to offer
# options in that area.

has $!pro; # The promise returned by the latest Proc::Async .start
           # or the result thereof.  Keeps track of whether we have
           # an "in flight" screen command.

has $.screen-pid; # The PID that eventually is used for session naming

has Str $.sessionname;   # Something to make our sessions stand out

# XXX for some reason, things blow up when rcfh or pidfh are made private
has Str $.rcfn;          # Our adhoc rcfile, until it is no longer needed
has IO::Handle $.rcfh;     

has Str $.pidfn;         # Screen hands us its PID via this file
has IO::Handle $.pidfh;    

# Emulates the logic to find the right .screenrc, hopefully well enough.
# If you alter C<:rc> you may want to use this to pull in the normal
# screenrc at the appropriate point with a "source" command.
method screenrc(::?CLASS:U:) {
  %*ENV<SCREENRC> // $*SPEC.catdir(%*ENV<HOME>, ".screenrc");
}
has @.rc; # lines of screenrc stored in a temporary file and passed via -c

# The command to pass as the shell on the screen commandline
# ("shell" in @.rc can also be used but does not take arguments.)
has @.shell;

# TODO: serial line tty and "telnet" window types though seriously
# who uses telnet anymore.

#| Plan a new screen session.  This does not start it.
#| Except for C<:path> and C<:args> all C<Proc::Async> attributes are accepted
method new(::?CLASS:U: *%iv is copy) {
  die ":args is not user-settable in Proc::Screen" if %iv<args>:exists;
  %iv<path> = "screen" unless %iv<path>:exists;
  %iv<sessionname> //= "Proc::Screen";

  # Set up files to trampoline the screenrc and to receive the PID
  # XXX File::Temp might want to consider GLRization of return values
  %iv<rcfn rcfh pidfn pidfh> = |tempfile, |tempfile;
  %iv<rc> //= ("source " ~ ::?CLASS.screenrc(),);

  # Inject commands to get the PID, so we can match the session
  %iv<rcfh>.print(sprintf(Q:to<EORC>, %iv<pidfn>, %iv<rc>.join("\n")));
    eval 'register . "$PID"' 'writebuf %s' 'register . ""'
    %s
    EORC
  %iv<args> := [ '-q', '-c', %iv<rcfn>, '-S', %iv<sessionname>,
                 '-d', '-m', |(%iv<shell> with %iv<shell>) ];
  nextwith(|%iv);
}

#| Starts the command to start the planned screen session.  Does not wait.
method start (::?CLASS:D:) {
  fail "Tried to .start {self.WHAT.^name} which was already started"
    if $!pro.defined;
  # Begin to watch the file where the PID will get dumped.
  $!screen-pid = $!pidfh.watch.head(1).Promise.then: -> $res {
    if $res.result.WHAT === IO::Notification::Change {
      $!screen-pid = $!pidfh.slurp-rest;
      self.clean-old-files;
      if $!screen-pid.chars {
        $tokill_lock.protect: {
          %tokill{"$!screen-pid.$.sessionname"} = ( $.path, $.remain );
        }
      }
    }
    else {
      die("Did not expect this");
    }
  }
  $!pro = callsame;
}

#| Waits for "screen" to finish executing.  If the session has just
#| been started, also waits until its process ID is known.  Note
#| that this only means the "screen" executable has finished, not
#| that the session has finished processing any commands that were sent.
method await-ready (::?CLASS:D:) {
  fail "Must .start {::?CLASS.^name} before using it."
    unless $!pro.defined;

  # Wait for completion of the last invocation of screen.
  if $!pro ~~ Promise {
    await Promise.anyof($!pro, Promise.in(5));
    if $!pro.status {
      $!pro = $!pro.result;
    }
  }
  fail "The screen server failed to run or daemonize"
    unless $!pro ~~ Proc;

  # Wait for it to send us its PID, if we are just starting now.
  my $pid = $!screen-pid;
  if $pid ~~ Promise {
    await Promise.anyof($pid, Promise.in(5));
    fail "Screen session never sent PID"
      unless $!screen-pid.WHAT === Str and $!screen-pid.chars;
  }
  True;
}

#| Clean up the temp files used when starting a new session.  It is unlikely
#| to be necessary to run this method manually.
method clean-old-files (::?CLASS:D:) {
  # File::Temp may have done this already or it may get run twice,
  # so hopefully nothing in here blows up if run redundantly.
  $!pidfh.?close;
  $!pidfn.IO.unlink with $!pidfn;
  $!pidfh = Nil;
  $!pidfn = Nil;
  $!rcfh.?close;
  $!rcfn.IO.unlink with $!rcfn;
  $!rcfh = Nil;
  $!rcfn = Nil;
}

# TODO: File::Temp cleans up during END, and according to specs DESTROY
# may run after that.  If a session is created and then destroyed while
# starting things might get messy, but we'll hold off fixing that until the
# dust settles around destruction/File::Temp.

#| Manually destroy a session the same way the garbage collector would.
#| Should clean everything up, if it has not been already.  Even when calling
#| this manually, C<.remain> will still protect the session, so it must be
#! adjusted according to intent.
method DESTROY (::?CLASS:D:) {
  $tokill_lock.protect: {
    %tokill{"$!screen-pid.$.sessionname"}:delete
  }
  if $!pro.defined {
    unless $!remain {
      if $!screen-pid ~~ Promise {
        # It was created but the PID was never harvested.
        # Since we may be on a countdown to process termination,
        # we can't really sit around waiting.  Just schedule
        # a handler and hope.
        $!screen-pid.then: {
          if $!screen-pid.chars and not $!remain {
            run $.path, '-q', '-S', "$!screen-pid.$.sessionname", '-X', 'quit'
          }
        }
      }
      else {
        # This is orderly run-time destruction, so in case it is still
        # being created in another thread, let it finish starting and
        # then shut it down in a civil manner.
        self.command("quit");
        # That may have repopulated %tokill, so delete again.
        $tokill_lock.protect: {
          %tokill{"$!screen-pid.$.sessionname"}:delete
        }
        # JIC run a wipe.
        # XXX this complains in the normal case due to exit code, skip for now
        # run $.path, '-q', '-wipe', "$!screen-pid.$.sessionname";
        # TODO: need to handle any zombie weirdness?
      }
    }
  }
  else {
    # Never started, so probably still has these files laying around
    self.clean-old-files;
  }
}

#| Send a command to a running session.  Does not wait.  A Promise
#| is returned, or use await-ready to wait.
method command(::?CLASS:D: $command, *@args) {
  self.await-ready;
  my $cmd = Proc::Async.new(:$.path,
    :args['-q', '-S', "$!screen-pid.$.sessionname", '-X', $command, |@args]);
  $!pro = $cmd.start();
}

method attach(::?CLASS:U: $match) {
  # TODO: constructor to attach to pre-existing sessions
  ...
}

#| Query information from a running session, storing the results
#| in C<out> as they become available. A C<Promise> is returned,
#| or use await-ready to wait before looking at the contents of C<:out>.
multi method query (::?CLASS:D: $command, *@args, :$out! is rw) {
  self.await-ready;
  my $cmd = Proc::Async.new(:$.path,
    :args['-S', "$!screen-pid.$.sessionname", '-Q', $command, |@args], :$out);
  $cmd.stdout(:bin).tap(-> $s { $out ~= $s.decode('ascii') });
  $!pro = $cmd.start();
}

#| If C<:out> is not provided C<.query>, will wait and return a
#| C<Str> containing the result.
multi method query (::?CLASS:D: $command, *@args) returns Str {
  self.await-ready;
  my $cmd = Proc::Async.new(:$.path,
    :args['-S', "$!screen-pid.$.sessionname", '-Q', $command, |@args]);
  # Probably overwrought but will refactor eveything once File::Temp has pipes
  my $c = Channel.new;
  (supply {
    whenever $cmd.stdout(:bin) -> $s {
      $c.send($s);
      emit("junk");
    };
    $!pro = $cmd.start }
  ).head.Promise.then({$c.close});
  ($c».decode('ascii')).join;
}

# Eventually we may be providing programmatic management of screenrc
# files, if wanted by users.  Stubbing in some stuff for now.

# Used for keybinding options.
#
# Given either an actual character or any common
# "human readable" representation of that character
# produce a pair where the key is the format screen
# understands in config files and the value is the actual
# character.  For example the "human readable" forms of
# control characters accepted are like "^A" "C-A" or "c-a"
# for \x01.

has $.escape = "\x[01]a";

my sub munge-escape-char(Str:D $_) {
  when /^ [ \^ | C\- ] (<[\@ A..Z \?]>) $/ {
      "^$_" => ($/[0] - '@'.ord).chr;
  }
  when /^ [ \^ | C\- ] (<[a..z]>) $/ {
    "^$_".uc => ($/[0] + 1 - 'a'.ord).chr;
  }
  when /^ (<[\x00..\x1a \x7f]>) $/ {
    "^{($_.ord + '@'.ord).chr}" => $_;
  }
  when /^ <:!control> $/ {
    $_ => $_;
  }
  default {
    die X::NYI.new(:feature<Some control characters>);
  }
}

# Return the configured options as they would appear on CLI
# If you want a list with pairs broken up, use :!paired
method options-cli(:$paired = True) {
  my @options;
  my sub infix:<→> ($k, $v) {
     $paired ?? ($k => $v) !! |($k, $v);
  }
  @options.append("-e" → [~] $.escape.comb.map({ munge-escape-char($_).key }));
}

# Return the configured options as they would appear in screenrc
# If you want a list of config lines instead of pairs, use :!paired
method options-conf(:$paired = True) {
  my @options;
  my sub infix:<→> ($k, $v) {
     $paired ?? ($k => $v) !! "$k $v";
  }
  @options.append("escape" → [~] $.escape.comb.map({ munge-escape-char($_).key }));
}
