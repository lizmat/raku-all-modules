use v6;

unit class Net::OSC::Message;

=begin pod

=head1 NAME

Net::OSC::Message - Impliments OSC message packing and unpacking

=head1 METHODS

=end pod

use Numeric::Pack :ALL;

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

submethod BUILD(:@!args, :$!path = '/', :$!is64bit = True)
#= Constructs an Net::OSC::Message
#= :args is required even if it is simply an empty list
#= Set :is64bit to false to force messages to be packed to 32bit types
#=  this option may be required to talk to some versions of Max and other old OSC implimentations.
{
   self!update-type-list(@!args);
}

method type-string()
#= Returns the current type string of this messages content.
{
  @!type-list.join: '';
}

method pick-osc-type($arg)
#= Returns the character representing the OSC type $arg would be packed as by this Message object.
{
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

method args(*@new-args)
#= adds any argumetns as args to the object and returns the current message args list.
{
  if @new-args {
    @!args.push(|@new-args);
    self!update-type-list(|@new-args);
  }

  gather for @!args -> $arg {
    take $arg;
  }
}

method set-args(*@new-args)
#= Clears the message args lists and sets it to the arguments provided.
{
  @!args = ();
  @!type-list = ();
  self.args(@new-args) if @new-args;
}

method type-map()
#= Returns the current OSC type map of the message.
{
  ($!is64bit ?? %type-map64 !! %type-map32).pairs;
}

method package() returns Buf
#= Returns a Buf of the packed OSC message
{
    self.pack-string($!path)
    ~ self.pack-string(",{ self.type-string() }")
    ~ self!pack-args();
}

#= Map OSC arg types to a packing routine
method !pack-args() returns Blob {
  [~] gather for @!args Z @!type-list -> ($arg, $type) {
    #say "Packing '$arg' of OSC type '$type' with pattern '%pack-map{$type}'";

    given %pack-map{$type} {
      when 'f' {
        take pack-float($arg);
      }
      when 'd' {
        take pack-double($arg);
      }
      when 'i' {
        take pack-int32($arg);
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
method unpackage(Buf $packed-osc)
#= Returns an Net::OSC::Message from a Buf where the content of the Buf is an OSC message
{
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
        @args.push: unpack-float $buf;
        $read-pointer += $buffer-width;
      }
      when $type eq 'd' {
        $buffer-width = 8;
        my $buf = $packed-osc.subbuf($read-pointer, $buffer-width);
        @args.push: unpack-double $buf;
        $read-pointer += $buffer-width;
      }
      when $type eq 'i' {
        $buffer-width = 4;
        my $buf = $packed-osc.subbuf($read-pointer, $buffer-width);

        @args.push: unpack-int32 $buf ;
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

method buf2bin(Buf $bits) returns Array
#= Returns an binary array of the content of a Buf. Useful for debugging.
{
  my @bin;
  for 0 .. ($bits.elems - 1) {
    @bin.push: |sprintf( '%08d', $bits[$_].base(2) ).comb;
  }
  @bin
}

method bits2buf(@bits) returns Buf
#= Returns a Buf from a binary array. Not super useful.
{
  Buf.new: @bits.rotor(8).map: { self.unpack-int($_, :signed(False)) };
}

method pack-string(Str $string) returns Blob
#= Returns a Blob of a string packed for OSC transmission.
{
  ( $string ~ ( "\0" x 4 - ( $string.chars % 4) ) ).encode('ISO-8859-1')
}
