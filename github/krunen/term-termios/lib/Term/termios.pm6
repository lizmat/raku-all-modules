use v6;
use NativeCall;

=begin pod

=head1 NAME

Term::termios

=head1 DESCRIPTION

Class to interface to libc termios functions

=head1 SYNOPSIS

 use Term::termios;

 # Save the previous attrs
 my $saved_termios := Term::termios.new(fd => 1).getattr;

 # Get the existing attrs in order to modify them
 my $termios := Term::termios.new(fd => 1).getattr;

 # Set the tty to raw mode
 $termios.makeraw;

 # You could also do the same in the old-fashioned way
 $termios.unset_iflags(<BRKINT ICRNL ISTRIP IXON>);
 $termios.set_oflags(<ONLCR>);
 $termios.set_cflags(<CS8>);
 $termios.unset_lflags(<ECHO ICANON IEXTEN ISIG>);

 # Set the modified atributes, delayed until the buffer is emptied
 $termios.setattr(:DRAIN);

 # Loop on characters from STDIN
 loop {
    my $c = $*IN.getc;
    print "got: " ~ $c.ord ~ "\r\n";
    last if $c eq 'q';
 }

 # Restore the saved, previous attributes before exit
 $saved_termios.setattr(:DRAIN);

See the manpage L<man:termios(3)> for information about the flags.

=end pod

my %iflags = (
  IGNBRK  => 1,
  BRKINT  => 2,
  IGNPAR  => 4,
  PARMRK  => 10,
  INPCK   => 20,
  ISTRIP  => 40,
  INLCR   => 100,
  IGNCR   => 200,
  ICRNL   => 400,
  IUCLC   => 1000,
  IXON    => 2000,
  IXANY   => 4000,
  IXOFF   => 10000,
  IMAXBEL => 20000,
  IUTF8   => 40000,
);

my %oflags = (
  OPOST   => 1,
  OLCUC   => 2,
  ONLCR   => 4,
  OCRNL   => 10,
  ONOCR   => 20,
  ONLRET  => 40,
  OFILL   => 100,
  OFDEL   => 200,
  VTDLY   => 40000,
    VT0   => 0,
    VT1   => 40000,
);

my %cflags = (
  CSIZE   => 60,
    CS5   => 0,
    CS6   => 20,
    CS7   => 40,
    CS8   => 60,
  CSTOPB  => 100,
  CREAD   => 200,
  PARENB  => 400,
  PARODD  => 1000,
  HUPCL   => 2000,
  CLOCAL  => 4000,
);

my %lflags = (
  ISIG    => 1,
  ICANON  => 2,
  ECHO    => 10,
  ECHOE   => 20,
  ECHOK   => 40,
  ECHONL  => 100,
  NOFLSH  => 200,
  TOSTOP  => 400,
  IEXTEN  => 100000,
);

class Term::termios is repr('CStruct') {
  has int32 $.iflag;
  has int32 $.oflag;
  has int32 $.cflag;
  has int32 $.lflag;
  has int8 $.line;
  has int8 $.cc_VINTR is rw;
  has int8 $.cc_QUIT is rw;
  has int8 $.cc_VERASE is rw;
  has int8 $.cc_VKILL is rw;
  has int8 $.cc_VEOF is rw;
  has int8 $.cc_VTIME is rw;
  has int8 $.cc_VMIN is rw;
  has int8 $.cc_VSWTC is rw;
  has int8 $.cc_VSTART is rw;
  has int8 $.cc_VSTOP is rw;
  has int8 $.cc_VSUSP is rw;
  has int8 $.cc_VEOL is rw;
  has int8 $.cc_VREPRINT is rw;
  has int8 $.cc_VDISCARD is rw;
  has int8 $.cc_VWERASE is rw;
  has int8 $.cc_VLNEXT is rw;
  has int8 $.cc_VEOL2 is rw;
  has int8 $.cc_17 is rw; has int8 $.cc_18 is rw; has int8 $.cc_19 is rw;
  has int8 $.cc_20 is rw; has int8 $.cc_21 is rw; has int8 $.cc_22 is rw;
  has int8 $.cc_23 is rw; has int8 $.cc_24 is rw; has int8 $.cc_25 is rw;
  has int8 $.cc_26 is rw; has int8 $.cc_27 is rw; has int8 $.cc_28 is rw;
  has int8 $.cc_29 is rw; has int8 $.cc_30 is rw; has int8 $.cc_31 is rw;
  has int32 $.ispeed is rw;
  has int32 $.ospeed is rw;

