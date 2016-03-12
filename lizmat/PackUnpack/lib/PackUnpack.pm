use v6.c;

unit module PackUnpack:ver<0.06>;

my %dispatch;
{
    my int $i = -1;
    %dispatch.ASSIGN-KEY($_,$i = $i + 1)
      for <a A c C h H i I l L n N q Q s S U v V w x X Z>;  # Q fix hl
}
my int $bits = $*KERNEL.bits;

# this need to be conditional on the endianness of the system
my int @NONE;                          # no shifting whatsoever
my int @NET2 = 0x08,0x00;              # short, network (big-endian) order
my int @NET4 = 0x18,0x10,0x08,0x00;                     # long
my int @NET8 = 0x38,0x30,0x28,0x20,0x18,0x10,0x08,0x00; # quad
my int @VAX2 = 0x00,0x08;              # short, VAX (little-endian) order
my int @VAX4 = 0x00,0x08,0x10,0x18;                     # long
my int @VAX8 = 0x00,0x08,0x10,0x18,0x20,0x28,0x30,0x38; # quad
my int @NAT;
my Int $int-bound;
my Int $int-diff;
if $bits == 32 {
    @NAT       = @VAX4;
    $int-bound = 2147483647;
    $int-diff  = 4294967296;
}
else {   # assume 64
    @NAT       = @VAX8;
    $int-bound =  9223372036854775807;
    $int-diff  = 18446744073709551616;
}

# parse a pack/unpack template into ops with additional info
sub parse-pack-template($template) is export {
    my int $i     = -1;
    my int $chars = $template.chars;
    my @template;

    sub is-whitespace(\s) { s eq " " || uniprop(s,'White_Space') } # ) fix hl

    while ($i = $i + 1) < $chars {
        my str $directive = substr($template,$i,1);
        if %dispatch.EXISTS-KEY($directive) {
            my str $repeat = ($i = $i + 1) < $chars
              ?? substr($template,$i,1)
              !! "1";

            if %dispatch.EXISTS-KEY($repeat) {  # repeat is next directive
                @template.push( (%dispatch.AT-KEY($directive),1) );
                $i = $i - 1;  # went one too far
            }
            elsif $repeat eq '*' {
                @template.push( (%dispatch.AT-KEY($directive),$repeat) );
            }
            elsif is-whitespace($repeat) {
                # no action needed, whitespace is ignored
            }
            elsif $repeat.unival === NaN {
                X::Buf::Pack.new(:directive($directive ~ $repeat)).throw;
            }
            else {  # a number
                my $next;
                $repeat = $repeat ~ $next
                  while ($i = $i + 1) < $chars
                    && !(($next = substr($template,$i,1)).unival === NaN);
                @template.push( (%dispatch.AT-KEY($directive),+$repeat) );
                $i = $i - 1; # went one too far
            }
        }
        elsif is-whitespace($directive) {
            # no action needed, whitespace is ignored
        }
        else {
            X::Buf::Pack.new(:$directive).throw;
        }
    }

    @template;
}

