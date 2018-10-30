use v6;

class Net::OSC::Bundle {
  use Numeric::Pack :ALL;
  use Net::OSC::Message;
  our $start-bundle = "#bundle".encode('ISO-8859-1');

  has Net::OSC::Message @.messages handles <push pop shift unshift elems head tail map grep zip rotor kv>;
  has Instant $.time-stamp is rw = now;

  =begin pod

  =head1 NAME

  Net::OSC::Bundle - Implements OSC message bundling and unbundling

  =head1 METHODS

  =begin code
  method new(:@messages, :$time-stamp)
  =end code

  =end pod

  method package( --> Blob)
  #= Packages up a bundle into a Blob, ready for transport over a binary protocol.
  #= The pacakge contains the time-stamp and all messages of the Bundle object.
  {
    my $packed-messaged = gather for @!messages { take .package }
    Buf.new(
      |$start-bundle[], 0x00,
      |self.time-stamper($!time-stamp)[],
      |$packed-messaged.map( {
        |pack-int32(.bytes, :byte-order(big-endian))[], |$_[]
      } )
    )
  }

  method unpackage(Blob:D $bundle --> Net::OSC::Bundle)
  #= Unapackages a Blob into a bundle object.
  #= The blob must begin with #bundle0x00 as defined by the OSC spec.
  {
    $bundle.subbuf(0, 7)[] eq $start-bundle[] or die "Start of bundle is not equal to '{ $start-bundle.decode }' (recieved '{ $bundle.subbuf(0, 7).decode }')!";
    my Instant $time-stamp = self.time-stamp-to-instant: $bundle.subbuf(8, 8);
    my @messages;
    my $pointer = 16;
    while my $size-chunk = $bundle.subbuf($pointer, 4) {
      $pointer += 4;
      if $size-chunk.elems == 4 and my $message-size = unpack-int32($size-chunk, :byte-order(big-endian)) {
        @messages.push: Net::OSC::Message.unpackage( $bundle.subbuf($pointer, $message-size) );
        $pointer += $message-size;
      }
      else {
        #we are out of bytes in our bunlde buffer :)
        last
      }
    }

    self.new(
      :@messages
      :$time-stamp
    );
  }

  method time-stamper(Instant $time --> Buf) {
    given ($time.floor, $time - $time.floor) -> ($int, $fraction) {
      # Offset by the 70 odd years e.g. (70*365 + 17)*86400
      pack-uint32($int + 2208988800, :byte-order(big-endian)) ~ pack-uint32($fraction, :byte-order(big-endian))
    }
  }

  method time-stamp-to-instant(Buf:D $time-stamp --> Instant) {
    # Offset by the 70 odd years e.g. (70*365 + 17)*86400
    Instant.from-posix(unpack-uint32($time-stamp.subbuf(0, 4), :byte-order(big-endian)) - 2208988800) + ('0.' ~ unpack-uint32($time-stamp.subbuf(4, 4), :byte-order(big-endian)))
  }

}
