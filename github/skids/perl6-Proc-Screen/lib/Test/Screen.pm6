unit class Test::Screen:auth<skids>:ver<0.0.1>;

use Test;
use Proc::Screen;
use File::Temp;

#| Although screen only emulates vt100 it may be possible to test
#| useful differences between two screen sessions if they are
#| optioned differently.  Each entry in %Test::Screen::rcs will
#| spawn a different screen with the screenrc provided in the
#| key as an array of lines.
#| All tests run in parallel on each screen.
our %test-screenrcs =  :utf8["defutf8 on"], :utf8alt["defutf8 on","altscreen on"];
# unfortunately despite the sundry options and termcap handling,
# the screen code hardcodes 80x24 when we start without a display.
#:utf8large["defutf8 on",'termcap * Z0=\E[?3h:Z1=\E[?3l', "width -w 120","height -w 35"];
# unfortunatley -Q info is broken with non-utf8
#:latin1["defutf8 off"]

#| Usually you want to run (copies of) the same program in each screen.
#| This can be done easily by setting $test-screen-shell to an array 
#| containing the desired command and arguments.  If different commands
#| are desired per screen, set $test-screen-shell to a hash of arrays
#| using the same keys as %test-screenrcs.
our $test-screen-shell is export = ["sh"];

#| The session IDs for all the screens being tested are stored here.
our %test-screens is export;

#| A screen can be exempted from further tests by adding its key here
#| (and turned back on by deleting the key.)  Note this does not
#| count as a "skip" in the Test::skip sense.
our %test-skipped-screens is export;

#| Prettier way to add keys to %test-skipped-screens.
our sub skip-screens (@names) is export {
  %test-skipped-screens{@names} = ();
}

#| Empty out %test-skipped-screens so tests run on all screens again
our sub all-screens (@names) is export {
  %test-skipped-screens{ }:delete;
}

#| Mostly for internal use: keys/values of screens that are not being skipped
our sub tested-screens is export {
  %test-screens{
    (%test-screens (-) %test-skipped-screens).keys
  }:kv;
}

#| Stop all the running screens (and their child processes) except
#| the ones in Test::Screen::skip-screens
our sub destroy-screens is export {
  for tested-screens() -> $sn, $ss {
    $ss.DESTROY;
    %test-screens{$sn}:delete;
  }
}

#| Stop all running (unskipped) screens and then start screens as
#| defined in %test-screenrcs, which may indeed be altered beforehand.
#| This will not clear the %test-skipped-screens keys
#| so if you name a new screen the same as one that was killed,
#| it will still be running, and skipped.
our sub restart-screens is export {
  destroy-screens;
  for %test-screenrcs{
    (%test-screenrcs (-) %test-skipped-screens).keys
  }:kv -> $sn, $rc {
    my @shell = $test-screen-shell ~~ Hash ??
      $test-screen-shell{$sn}.list !! $test-screen-shell.list;
    @shell = ~«@shell;
    die "Need to specify shell for screen '$sn'" unless @shell;
    %test-screens{$sn} = Proc::Screen.new(:sessionname<Test::Screen> 
                                          :rc[$rc.list] :@shell);
    %test-screens{$sn}.start;
  }
}
#| Just an alias for restart-screens
our sub start-screens is export {
  restart-screens
}

#| Simulate user keystrokes on all unskipped test screens.
#| Durations will be slept on; other stringy things will be encoded
#| and the resulting bytes sent.  Screen understands utf-8 for
#| this purpose.
sub screen-keystrokes (*@keystrokes) is export {
  await (for tested-screens() -> $sn, $ss {
    start {
      for @keystrokes {
        when Duration { sleep $_ }
        default {
          $ss.command('eval', 'register p "' ~
                      $_.encode.values.map({.fmt('\%3.3o')}).join ~ '"', 'paste p');
        }
      }
    }
  });
}

#| Take screenshots from all unskipped screens.  Include the scrollback
#| buffer if :$inscrollback is True.  Do not include the on-screen portion
#| if :$onscreen is False.  Returns a hash of screen session ID to content.
sub get-hardcopies (:$inscrollback = False; :$onscreen = True) is export {
  my %res;
  for tested-screens() -> $sn, $ss {
      %res{$sn} := $ = Nil;
  }
  await (for tested-screens() -> $sn, $ss {
    start {
      my $sr := %res{$sn};
      my $info = $ss.query('info');
      my ($fn, $fh) = |tempfile();
      $info ~~ m|\( \d+ \, \d+ \) \/ \( \d+ \, (\d+) \) \+ (\d+)|;
      my ($height, $scrollback) = +«$/[0,1];
      my $p = $fh.watch.head.Promise;
      $ss.command("hardcopy", ("-h" if $inscrollback), $fn);
      await Promise.anyof($p, Promise.in(5));
      my $output = $fh.slurp-rest;
      if ($output.chars) {
        $sr = $output.lines;
        if $inscrollback and not $onscreen {
          $sr = $sr[0..^$scrollback];
        }
      }
      $fn.IO.unlink;
    }
  });
  %res;
} 

#| Test if a given row matches a pattern.  $row == 0 is the first one
#| on the visible area of the screen.  Negative rows are in the 
#| scrollback buffer.
multi sub row-matches($row where * >= 0, $pattern, $message) is export {
  my %hc = get-hardcopies;
  subtest {
    my @screens;
    for tested-screens() -> $sn, $ss {
      @screens.push($sn);
    }
    @screens .= sort;
    plan +@screens;
    for @screens -> $sn {
      if %hc{$sn}.defined and %hc{$sn}[$row]:exists {
        my $ok = %hc{$sn}[$row] ~~ $pattern;
        ok $ok, "[ test screen $sn ]";
        unless $ok {
          diag "Expected: " ~ ($pattern ~~ Str ?? $pattern !! $pattern.perl);
          diag "     Got: " ~ %hc{$sn}[$row];
        }
      }
      else {
        # TODO: do not report this if row is out of actual visible range;
        nok 1, "Test::Screen internal error";
      }
    }
  }, $message;
}

multi sub row-matches($row where * < 0, $pattern, $message) is export {
  my %hc = get-hardcopies(:inscrollback, :!onscreen);
  subtest {
    my @screens;
    for tested-screens() -> $sn, $ss {
      @screens.push($sn);
    }
    @screens .= sort;
    plan +@screens;
    for @screens -> $sn {
      if %hc{$sn}.defined and %hc{$sn}[* + $row]:exists {
        my $ok = %hc{$sn}[* + $row] ~~ $pattern;
        ok $ok, "[ test screen $sn ]";
        unless $ok {
          diag "Expected: " ~ ($pattern ~~ Str ?? $pattern !! $pattern.perl);
          diag "     Got: " ~ %hc{$sn}[* + $row];
        }
      }
      else {
        # TODO: do not report this if row is out of actual scrollback range;
        nok 1, "Test::Screen internal error";
      }
    }
  }, $message;
}