proto sub pack(|) is export { * }
multi sub pack(Str $t, |c) { pack(parse-pack-template($t),|c) }
multi sub pack(@template, *@items) {
    my $buf = Buf.new;
    my $repeat;
    my int $pos   = 0;
    my int $elems = @items.elems; 

    sub putabyte(--> Nil) {
        if $pos < $elems {
            my $data = @items.AT-POS($pos++);
            fill($data ~~ Str ?? $data.encode !! $data,0,0);
        }
        else {
            fill((),0,0);
        }
    }
    sub repeat-shift-per-byte(int @shifts --> Nil) {
        if $repeat eq '*' {
            for ^$elems {
                my int $number = @items.AT-POS($pos++);
                $buf.push($number +> $_) for @shifts;
            }
        }
        else {
            for ^$repeat {
                my int $number = $pos < $elems ?? @items.AT-POS($pos++) !! 0;
                $buf.push($number +> $_) for @shifts;
            }
        }
    }
    sub fill($data,\filler,\last-must-be-null --> Nil) {
        my int $i     = -1;
        my int $elems = +$data;
        if $repeat eq "*" {
            $buf.push($data.AT-POS($i)) while ($i = $i + 1) < $elems;
            $buf.push(filler) if last-must-be-null;
        }
        elsif $repeat <= $elems {
            $buf.push($data.AT-POS($i)) while ($i = $i + 1) < $repeat;
            $buf.AT-POS($buf.elems - 1) = 0 if last-must-be-null;
        }
        else {
            $buf.push($data.AT-POS($i)) while ($i = $i + 1) <  $elems;
            $buf.push(filler)           while ($i = $i + 1) <= $repeat;
        }
    }
    sub from-hex(\hex,\flip --> Nil) {
        my int $chars = hex.chars;
        if $chars % 2 {
            hex    = hex ~ '0';
            $chars = $chars + 1;
        }
        my int $i = -2;
        if flip {
            $buf.push( :16(substr(hex,$i,2).flip) )
              while ($i = $i + 2) < $chars;
        }
        else {
            $buf.push( :16(substr(hex,$i,2)) )
              while ($i = $i + 2) < $chars;
        }
    }
    sub ascii() {
        my $data = @items.AT-POS($pos++).ords.cache;
        if $data.first( -> $byte { $byte > 0x7f } ) -> $too-large {
            X::Buf::Pack::NonASCII.new(:char($too-large.chr)).throw;
        }
        $data
    }
    sub one(--> Nil) {
        $buf.push( $pos < $elems ?? @items.AT-POS($pos++) !! 0 )
    }
    sub hex(\flip --> Nil) {
        my int $times = $repeat eq '*' || $repeat > @items - $pos
          ?? @items - $pos
          !! $repeat;
        from-hex(@items.AT-POS($pos++),flip) for ^$times;
    }
    sub encode(--> Nil) {
        my int $times = $repeat eq '*' || $repeat > @items - $pos
          ?? @items - $pos
          !! $repeat;
        $buf.push(@items.AT-POS($pos++).chr.encode.list) for ^$times;
    }
    sub ber(--> Nil) {
        sub ber-encode(Int $val is copy --> Nil) {
            if $val < 0x80 {
                $buf.push($val);
            }
            else {
                my int @bytes = $val +& 0x7f;
                @bytes.unshift($val +& 0x7f +| 0x80)
                  until ($val = $val div 0x80) == 0;
                $buf.push(@bytes);
            }
        }
        my int $times = $repeat eq '*' || $repeat > @items - $pos
          ?? @items - $pos
          !! $repeat;
        ber-encode(@items.AT-POS($pos++)) for ^$times;
    }
    sub pop(--> Nil) {
        unless $repeat eq '*' {
            $repeat <= $buf.elems
              ?? ($buf.pop for ^$repeat)
              !! die "'X' outside of " ~ $buf.^name;
        }
    }

    # make sure this has the same order as the %dispatch initialization
    state @dispatch =
      -> --> Nil { putabyte() },                                    # a
      -> --> Nil { fill( $pos < $elems ?? ascii() !! (),0x20,0) },  # A
      -> --> Nil { one() },                                         # c
      -> --> Nil { one() },                                         # C
      -> --> Nil { hex(0) },                                        # h
      -> --> Nil { hex(1) },                                        # H
      -> --> Nil { repeat-shift-per-byte(@NAT)  },                  # i
      -> --> Nil { repeat-shift-per-byte(@NAT)  },                  # I
      -> --> Nil { repeat-shift-per-byte(@VAX4) },                  # l
      -> --> Nil { repeat-shift-per-byte(@VAX4) },                  # L
      -> --> Nil { repeat-shift-per-byte(@NET2) },                  # n
      -> --> Nil { repeat-shift-per-byte(@NET4) },                  # N
      -> --> Nil { repeat-shift-per-byte(@VAX8) },                  # q
      -> --> Nil { repeat-shift-per-byte(@VAX8) },                  # Q
      -> --> Nil { repeat-shift-per-byte(@VAX2) },                  # s
      -> --> Nil { repeat-shift-per-byte(@VAX2) },                  # S
      -> --> Nil { encode() },                                      # U
      -> --> Nil { repeat-shift-per-byte(@VAX2) },                  # v
      -> --> Nil { repeat-shift-per-byte(@VAX4) },                  # V
      -> --> Nil { ber() },                                         # w
      -> --> Nil { fill((),0,0) unless $repeat eq '*' },            # x
      -> --> Nil { pop() },                                         # X
      -> --> Nil { fill( $pos < $elems ?? ascii() !! (),0x20,1) },  # Z
    ;

    for @template -> $todo {
        $repeat = $todo.AT-POS(1);
        @dispatch.AT-POS($todo.AT-POS(0))();
    }

    $buf
}

