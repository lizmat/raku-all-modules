unit module Digest::PSHA1;

use Digest::SHA;
use Digest::HMAC;

our sub psha1($clientbytes is copy, $serverbytes is copy, int $keysize = 256) is export {
    $clientbytes = $clientbytes.encode('ascii') unless $clientbytes ~~ Blob;
    $serverbytes = $serverbytes.encode('ascii') unless $serverbytes ~~ Blob;

    my int $sizebytes           = $keysize div 8;
    my int $sha1digestsizebytes = 160 div 8; # 160 is the length of sha1 digest

    my Blob $buffer1 = $serverbytes;
    my Blob $buffer2;
    my Buf $pshabuffer = Buf.new;

    my Int $i = 0;
    my Blob $temp;

    while $i < $sizebytes {
        $buffer1 = hmac($clientbytes, $buffer1, &sha1, 64);
        $buffer2 = $buffer1.subbuf(0, $sha1digestsizebytes) ~ $serverbytes;
        $temp    = hmac($clientbytes, $buffer2, &sha1, 64);

        for 0..^$temp.elems -> $x {
            if $i < $sizebytes {
                $pshabuffer[$i] = $temp[$x];
                $i++;
            }
            else {
                last;
            }
        }
    }

    $pshabuffer
}

our sub psha1-hex($clientbytes, $serverbytes, $keysize = 64) is export {
    psha1($clientbytes, $serverbytes, $keysize).list».fmt("%02x").join;
}
