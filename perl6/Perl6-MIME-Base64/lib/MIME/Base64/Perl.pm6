use v6;
unit class MIME::Base64::Perl;

# 6 bit encoding - 64 characters needed
# note: range operator removed due to current jvm failures
my @encoding-chars = <A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 + />;

my %decode-values;
for 0..63 -> $i {
    %decode-values{@encoding-chars[$i]} = $i;
}

class EncodedData {
    has @!chars;
    has $!linelen = 0;
    has $.maxlen = 76;
    has $.newline = "\n";

    method add-byte($b) {
        self.add-char(@encoding-chars[$b]);
    }

    method add-char($x) {
        @!chars.push($x);
        $!linelen++;
        if self.maxlen && $!linelen >= self.maxlen {
            $!linelen = 0;
            @!chars.push(self.newline);
        }
    }

    method Str {
        return @!chars.join;
    }
}

method encode(Blob $data, :$oneline --> Str){
    my $encoded = EncodedData.new;
    if $oneline {
        $encoded.maxlen = 0;
    }
    my $linelen = 0;
    for $data.list -> $byte1, $byte2?, $byte3? {
        # first 6 bits of 1
        $encoded.add-byte(($byte1 +& 0xFC) +> 2);
        if $byte2.defined {
            # last 2 bits of 1, first 4 of 2
            $encoded.add-byte((($byte1 +& 0x03) +< 4) +| (($byte2 +& 0xF0) +> 4));
            if $byte3.defined {
                # last 4 bits of 2, first 2 of 3
                $encoded.add-byte((($byte2 +& 0x0F) +< 2) +| (($byte3 +& 0xC0) +> 6));
                # last 6 bits of 3
                $encoded.add-byte($byte3 +& 0x3F);
            } else {
                # last 4 bits of 2 (remaining 2 bits unset)
                $encoded.add-byte(($byte2 +& 0x0F) +< 2);
                $encoded.add-char('=');
            }
        } else {
            # last 2 bits of 1 (remaining 4 bits unset)
            $encoded.add-byte(($byte1 +& 0x03) +< 4);
            $encoded.add-char('=');
            $encoded.add-char('=');
        }
    }
    return ~$encoded;
}

method decode(Str $encoded --> Buf){
    my @decoded;
    
    my $extra;
    my $spaceleft = 8;
    my $padcount = 0;
    for $encoded.comb -> $char {
        my $val = %decode-values{$char};
        if $val ~~ Int {
            if $spaceleft == 8 {
                # grab the first 6 bits
                $spaceleft = 2;
                $extra = $val +< 2;
            } elsif $spaceleft == 2 {
                # grab the top two bits, complete a byte...
                @decoded.push($extra +| (($val +& 0x30) +> 4));

                # and start the next byte with the 4 remaining bits
                $spaceleft = 4;
                $extra = ($val +& 0x0F) +< 4;
            } elsif $spaceleft == 4 {
                # grab the top 4 bits, complete a byte...
                @decoded.push($extra +| (($val +& 0x3C) +> 2));

                # and start the next byte with the 2 remaining bits
                $spaceleft = 6;
                $extra = ($val +& 0x03) +< 6;
            } elsif $spaceleft == 6 {
                # complete a byte with a 6-bit char
                @decoded.push($extra +| $val);
                $spaceleft = 8;
            }
        }
        if $char eq '=' {
            $padcount++;
        }
    }
    return Buf.new(@decoded);
}
