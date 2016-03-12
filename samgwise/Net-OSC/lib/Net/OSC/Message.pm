use v6;
#use experimental :pack;

class Net::OSC::Message {
  subset OSCPath of Str where *.substr-eq('/', 0);

  my %type-map32 =
    Int.^name,    'i',
    IntStr.^name, 'i',
    Num.^name,    'f',
    Rat.^name,    'f',
    RatStr.^name, 'f',
    FatRat.^name, 'f',
    Str.^name,    's',
    Blob.^name,   'b',
  ;
  my %type-map64 =
    Int.^name,    'i',
    IntStr.^name, 'i',
    Num.^name,    'd',
    Rat.^name,    'd',
    RatStr.^name, 'd',
    FatRat.^name, 'd',
    Str.^name,    's',
    Blob.^name,   'b',
  ;
  #Initial pack mappings sourced from the Protocol::OSC perl5 module
  # expanded with info from http://opensoundcontrol.org/spec-1_0
  my %pack-map =
    i => 'i',           #int32
    f => 'f',           #float32
    s => 's',           #OSC-string
    S => 's',           #OSC-string alternative
    #b => 'N/C* x!4',    #OSC-blob
    #h => 'h',           #64 bit big-endian twos compliment integer
    #t => 'N2',          #OSC-timetag
    d => 'd',           #64 bit ("double") IEEE 754 floating point number
  ;

  has OSCPath $.path        = '/';
  has Str     @!type-list   = Nil;
  has         @!args;
  has Bool    $.is64bit    = True;

  submethod BUILD(:@!args, :$!path = '/', :$!is64bit = True) {
     self!update-type-list(@!args);
  }

  method type-string() {
    @!type-list.join: '';
  }

  method pick-osc-type($arg) {
    #say "Choosing type for $arg of type {$arg.WHAT.perl}";
    my $type-map = $!is64bit ?? %type-map64 !! %type-map32;
    if $arg.WHAT.perl ~~ $type-map {
      return $type-map{$arg.WHAT.perl};
    }
    else {
      die "Unable to map $arg of type { $arg.perl } to OSC type!";
    }
  }

  method !update-type-list(*@args){
    for @args -> $arg {
      @!type-list.push: self.pick-osc-type($arg);
    }
  }

  method args(*@new-args) {
    if @new-args {
      @!args.push(|@new-args);
      self!update-type-list(|@new-args);
    }

    gather for @!args -> $arg {
      take $arg;
    }
  }

  method set-args(*@new-args) {
    @!args = ();
    @!type-list = ();
    self.args(@new-args) if @new-args;
  }

  method type-map() {
    ($!is64bit ?? %type-map64 !! %type-map32).pairs;
  }

  method package() returns Buf {
      self.pack-string($!path)
      ~ self.pack-string(",{ self.type-string() }")
      ~ self!pack-args();
  }

  method !pack-args() returns Blob {
    [~] gather for @!args Z @!type-list -> ($arg, $type) {
      #say "Packing '$arg' of OSC type '$type' with pattern '%pack-map{$type}'";

      given %pack-map{$type} {
        when 'f' {
          take self.pack-float32($arg);
        }
        when 'd' {
          take self.pack-double($arg);
        }
        when 'i' {
          take self.pack-int32($arg);
        }
        when 's' {
          take self.pack-string($arg);
        }
        default {
          take pack(%pack-map{$type}, $arg);
        }
      }

    }
  }

  #returns a new Message object
  method unpackage(Buf $packed-osc) {
    #say "Unpacking message of {$packed-osc.elems} byte(s):";
    #say $packed-osc.map( { sprintf('%4s', $_.base(16)) } ).rotor(8, :partial).join("\n");
    my $path = '';
    my @types;
    my @args;
    my $read-pointer = 0;
    my $buffer-width = 1;
    my $message-part = 0; # 0 = path, 1 = type string, 2 = args

    #Closure for string parsing, operates on this scope of variables
    my $extract-string = sub {
      #say "Unpacking string";
      $buffer-width = 4;
      my $arg = '';
      my $chars;
      repeat {
        $chars = $packed-osc.subbuf($read-pointer, $buffer-width);
        $read-pointer += $buffer-width;
        for $chars.decode('ISO-8859-1').comb -> $char {
          if $char eq "\0" {
            $buffer-width = 0; #signal end of string
            last;
          }
          $arg ~= $char;
        }
      } while $buffer-width == 4 and $read-pointer < $packed-osc.elems;
      #say "'$arg'";
      $arg;
    }

    #start parse
    $path = $extract-string.();
    @types = $extract-string.().comb: /\w/; #extract type chars and ignore the ','

    while $read-pointer < $packed-osc.elems {
      given @types.shift -> $type {
        when $type eq 'f' {
          $buffer-width = 4;
          my $buf = $packed-osc.subbuf($read-pointer, $buffer-width);
          @args.push: self.unpack-float32( $buf );
          $read-pointer += $buffer-width;
        }
        when $type eq 'd' {
          $buffer-width = 8;
          my $buf = $packed-osc.subbuf($read-pointer, $buffer-width);
          @args.push: self.unpack-double( $buf );
          $read-pointer += $buffer-width;
        }
        when $type eq 'i' {
          $buffer-width = 4;
          my $buf = $packed-osc.subbuf($read-pointer, $buffer-width);

          @args.push: self.unpack-int32( $buf );
          $read-pointer += $buffer-width;
        }
        when $type eq 's' {
          @args.push: $extract-string.();
        }
        default {
          die "Unhandled type '$type'";
        }
      }
    }

    self.bless(
      :$path,
      :@args
    );
  }