  has int32 $!fd;
  has Term::termios $!saved;

  sub tcgetattr(int32, Term::termios) returns int32 is native {*}
  sub tcsetattr(int32, int32, Term::termios) returns int32 is native {*}
  sub cfmakeraw(Term::termios) is native {*}
  my constant $library = %?RESOURCES<libraries/myhelper>.Str;

  class termios_constants is repr('CPointer') {};
  sub termios_create_constant() returns termios_constants is native($library) {*}
  sub termios_get_next_constant(termios_constants) returns termios_constants is native($library) {*}
  sub termios_get_name(termios_constants) returns Str is native($library) {*}
  sub termios_get_value(termios_constants) returns int64 is native($library) {*}

  method !overwrite_constant {
      my $p = termios_create_constant();
      loop {
          my Str $name = termios_get_name($p);
          my Int $value = termios_get_value($p);
          last unless $name.defined;

          %iflags{$name} = $value if %iflags{$name}:exists;
          %oflags{$name} = $value if %oflags{$name}:exists;
          %cflags{$name} = $value if %cflags{$name}:exists;
          %lflags{$name} = $value if %lflags{$name}:exists;

          $p = termios_get_next_constant($p);
      }
  }

  submethod BUILD(:$fd) {
    $!fd = $fd;
    self!overwrite_constant;
  }

  method getattr () {
    tcgetattr($!fd,self) and die "tcgetattr failed";
    self;
  }

  method setattr (:$NOW?, :$DRAIN?, :$FLUSH?) {
    tcsetattr($!fd, $DRAIN ?? 1 !! $FLUSH ?? 2 !! 0, self) and die "tcsetattr failed";
    self;
  }

  method makeraw() {
    cfmakeraw(self);
    self;
  }

  method set_iflags(*@flags) {
    for @flags -> $flag {
      die "Uknown iflag $flag" unless %iflags{$flag};
      $!iflag = $!iflag +| %iflags{$flag};
    }
  }

  method unset_iflags(*@flags) {
    for @flags -> $flag {
      die "Uknown iflag $flag" unless %iflags{$flag};
      $!iflag = $!iflag +& +^%iflags{$flag};
    }
  }

  method set_oflags(*@flags) {
    for @flags -> $flag {
      die "Uknown oflag $flag" unless %oflags{$flag};
      $!oflag = $!oflag +| %oflags{$flag};
    }
  }

  method unset_oflags(*@flags) {
    for @flags -> $flag {
      die "Uknown oflag $flag" unless %oflags{$flag};
      $!oflag = $!oflag +& +^%oflags{$flag};
    }
  }

  method set_cflags(*@flags) {
    for @flags -> $flag {
      die "Uknown cflag $flag" unless %cflags{$flag};
      $!cflag = $!cflag +| %cflags{$flag};
    }
  }

  method unset_cflags(*@flags) {
    for @flags -> $flag {
      die "Uknown cflag $flag" unless %cflags{$flag};
      $!cflag = $!cflag +& +^%cflags{$flag};
    }
  }

  method set_lflags(*@flags) {
    for @flags -> $flag {
      die "Uknown lflag $flag" unless %lflags{$flag};
      $!lflag = $!lflag +| %lflags{$flag};
    }
  }

  method unset_lflags(*@flags) {
    for @flags -> $flag {
      die "Uknown lflag $flag" unless %lflags{$flag};
      $!lflag = $!lflag +& +^%lflags{$flag};
    }
  }
}