proto sub unpack(|) is export { * }
multi sub unpack(Str $t, Blob:D \b) { unpack(parse-pack-template($t),b) }
multi sub unpack(@template, Blob:D \b) {
    my @result;
    my $repeat;
    my int $pos   = 0;
    my int $elems = b.elems; 

    sub abyte() { $pos < $elems ?? b.AT-POS($pos++) !! 0 }
    sub reassemble-string($filler? --> Nil) {
        my @string;
        $repeat = $elems - $pos if $repeat eq "*" || $pos + $repeat > $elems;
        @string.push(b.ATPOS($pos++)) for ^$repeat;

        if defined($filler) {
            my int $i = @string.elems;
            @string.pop
              while ($i = $i - 1) >= 0 && @string.AT-POS($i) == $filler;
        }
        @result.push(chrs(@string));
    }
    sub repeat-reassemble-hex(\flip --> Nil) {
        my str $result = '';
        my int $byte;
        my int $times = $repeat eq "*"
          ?? $elems - $pos
          !! min($repeat, $elems - $pos);

        if flip {
            for ^$times {
                $byte = b.AT-POS($pos++);
                $result = $result
                  ~ ($byte % 16).fmt("%x")
                  ~ ($byte +> 4).fmt("%x");
            }
        }
        else {
            for ^$times {
                $byte = b.AT-POS($pos++);
                $result = $result
                  ~ ($byte +> 4).fmt("%x")
                  ~ ($byte % 16).fmt("%x");
            }
        }

        @result.push($result)
    }
    sub reassemble-Int(int @shifts) {
        if @shifts {
            my Int $result = 0;
            $result = $result +| b.AT-POS($pos++) +< $_ for @shifts;
            $result
        }
        else {
            b.AT-POS($pos++)
        }
    }
    sub repeat-reassemble-uint(int @shifts --> Nil) {
        my int $shifts = @shifts.elems;
        if $repeat eq "*" {
            @result.push(reassemble-Int(@shifts))
              while $pos + $shifts <= $elems;
        }
        else {
            my int $times = min $repeat, ($elems - $pos) / $shifts;
            @result.push(reassemble-Int(@shifts)) for ^$times;
        }
    }
    sub repeat-reassemble-int(int @shifts,\bound,\diff --> Nil) {
        my int $shifts = @shifts.elems;
        my Int $result;
        if $repeat eq "*" {
            while $pos + $shifts <= $elems {
                $result = reassemble-Int(@shifts);
                @result.push($result > bound ?? $result - diff !! $result);
            }
        }
        else {
            my int $times = min $repeat, ($elems - $pos) / $shifts;
            for ^$times {
                $result = reassemble-Int(@shifts);
                @result.push($result > bound ?? $result - diff !! $result);
            }
        }
    }
    sub reassemble-utf8(--> Nil) {
        my int $byte = abyte;
        $byte +> 7 == 0
          ?? @result.push(utf8.new($byte).decode.ord)
          !! $byte +> 5 == 0b110
            ?? @result.push(utf8.new($byte,abyte).decode.ord)
            !! $byte +> 4 == 0b1110
              ?? @result.push(utf8.new($byte,abyte,abyte).decode.ord)
              !! $byte +> 3 == 0b11110
                ?? @result.push(utf8.new($byte,abyte,abyte,abyte).decode.ord)
                !! die "Cannot unpack byte '{sprintf('%#x', $byte)}' using directive 'U'";
    }
    sub reassemble-ber(-->Nil) {
        my int $byte;
        my Int $val = 0;
        $val = ($val + ($byte +& 0x7F)) * 128 until ($byte = abyte) < 0x80;
        @result.push($val + $byte);
    }

    # make sure this has the same order as the %dispatch initialization
    state @dispatch =
      -> --> Nil { reassemble-string() },               # a
      -> --> Nil { reassemble-string(0x20) },           # A
      -> --> Nil {                                      # c
          repeat-reassemble-int(@NONE,127,256)
      },
      -> --> Nil { repeat-reassemble-uint(@NONE) },     # C
      -> --> Nil { repeat-reassemble-hex(1)  },         # h
      -> --> Nil { repeat-reassemble-hex(0)  },         # H
      -> --> Nil {                                      # i
          repeat-reassemble-int(@NAT,$int-bound,$int-diff)
      },
      -> --> Nil { repeat-reassemble-uint(@NAT)  },     # I
      -> --> Nil {                                      # l
          repeat-reassemble-int(@VAX4,2147483647,4294967296)
      },
      -> --> Nil { repeat-reassemble-uint(@VAX4) },     # L
      -> --> Nil { repeat-reassemble-uint(@NET2) },     # n
      -> --> Nil { repeat-reassemble-uint(@NET4) },     # N
      -> --> Nil {                                      # q
          repeat-reassemble-int(@VAX8,9223372036854775807,18446744073709551616)
      },
      -> --> Nil { repeat-reassemble-uint(@VAX8) },     # Q
      -> --> Nil {                                      # s
          repeat-reassemble-int(@VAX2,32767,65536)
      },
      -> --> Nil { repeat-reassemble-uint(@VAX2) },     # S
      -> --> Nil {                                      # U
          $repeat eq "*"
            ?? (reassemble-utf8() while $pos < $elems)
            !! (reassemble-utf8() for ^$repeat);
      },        
      -> --> Nil { repeat-reassemble-uint(@VAX2) },     # v
      -> --> Nil { repeat-reassemble-uint(@VAX4) },     # V
      -> --> Nil {                                      # w
          $repeat eq "*"
            ?? (reassemble-ber() while $pos < $elems)
            !! (reassemble-ber() for ^$repeat);
      },
      -> --> Nil {                                      # x
          $pos = $repeat eq "*"
            ?? $elems
            !! $pos + $repeat < $elems
              ?? $pos + $repeat
              !! die "'x' outside of " ~ b.^name;
      },
      -> --> Nil {                                      # X
          unless $repeat eq "*" {
              $repeat <= $pos
                ?? ($pos = $pos - $repeat)
                !! die "'X' outside of " ~ b.^name;
          }
      },
      -> --> Nil { reassemble-string(0) },              # Z
    ;

    for @template -> $todo {
        $repeat = $todo.AT-POS(1);
        @dispatch.AT-POS($todo.AT-POS(0))();
    }

    @result
}

# vim: ft=perl6 expandtab sw=4