  method pack-float32(Numeric(Cool) $number) returns Buf {
    self!floating-point-packer(8, 23, $number);
  }

  method pack-double(Numeric(Cool) $number) returns Buf {
    self!floating-point-packer(11, 52, $number);
  }

  #! generalised float packer routine. Use args(8, 23, $r) to pack a float 32 value or args(11, 52, $r) for a double etc...
  method !floating-point-packer(Int $exponent, Int $fraction, Numeric(Cool) $number) returns Buf {
    self.bits2buf(
      (
          ($number.sign == -1 ?? 1 !! 0)                                                                                         #sign
        ~ ( ( $number.truncate.msb + ((2**($exponent - 1)) - 1) ).base(2) ~ (0 x $exponent) ).substr(0, $exponent)               #exponent
        ~ ( ($number / 2**$number.truncate.msb).base(2) ~ (0 x $fraction) ).substr( ($number.sign == -1 ?? 3 !! 2), $fraction )  #fraction
      ).comb
    );
  }

  method pack-int32(Int(Cool) $number) returns Buf {
    self.pack-int($number, 32);
  }

  method pack-int(Int $value, Int $bit-width = 32, Bool :$signed = True) returns Buf {
    # #say "Packing $value to a { $signed ?? "signed" !! "unsigned" } {$bit-width}bit int";
    # my @bits = (
    #   ($signed ?? ($value.sign == -1 ?? 1 !! 0) !! '')
    #   ~
    #   sprintf( "\%0{ $signed ?? $bit-width - 1 !! $bit-width }d", $value.abs.base(2) )
    # ).comb;
    #
    # #say "$value → { @bits.rotor(8)».join: '' }";
    #
    # self.bits2buf(@bits);

    self.bits2buf(
      (
        ($signed ?? ($value.sign == -1 ?? 1 !! 0) !! '')
        ~
        sprintf( "\%0{ $signed ?? $bit-width - 1 !! $bit-width }d", $value.abs.base(2) )
      ).comb
    )
  }

  method unpack-float32(Buf $bits) {
    self!unpack-floating-point(8, 23, $bits);
  }

  method unpack-double(Buf $bits) {
    self!unpack-floating-point(11, 52, $bits);
  }

  #! generalised float unpacker routine. Use args(8, 23, $r) to pack a float 32 value or args(11, 52, $r) for a double etc...
  method !unpack-floating-point(Int $exponent, Int $fraction, Buf $bits) {
    my $bin = self.buf2bin($bits);
    (
      (-1) ** $bin[0]                                                                                  #sign
      *
      (1 + self.unpack-int($bin[($exponent + 1)..$bin.end], :signed(False)) * 2**($fraction * -1))     #significand (fraction)
      *
      2 ** ( self.unpack-int($bin[1..$exponent], :signed(False)) - ((2**($exponent - 1)) - 1) )        #exponent
    ) + ($bin[0].sign == 1 ?? 128 !! 0);
  }

  method unpack-int32(Buf $bits) returns Int {
    self.unpack-int: self.buf2bin($bits);
  }

  method unpack-int(@bits, Bool :$signed = True) returns Int {
    #say "Unpacking { $signed ?? "signed" !! "unsigned" } int { @bits.perl } { @bits.elems }";
    my Int $total = 0;
    for ($signed ?? 1 !! 0)..@bits.end -> $i {
      if !$signed or @bits[0] == 0 {
        $total += Int(@bits[$i] * (2 ** (@bits.end - $i)));
      }
      else {
        $total -= Int(@bits[$i] * (2 ** (@bits.end - $i)));
      }
    }
    #say $total;
    $total;
  }

  method buf2bin(Buf $bits) returns Array {
    my @bin;
    for 0 .. ($bits.elems - 1) {
      @bin.push: |sprintf( '%08d', $bits[$_].base(2) ).comb;
    }
    @bin
  }

  method bits2buf(@bits) returns Buf {
    Buf.new: @bits.rotor(8).map: { self.unpack-int($_, :signed(False)) };
  }

  method pack-string(Str $string) returns Blob {
    ( $string ~ ( "\0" x 4 - ( $string.chars % 4) ) ).encode('ISO-8859-1')
  }
}
