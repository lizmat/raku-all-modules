use Shell::Command;

class overwatch {
  has Str      $.execute       = 'perl6';
  has Bool     $.keep-alive    = True;
  has Bool     $.exit-on-error = False,
  has Str      $.filter        = '';
  has Supplier $.supplier     is rw;
  has Supply   $.events       is rw;
  has Int      $.git-interval is rw;
  has Bool     $.dying        is rw;

  has $.git = -1;
  has @.filters;
  has @.watch;

  method BUILD(:$!execute, :$!keep-alive, :$!exit-on-error, :$!filter, :$!git-interval = Int, :$!git, :@!filters, :@!watch) {
    $.supplier .=new;
    $.events = $.supplier.Supply; 
  }

  method go (*@args) {
    my ($prom, $proc, $killer, @filters);

    die 'Please provide some arguments' if @args.elems == 0;

    $.events = $.supplier.Supply;

    @.filters = $.filter.split(',').map({ .trim }).Slip;

    $.git-interval = $.git;

    $.git-interval = 5 if $.git ~~ Bool && $.git:so;

    $.supplier.emit({
      action       => 'start',
      execute      => $.execute,
      filters      => @.filters,
      watch        => @.watch,
      git-interval => $.git-interval,
      args         => @args,
    });

    for @.watch -> $dir {
      die "Unable to find directory: $dir" if $dir.IO !~~ :e;
      $dir.IO.watch.tap: -> $f {
        my $restart = False;
        for @.filters -> $e { 
          $restart = True, last if $f.path.chars > $e.chars &&  $e eq $f.path.substr(*- $e.chars); 
        }
        if @filters.elems == 0 || (@filters.elems > 0 && $restart) {
          try {
            $proc.kill(SIGQUIT);
            CATCH { 
              default { 
                $.supplier.emit({
                  action => 'error',
                  type   => 100,
                  msg    => "Could not kill process: {.message}"
                });
              } 
            }
          }
          try {
            $killer.keep(True);
          }
          $.supplier.emit({
            action    => 'file-changed',
            file-path => "$dir/{$f.path}".IO.relative;
          });
        }
      }
    }
    
    my $s;
    if $.git-interval >= 0 {
      start { 
        $s = Supply.interval($.git-interval * 60);
        my Promise $p .= new;
        $s.tap({
          qx<git remote update>; 
          my $local  = qx<git rev-parse @{0}>.chomp; 
          my $remote = qx<git rev-parse @{u}>.chomp; 
          my $base   = qx<git merge-base @{0} @{u}>.chomp;
          if $local ne $remote && $local eq $base {
            $.supplier.emit({ action => 'git-pull' });
            qx<git pull>;
          }
        }, quit => { $p.keep; });
        await $p;
      };
    }

    $.dying = False;
    signal(SIGTERM,SIGINT,SIGHUP,SIGQUIT).tap({
      $.dying = True;
      $.supplier.emit({ 
        action => 'kill-proc',
        signal => $_,
      });
      await $proc.kill($_);
      exit 0;
    });

    while Any ~~ $proc || $.keep-alive {
      $proc = Proc::Async.new($.execute, @args);
      $proc.stdout.act(&print);
      $proc.stderr.act(-> $r { $*ERR.print($r); });
      $prom = $proc.start;
      $killer = Promise.new;
      await Promise.anyof($prom, $killer);
      $killer.break if $killer.status !~~ Kept;
      if ($killer.status !~~ Kept && $prom.result:exists && $prom.result.exitcode != 0 && $.exit-on-error) || $.dying {
        $.supplier.emit({
          action => 'proc-died',
          code   => $prom.result.exitcode,
        });
        exit 0;
      }
      $.supplier.emit({
        action  => 'restart',
        execute => "$.execute {@args.map({ "'$_'" }).Slip.join(' ')}",
      });
    }
    try $s.quit;
  }
}
