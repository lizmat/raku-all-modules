use Event::Emitter::Role::Handler;

unit role Event::Emitter::Inter-Process does Event::Emitter::Role::Handler;

has Bool $!sub-process = False;
has Int  $!tapid;

has $!AOUT;
has @!events;
has %!tapbuf;

my \PROC_STATE_SIZE1 = 0;
my \PROC_STATE_EVENT = 1;
my \PROC_STATE_SIZE2 = 2;
my \PROC_STATE_SIZEM = 3;
my \PROC_STATE_DATA  = 4;

submethod BUILD(Bool :$sub-process? = False) {
  $!tapid = 0; 
  $!sub-process = $sub-process;
  $!AOUT = $*OUT if $sub-process;
  $*OUT  = $*ERR if $sub-process;
  if $sub-process { 
    start {
      CATCH { default { warn $_.perl; } }
      my $data = %(
        buffer => Buf.new,
        lsize  => 0,
        event  => Buf.new,
        state  => PROC_STATE_SIZE1,
      );
      my $last = -1;
      my $lastloop = $*IN.eof;
      while (!$*IN.eof) || $lastloop {
        CATCH { default { warn $_.perl; } }
        my Buf[uint8] $d = $lastloop ?? $*IN.slurp-rest(:bin) !! $*IN.read(1);
        $data<buffer> ~= $d;

        if self!state($data) {
          self!run($data<event>.decode, $data<data>); 
        }
        last if $lastloop;
        $lastloop = True if $*IN.eof && !$lastloop;
      }    
    }
  }
}

method !run($event, $data) {
  my @a = @!events.grep(-> $e {
    given ($e<event>.WHAT) {
      when Regex    { $event ~~ $e<event> }
      when Callable { $e<event>.($event)  }
      default       { $e<event> eq $event }
    };
  });
  $_<callable>($data) for @a;
}

method !state($state is rw) {
  CATCH { default { warn $_.perl; } }
  if $state<state> == PROC_STATE_SIZE1 &&
     $state<buffer>.elems >= 1
  {
    $state<lsize> = $state<buffer>[0];
    $state<buffer> .=subbuf(1);
    $state<state>++;
  }
  if $state<state> == PROC_STATE_EVENT && 
     $state<buffer>.elems >= $state<lsize> 
  {
    $state<event> = $state<buffer>.subbuf(0, $state<lsize>); 
    $state<buffer> .=subbuf($state<lsize>);
    $state<state>++;
  }
  if $state<state> == PROC_STATE_SIZE2 && 
     $state<buffer>.elems > 0
  {
    $state<lsize> = $state<buffer>[0] * 256;
    $state<buffer> .=subbuf(1);
    $state<state>++;
  }
  if $state<state> == PROC_STATE_SIZEM &&
     $state<buffer>.elems > 0
  {
    $state<lsize> += $state<buffer>[0];
    $state<buffer> .=subbuf(1);
    $state<state>++;
  }   
  if $state<state> == PROC_STATE_DATA &&
     $state<buffer>.elems >= $state<lsize> 
  {
    $state<data>   = $state<buffer>.subbuf(0, $state<lsize>);
    $state<buffer> .=subbuf($state<lsize>);
    $state<state> = 0; 
    return True;
  }
  return False;
}

method hook(Proc::Async $proc) {
  my $id = $!tapid++;
  %!tapbuf{$id} = %( 
    process => $proc,
    state   => PROC_STATE_SIZE1,
    buffer  => Buf.new,
    lsize   => 0,
    event   => Buf.new,
    data    => Buf.new,
  );
  my Supplier $s  .= new;
  my Supply $c     = $s.Supply;
  my        $state = %!tapbuf{$id};
  $c.tap(-> $d { 
    if self!state($state) {
      self!run($state<event>.decode, $state<data>); 
      $s.emit(1);
    }
  });
  $proc.stdout(:bin).tap(-> $data {
    $state<buffer> = $state<buffer> ~ $data;
    CATCH { default { warn $_; } }
    try $s.emit(1);
  });
}

method on($event, Callable $callable) {
  @!events.push({
    event    => $event,
    callable => $callable,
  });
}

method emit(Blob $event, Blob $data? = Blob.new) {
  my Blob $msg  .= new;  
  my Int $bytes = 0;

  #encode $event
  $msg ~= Buf.new($event.bytes);
  $msg ~= Buf.new($event);
  
  #encode $data size
  $msg ~= Buf.new(($data.elems/256).floor);
  $msg ~= Buf.new($data.elems % 256);

  $msg ~= Buf.new($data);

  $!AOUT.write($msg) if $!sub-process;

  if !$!sub-process {
    for %!tapbuf.keys -> $i {
      await %!tapbuf{$i}<process>.write($msg);
    }
  }
  $msg;
}

