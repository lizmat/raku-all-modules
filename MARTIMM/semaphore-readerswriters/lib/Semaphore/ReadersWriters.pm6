use v6.c;

#`{{
  use Semaphore::ReadersWriters;

  my Semaphore::ReadersWriters $rw .= new;
  $rw.add-mutex-names('shv');
  my $shared-var = 10;

  # After creating threads ...
  # Some writer thread
  $rw.writer( 'shv', {$shared-var += 2});

  # Some reader thread
  say 'Shared var is ', $rw.reader( 'shv', {$shared-var;});
}}

class Semaphore::ReadersWriters:ver<0.2.2>:auth<MARTIMM> {

  # Using state instead of has or my will have a scope over all
  # objects of this class, state will also be initialized only
  # once and BUILD is not necessary.
  state Hash $semaphores = {};
  state Semaphore $s-mutex = Semaphore.new(1);

  has Bool $.debug is rw = False;

  constant C-RW-TYPE                            = 0;
  constant C-READSTRUCT-LOCK                    = 1; # read count lock
  constant C-READERS-LOCK                       = 2; # block readers
  constant C-READERS-COUNT                      = 3; # count readers
  constant C-WRITESTRUCT-LOCK                   = 4; # write count lock
  constant C-WRITERS-LOCK                       = 5; # block writers
  constant C-WRITERS-COUNT                      = 6; # writer count

  subset RWPatternType of Int is export where 1 <= $_ <= 3;
  constant C-RW-READERPRIO is export            = 1;
  constant C-RW-NOWRITERSTARVE is export        = 2;
  constant C-RW-WRITERPRIO is export            = 3;

  #-----------------------------------------------------------------------------
  method add-mutex-names (
    *@snames,
    RWPatternType :$RWPatternType = C-RW-WRITERPRIO
  ) {

    my Bool $throw-exception = False;
    my Str $used-name;

    $s-mutex.acquire;
    for @snames -> $sname {

      if $semaphores{$sname}:exists {
        $used-name = $sname;
        $throw-exception = True;
        last;
      }

      # Make an array of each entry. [0] is a readers semaphore with a readers
      # counter([1]). Second pair is for writers at [2] and [3].
      $semaphores{$sname} = [
        $RWPatternType,         # pattern type
        Semaphore.new(1), Semaphore.new(1), 0,    # readers semaphores and count
        Semaphore.new(1), Semaphore.new(1), 0     # writers semaphores and count
      ] unless $semaphores{$sname}:exists;
    }

    $s-mutex.release;

    if $throw-exception {
      die "Key '$used-name' already in use'";
    }
  }

  #-----------------------------------------------------------------------------
  method rm-mutex-names ( *@snames ) {

    $s-mutex.acquire;
    for @snames -> $sname {
      $semaphores{$sname}:delete if $semaphores{$sname}:exists;
    }
    $s-mutex.release;
  }

  #-----------------------------------------------------------------------------
  method get-mutex-names ( ) {

    $s-mutex.acquire;
    my @names = $semaphores.keys;
    $s-mutex.release;

    return @names;
  }

  #-----------------------------------------------------------------------------
  method check-mutex-names ( *@names --> Bool ) {

    $s-mutex.acquire;
    my Bool $in-use;
    for @names -> $name {
      $in-use = $semaphores{$name}:exists and $semaphores{$name}.defined;
      last if $in-use;
    }
    $s-mutex.release;

    return $in-use;
  }

  #-----------------------------------------------------------------------------
  method reader ( Str:D $sname, Block:D $code --> Any ) {

    # Check if structure of key is defined
    $s-mutex.acquire;
    my Bool $has-key = $semaphores{$sname}:exists;
    $s-mutex.release;
    return fail("mutex name '$sname' does not exist") unless $has-key;

say "$*THREAD.id() R $sname hold ws" if $!debug;
    # if writers are busy then wait,
    $semaphores{$sname}[C-WRITERS-LOCK].acquire;
say "$*THREAD.id() R $sname hold ws continue" if $!debug;

    self!reader-lock($sname);

say "$*THREAD.id() R $sname release ws" if $!debug;
    # signal writers queue
    $semaphores{$sname}[C-WRITERS-LOCK].release;

say "$*THREAD.id() R $sname run code" if $!debug;
    my Any $r = &$code();

    self!reader-unlock($sname);
say "$*THREAD.id() R unlock called" if $!debug;

    $r;
  }

  #-----------------------------------------------------------------------------
  method writer ( Str:D $sname, Block:D $code --> Any ) {

    # Check if structure of key is defined
    $s-mutex.acquire;
    my Bool $has-key = $semaphores{$sname}:exists;
    $s-mutex.release;
    return fail("mutex name '$sname' does not exist") unless $has-key;

    self!writer-lock($sname);

say "$*THREAD.id() W $sname block writers" if $!debug;
    # Block other writers
    $semaphores{$sname}[C-READERS-LOCK].acquire;
say "$*THREAD.id() W $sname block writers continue" if $!debug;

say "$*THREAD.id() W $sname run code" if $!debug;
    my Any $r = &$code();

say "$*THREAD.id() W $sname accept other writers" if $!debug;
    $semaphores{$sname}[C-READERS-LOCK].release;

    self!writer-unlock($sname);
say "$*THREAD.id() W unlock called" if $!debug;

    $r;
  }

  #-----------------------------------------------------------------------------
  method !reader-lock ( Str:D $sname ) {

say "$*THREAD.id() R $sname lock" if $!debug;
    # hold if this is the first writer
    $semaphores{$sname}[C-READSTRUCT-LOCK].acquire;
    $semaphores{$sname}[C-READERS-LOCK].acquire
      if ++$semaphores{$sname}[C-READERS-COUNT] == 1;
    $semaphores{$sname}[C-READSTRUCT-LOCK].release;
say "$*THREAD.id() R $sname locked" if $!debug;
  }

  #-----------------------------------------------------------------------------
  method !writer-lock ( Str:D $sname ) {

say "$*THREAD.id() W $sname lock" if $!debug;
    # hold if this is the first writer
    $semaphores{$sname}[C-WRITESTRUCT-LOCK].acquire;
    $semaphores{$sname}[C-WRITERS-LOCK].acquire
      if ++$semaphores{$sname}[C-WRITERS-COUNT] == 1;
    $semaphores{$sname}[C-WRITESTRUCT-LOCK].release;
say "$*THREAD.id() W $sname locked" if $!debug;
  }

  #-----------------------------------------------------------------------------
  method !reader-unlock ( Str:D $sname ) {

say "$*THREAD.id() R $sname unlock" if $!debug;
    $semaphores{$sname}[C-READSTRUCT-LOCK].acquire;
    $semaphores{$sname}[C-READERS-LOCK].release
      if --$semaphores{$sname}[C-READERS-COUNT] == 0;
    $semaphores{$sname}[C-READSTRUCT-LOCK].release;
say "$*THREAD.id() R $sname unlocked" if $!debug;
  }

  #-----------------------------------------------------------------------------
  method !writer-unlock ( Str:D $sname ) {

say "$*THREAD.id() W $sname unlock" if $!debug;
    $semaphores{$sname}[C-WRITESTRUCT-LOCK].acquire;
    $semaphores{$sname}[C-WRITERS-LOCK].release
      if --$semaphores{$sname}[C-WRITERS-COUNT] == 0;
    $semaphores{$sname}[C-WRITESTRUCT-LOCK].release;
say "$*THREAD.id() W $sname unlocked" if $!debug;
  }
}
