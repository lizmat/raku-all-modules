use v6.c;
use Test;
use Semaphore::ReadersWriters;

my Bool $debug = False;

#-------------------------------------------------------------------------------
subtest {
  my Semaphore::ReadersWriters $rw .= new;
  $rw.debug = $debug;
  my $shared-var = 10;

  isa-ok $rw, 'Semaphore::ReadersWriters';

  $rw.add-mutex-names(<shv def>);
  cmp-ok 'shv', '~~', any($rw.get-mutex-names), 'shv key set';
  cmp-ok 'def', '~~', any($rw.get-mutex-names), 'def key set';

  ok $rw.check-mutex-names('def'), 'Key def found';
  ok !$rw.check-mutex-names('xyz'), 'Key xyz not found';
  ok $rw.check-mutex-names(<def xyz>), 'any of def or xyz is found';

  $rw.rm-mutex-names('def');
  cmp-ok 'def', '!~~', any($rw.get-mutex-names), 'def key removed';


  $rw.writer( 'def', {$shared-var += 2});
  CATCH {

    when X::AdHoc {
      cmp-ok .message,
      '~~',
      /:s mutex name \'def\' does not exist/,
      .message;
    }
  }

}, 'basic tests';

#-------------------------------------------------------------------------------
subtest {
  my Semaphore::ReadersWriters $rw .= new;
  $rw.debug = $debug;
  $rw.add-mutex-names('shv 2');
  my $shared-var = 10;

  my @p;
  for ^10 {
    my $i = $_;

    @p.push: Promise.start( {
#say "$*THREAD.id() Try reading $i" if $debug;
        $rw.reader( 'shv 2', { sleep((rand * 2).Int); $shared-var;});
      }
    );
  }

  pass "Result {.result}" for @p;
  pass "All reader threads have ended, no hangups";

}, 'only readers';

#-------------------------------------------------------------------------------
subtest {
  my Semaphore::ReadersWriters $rw .= new;
  $rw.debug = $debug;

  try {
    $rw.add-mutex-names('shv');
    CATCH {
      default {
        ok .message ~~ m:s/Key \'shv\' already in use/, .message;
      }
    }
  }

  my $shared-var = 10;

  my @p;
  for ^10 {
    my $i = $_;

    @p.push: Promise.start( {
#say "$*THREAD.id() Try writing $i" if $debug;
        $rw.writer( 'shv', { sleep((rand * 2).Int); ++$shared-var;});
      }
    );
  }

  pass "Result {.result}" for @p;
  pass "All writers threads have ended, no hangups";

}, 'only writers';

#-------------------------------------------------------------------------------
subtest {
  my Semaphore::ReadersWriters $rw .= new;
#$debug = True;
  $rw.debug = $debug;
  $rw.add-mutex-names('shv 3');
  my $shared-var = 10;

  my @p;
  for (^10).pick(30) {
    my $i = $_;

    @p.push: Promise.start( {

        my $r;

        # Only when $i <= 2 then thread becomes a writer.
        # All others become readers
        if $i <= 2 {
#say "$*THREAD.id() Try writing $i" if $debug;
          $r = $rw.writer( 'shv 3', {$shared-var += $i});
        }

        else {
#say "$*THREAD.id() Try reading $i" if $debug;
          $r = $rw.reader( 'shv 3', {$shared-var});
        }

        CATCH {
          default {
            .say;
            $r = -1;
          }
        }

#        $i.fmt('%03d') ~ ', ' ~ $r.fmt('%04d');
#        $r.fmt('%04d');
        $r;
      }
    );
  }

  pass "Result {.result} " for @p;
#  .result for @p;
  pass "All threads have ended, no hangups";

}, 'readers and writers';

#-------------------------------------------------------------------------------
done-testing;
