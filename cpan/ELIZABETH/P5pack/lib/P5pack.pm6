use v6.c;

unit module P5pack:ver<0.0.7>:auth<cpan:ELIZABETH>;

my %dispatch;
BEGIN {
    my int $i = -1;
    %dispatch.ASSIGN-KEY($_,$i = $i + 1)
      for <a A c C h H i I l L n N q Q s S U v V w x X Z>;
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

my $parse-lock := Lock.new;
my %parsed-templates;

# parse a pack/unpack template into ops with additional info
my sub parse-pack-template($template) {
    sub parse($template) {
        my @template;
        my int $i     = -1;
        my int $chars = $template.chars;

        sub is-whitespace($s) { $s eq " " || ?($s ~~ / \s /) }

        while ++$i < $chars {
            my str $directive = substr($template,$i,1);
            if %dispatch.EXISTS-KEY($directive) {
                my str $repeat = ++$i < $chars
                  ?? substr($template,$i,1)
                  !! "1";

                if %dispatch.EXISTS-KEY($repeat) { # next is another directive
                    @template.push( (%dispatch.AT-KEY($directive),1) );
                    --$i;  # went one too far
                }
                elsif $repeat eq '*' {
                    @template.push( (%dispatch.AT-KEY($directive),$repeat) );
                }
                elsif is-whitespace($repeat) {
                    @template.push( (%dispatch.AT-KEY($directive),1) );
                    # no further action needed, whitespace is ignored
                }
                elsif $repeat.unival === NaN {
                    X::Buf::Pack.new(:directive($directive ~ $repeat)).throw;
                }
                else {  # a number
                    my $next;
                    $repeat = $repeat ~ $next
                      while ++$i < $chars
                        && !(($next = substr($template,$i,1)).unival === NaN);
                    @template.push( (%dispatch.AT-KEY($directive),+$repeat) );
                    --$i; # went one too far
                }
            }
            elsif is-whitespace($directive) {
                # no action needed, whitespace is ignored
            }
            else {
                X::Buf::Pack.new(:$directive).throw;
            }
        }

        @template
    }

    # make sure we don't have a race condition getting the template
    $parse-lock.protect: {
        %parsed-templates.AT-KEY($template)
          // %parsed-templates.BIND-KEY($template,parse($template))
    }
}

my sub pack($template, *@items) is export {

    my @template := parse-pack-template($template);
    my $buf      := Buf.new;
    my int $pos   = 0;
    my int $elems = @items.elems;
    my $repeat;

    sub put-a-byte(--> Nil) {
        if $pos < $elems {
            my $data = @items.AT-POS($pos++);
            fill($data ~~ Str ?? $data.encode !! $data,0,0)
        }
        else {
            fill((),0,0)
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
            $buf.push($data.AT-POS($i)) while ++$i < $elems;
            $buf.push(filler) if last-must-be-null;
        }
        elsif $repeat <= $elems {
            $buf.push($data.AT-POS($i)) while ++$i < $repeat;
            $buf.AT-POS($buf.elems - 1) = 0 if last-must-be-null;
        }
        else {
            $buf.push($data.AT-POS($i)) while ++$i <  $elems;
            $buf.push(filler)           while ++$i <= $repeat;
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
        $buf.push( $pos < $elems ?? @items.AT-POS($pos++) !! 0 ) for ^$repeat
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
                $buf.append(@bytes);
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
    my @dispatch =
      -> --> Nil { put-a-byte() },                                  # a
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

my sub unpack($template, Blob:D \b) is export {

    my @template := parse-pack-template($template);
    my @result;
    my int $pos   = 0;
    my int $elems = b.elems;
    my $repeat;

    sub abyte() { $pos < $elems ?? b.AT-POS($pos++) !! 0 }
    sub reassemble-string($filler? --> Nil) {
        my @string;
        $repeat = $elems - $pos if $repeat eq "*" || $pos + $repeat > $elems;
        @string.push(b.AT-POS($pos++)) for ^$repeat;

        with $filler {
            my int $i = @string.elems;
            @string.pop while --$i >= 0 && @string.AT-POS($i) == $filler;
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
    my @dispatch =
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

=begin pod

=head1 NAME

P5times - Implement Perl 5's pack()/unpack() built-ins

=head1 SYNOPSIS

  use P5pack; # exports pack(), unpack()

=head1 DESCRIPTION

Implements Perl 5's C<pack>/C<unpack> functionality in Perl 6.

Currently supported directives are: a A c C h H i I l L n N q Q s S U v V w x Z

=head1 ORIGINAL PERL 5 DOCUMENTATION

    pack TEMPLATE,LIST
            Takes a LIST of values and converts it into a string using the
            rules given by the TEMPLATE. The resulting string is the
            concatenation of the converted values. Typically, each converted
            value looks like its machine-level representation. For example, on
            32-bit machines an integer may be represented by a sequence of 4
            bytes, which will in Perl be presented as a string that's 4
            characters long.

            See perlpacktut for an introduction to this function.

            The TEMPLATE is a sequence of characters that give the order and
            type of values, as follows:

                a  A string with arbitrary binary data, will be null padded.
                A  A text (ASCII) string, will be space padded.
                Z  A null-terminated (ASCIZ) string, will be null padded.

                b  A bit string (ascending bit order inside each byte,
                   like vec()).
                B  A bit string (descending bit order inside each byte).
                h  A hex string (low nybble first).
                H  A hex string (high nybble first).

                c  A signed char (8-bit) value.
                C  An unsigned char (octet) value.
                W  An unsigned char value (can be greater than 255).

                s  A signed short (16-bit) value.
                S  An unsigned short value.

                l  A signed long (32-bit) value.
                L  An unsigned long value.

                q  A signed quad (64-bit) value.
                Q  An unsigned quad value.
                     (Quads are available only if your system supports 64-bit
                      integer values _and_ if Perl has been compiled to support
                      those.  Raises an exception otherwise.)

                i  A signed integer value.
                I  A unsigned integer value.
                     (This 'integer' is _at_least_ 32 bits wide.  Its exact
                      size depends on what a local C compiler calls 'int'.)

                n  An unsigned short (16-bit) in "network" (big-endian) order.
                N  An unsigned long (32-bit) in "network" (big-endian) order.
                v  An unsigned short (16-bit) in "VAX" (little-endian) order.
                V  An unsigned long (32-bit) in "VAX" (little-endian) order.

                j  A Perl internal signed integer value (IV).
                J  A Perl internal unsigned integer value (UV).

                f  A single-precision float in native format.
                d  A double-precision float in native format.

                F  A Perl internal floating-point value (NV) in native format
                D  A float of long-double precision in native format.
                     (Long doubles are available only if your system supports
                      long double values _and_ if Perl has been compiled to
                      support those.  Raises an exception otherwise.)

                p  A pointer to a null-terminated string.
                P  A pointer to a structure (fixed-length string).

                u  A uuencoded string.
                U  A Unicode character number.  Encodes to a character in char-
                   acter mode and UTF-8 (or UTF-EBCDIC in EBCDIC platforms) in
                   byte mode.

                w  A BER compressed integer (not an ASN.1 BER, see perlpacktut
                   for details).  Its bytes represent an unsigned integer in
                   base 128, most significant digit first, with as few digits
                   as possible.  Bit eight (the high bit) is set on each byte
                   except the last.

                x  A null byte (a.k.a ASCII NUL, "\000", chr(0))
                X  Back up a byte.
                @  Null-fill or truncate to absolute position, counted from the
                   start of the innermost ()-group.
                .  Null-fill or truncate to absolute position specified by
                   the value.
                (  Start of a ()-group.

            One or more modifiers below may optionally follow certain letters
            in the TEMPLATE (the second column lists letters for which the
            modifier is valid):

                !   sSlLiI     Forces native (short, long, int) sizes instead
                               of fixed (16-/32-bit) sizes.

                !   xX         Make x and X act as alignment commands.

                !   nNvV       Treat integers as signed instead of unsigned.

                !   @.         Specify position as byte offset in the internal
                               representation of the packed string.  Efficient
                               but dangerous.

                >   sSiIlLqQ   Force big-endian byte-order on the type.
                    jJfFdDpP   (The "big end" touches the construct.)

                <   sSiIlLqQ   Force little-endian byte-order on the type.
                    jJfFdDpP   (The "little end" touches the construct.)

            The ">" and "<" modifiers can also be used on "()" groups to force
            a particular byte-order on all components in that group, including
            all its subgroups.

            The following rules apply:

            *   Each letter may optionally be followed by a number indicating
                the repeat count. A numeric repeat count may optionally be
                enclosed in brackets, as in "pack("C[80]", @arr)". The repeat
                count gobbles that many values from the LIST when used with
                all format types other than "a", "A", "Z", "b", "B", "h", "H",
                "@", ".", "x", "X", and "P", where it means something else,
                described below. Supplying a "*" for the repeat count instead
                of a number means to use however many items are left, except
                for:

                *   "@", "x", and "X", where it is equivalent to 0.

                *   <.>, where it means relative to the start of the string.

                *   "u", where it is equivalent to 1 (or 45, which here is
                    equivalent).

                One can replace a numeric repeat count with a template letter
                enclosed in brackets to use the packed byte length of the
                bracketed template for the repeat count.

                For example, the template "x[L]" skips as many bytes as in a
                packed long, and the template "$t X[$t] $t" unpacks twice
                whatever $t (when variable-expanded) unpacks. If the template
                in brackets contains alignment commands (such as "x![d]"), its
                packed length is calculated as if the start of the template
                had the maximal possible alignment.

                When used with "Z", a "*" as the repeat count is guaranteed to
                add a trailing null byte, so the resulting string is always
                one byte longer than the byte length of the item itself.

                When used with "@", the repeat count represents an offset from
                the start of the innermost "()" group.

                When used with ".", the repeat count determines the starting
                position to calculate the value offset as follows:

                *   If the repeat count is 0, it's relative to the current
                    position.

                *   If the repeat count is "*", the offset is relative to the
                    start of the packed string.

                *   And if it's an integer n, the offset is relative to the
                    start of the nth innermost "( )" group, or to the start of
                    the string if n is bigger then the group level.

                The repeat count for "u" is interpreted as the maximal number
                of bytes to encode per line of output, with 0, 1 and 2
                replaced by 45. The repeat count should not be more than 65.

            *   The "a", "A", and "Z" types gobble just one value, but pack it
                as a string of length count, padding with nulls or spaces as
                needed. When unpacking, "A" strips trailing whitespace and
                nulls, "Z" strips everything after the first null, and "a"
                returns data with no stripping at all.

                If the value to pack is too long, the result is truncated. If
                it's too long and an explicit count is provided, "Z" packs
                only "$count-1" bytes, followed by a null byte. Thus "Z"
                always packs a trailing null, except when the count is 0.

            *   Likewise, the "b" and "B" formats pack a string that's that
                many bits long. Each such format generates 1 bit of the
                result. These are typically followed by a repeat count like
                "B8" or "B64".

                Each result bit is based on the least-significant bit of the
                corresponding input character, i.e., on "ord($char)%2". In
                particular, characters "0" and "1" generate bits 0 and 1, as
                do characters "\000" and "\001".

                Starting from the beginning of the input string, each 8-tuple
                of characters is converted to 1 character of output. With
                format "b", the first character of the 8-tuple determines the
                least-significant bit of a character; with format "B", it
                determines the most-significant bit of a character.

                If the length of the input string is not evenly divisible by
                8, the remainder is packed as if the input string were padded
                by null characters at the end. Similarly during unpacking,
                "extra" bits are ignored.

                If the input string is longer than needed, remaining
                characters are ignored.

                A "*" for the repeat count uses all characters of the input
                field. On unpacking, bits are converted to a string of 0s and
                1s.

            *   The "h" and "H" formats pack a string that many nybbles (4-bit
                groups, representable as hexadecimal digits, "0".."9"
                "a".."f") long.

                For each such format, pack() generates 4 bits of result. With
                non-alphabetical characters, the result is based on the 4
                least-significant bits of the input character, i.e., on
                "ord($char)%16". In particular, characters "0" and "1"
                generate nybbles 0 and 1, as do bytes "\000" and "\001". For
                characters "a".."f" and "A".."F", the result is compatible
                with the usual hexadecimal digits, so that "a" and "A" both
                generate the nybble "0xA==10". Use only these specific hex
                characters with this format.

                Starting from the beginning of the template to pack(), each
                pair of characters is converted to 1 character of output. With
                format "h", the first character of the pair determines the
                least-significant nybble of the output character; with format
                "H", it determines the most-significant nybble.

                If the length of the input string is not even, it behaves as
                if padded by a null character at the end. Similarly, "extra"
                nybbles are ignored during unpacking.

                If the input string is longer than needed, extra characters
                are ignored.

                A "*" for the repeat count uses all characters of the input
                field. For unpack(), nybbles are converted to a string of
                hexadecimal digits.

            *   The "p" format packs a pointer to a null-terminated string.
                You are responsible for ensuring that the string is not a
                temporary value, as that could potentially get deallocated
                before you got around to using the packed result. The "P"
                format packs a pointer to a structure of the size indicated by
                the length. A null pointer is created if the corresponding
                value for "p" or "P" is "undef"; similarly with unpack(),
                where a null pointer unpacks into "undef".

                If your system has a strange pointer size--meaning a pointer
                is neither as big as an int nor as big as a long--it may not
                be possible to pack or unpack pointers in big- or
                little-endian byte order. Attempting to do so raises an
                exception.

            *   The "/" template character allows packing and unpacking of a
                sequence of items where the packed structure contains a packed
                item count followed by the packed items themselves. This is
                useful when the structure you're unpacking has encoded the
                sizes or repeat counts for some of its fields within the
                structure itself as separate fields.

                For "pack", you write length-item"/"sequence-item, and the
                length-item describes how the length value is packed. Formats
                likely to be of most use are integer-packing ones like "n" for
                Java strings, "w" for ASN.1 or SNMP, and "N" for Sun XDR.

                For "pack", sequence-item may have a repeat count, in which
                case the minimum of that and the number of available items is
                used as the argument for length-item. If it has no repeat
                count or uses a '*', the number of available items is used.

                For "unpack", an internal stack of integer arguments unpacked
                so far is used. You write "/"sequence-item and the repeat
                count is obtained by popping off the last element from the
                stack. The sequence-item must not have a repeat count.

                If sequence-item refers to a string type ("A", "a", or "Z"),
                the length-item is the string length, not the number of
                strings. With an explicit repeat count for pack, the packed
                string is adjusted to that length. For example:

                 This code:                             gives this result:

                 unpack("W/a", "\004Gurusamy")          ("Guru")
                 unpack("a3/A A*", "007 Bond  J ")      (" Bond", "J")
                 unpack("a3 x2 /A A*", "007: Bond, J.") ("Bond, J", ".")

                 pack("n/a* w/a","hello,","world")     "\000\006hello,\005world"
                 pack("a/W2", ord("a") .. ord("z"))    "2ab"

                The length-item is not returned explicitly from "unpack".

                Supplying a count to the length-item format letter is only
                useful with "A", "a", or "Z". Packing with a length-item of
                "a" or "Z" may introduce "\000" characters, which Perl does
                not regard as legal in numeric strings.

            *   The integer types "s", "S", "l", and "L" may be followed by a
                "!" modifier to specify native shorts or longs. As shown in
                the example above, a bare "l" means exactly 32 bits, although
                the native "long" as seen by the local C compiler may be
                larger. This is mainly an issue on 64-bit platforms. You can
                see whether using "!" makes any difference this way:

                    printf "format s is %d, s! is %d\n",
                        length pack("s"), length pack("s!");

                    printf "format l is %d, l! is %d\n",
                        length pack("l"), length pack("l!");

                "i!" and "I!" are also allowed, but only for completeness'
                sake: they are identical to "i" and "I".

                The actual sizes (in bytes) of native shorts, ints, longs, and
                long longs on the platform where Perl was built are also
                available from the command line:

                    $ perl -V:{short,int,long{,long}}size
                    shortsize='2';
                    intsize='4';
                    longsize='4';
                    longlongsize='8';

                or programmatically via the "Config" module:

                       use Config;
                       print $Config{shortsize},    "\n";
                       print $Config{intsize},      "\n";
                       print $Config{longsize},     "\n";
                       print $Config{longlongsize}, "\n";

                $Config{longlongsize} is undefined on systems without long
                long support.

            *   The integer formats "s", "S", "i", "I", "l", "L", "j", and "J"
                are inherently non-portable between processors and operating
                systems because they obey native byteorder and endianness. For
                example, a 4-byte integer 0x12345678 (305419896 decimal) would
                be ordered natively (arranged in and handled by the CPU
                registers) into bytes as

                    0x12 0x34 0x56 0x78  # big-endian
                    0x78 0x56 0x34 0x12  # little-endian

                Basically, Intel and VAX CPUs are little-endian, while
                everybody else, including Motorola m68k/88k, PPC, Sparc, HP
                PA, Power, and Cray, are big-endian. Alpha and MIPS can be
                either: Digital/Compaq uses (well, used) them in little-endian
                mode, but SGI/Cray uses them in big-endian mode.

                The names big-endian and little-endian are comic references to
                the egg-eating habits of the little-endian Lilliputians and
                the big-endian Blefuscudians from the classic Jonathan Swift
                satire, Gulliver's Travels. This entered computer lingo via
                the paper "On Holy Wars and a Plea for Peace" by Danny Cohen,
                USC/ISI IEN 137, April 1, 1980.

                Some systems may have even weirder byte orders such as

                   0x56 0x78 0x12 0x34
                   0x34 0x12 0x78 0x56

                You can determine your system endianness with this
                incantation:

                   printf("%#02x ", $_) for unpack("W*", pack L=>0x12345678);

                The byteorder on the platform where Perl was built is also
                available via Config:

                    use Config;
                    print "$Config{byteorder}\n";

                or from the command line:

                    $ perl -V:byteorder

                Byteorders "1234" and "12345678" are little-endian; "4321" and
                "87654321" are big-endian.

                For portably packed integers, either use the formats "n", "N",
                "v", and "V" or else use the ">" and "<" modifiers described
                immediately below. See also perlport.

            *   Starting with Perl 5.10.0, integer and floating-point formats,
                along with the "p" and "P" formats and "()" groups, may all be
                followed by the ">" or "<" endianness modifiers to
                respectively enforce big- or little-endian byte-order. These
                modifiers are especially useful given how "n", "N", "v", and
                "V" don't cover signed integers, 64-bit integers, or
                floating-point values.

                Here are some concerns to keep in mind when using an
                endianness modifier:

                *   Exchanging signed integers between different platforms
                    works only when all platforms store them in the same
                    format. Most platforms store signed integers in
                    two's-complement notation, so usually this is not an
                    issue.

                *   The ">" or "<" modifiers can only be used on
                    floating-point formats on big- or little-endian machines.
                    Otherwise, attempting to use them raises an exception.

                *   Forcing big- or little-endian byte-order on floating-point
                    values for data exchange can work only if all platforms
                    use the same binary representation such as IEEE
                    floating-point. Even if all platforms are using IEEE,
                    there may still be subtle differences. Being able to use
                    ">" or "<" on floating-point values can be useful, but
                    also dangerous if you don't know exactly what you're
                    doing. It is not a general way to portably store
                    floating-point values.

                *   When using ">" or "<" on a "()" group, this affects all
                    types inside the group that accept byte-order modifiers,
                    including all subgroups. It is silently ignored for all
                    other types. You are not allowed to override the
                    byte-order within a group that already has a byte-order
                    modifier suffix.

            *   Real numbers (floats and doubles) are in native machine format
                only. Due to the multiplicity of floating-point formats and
                the lack of a standard "network" representation for them, no
                facility for interchange has been made. This means that packed
                floating-point data written on one machine may not be readable
                on another, even if both use IEEE floating-point arithmetic
                (because the endianness of the memory representation is not
                part of the IEEE spec). See also perlport.

                If you know exactly what you're doing, you can use the ">" or
                "<" modifiers to force big- or little-endian byte-order on
                floating-point values.

                Because Perl uses doubles (or long doubles, if configured)
                internally for all numeric calculation, converting from double
                into float and thence to double again loses precision, so
                "unpack("f", pack("f", $foo)") will not in general equal $foo.

            *   Pack and unpack can operate in two modes: character mode ("C0"
                mode) where the packed string is processed per character, and
                UTF-8 mode ("U0" mode) where the packed string is processed in
                its UTF-8-encoded Unicode form on a byte-by-byte basis.
                Character mode is the default unless the format string starts
                with "U". You can always switch mode mid-format with an
                explicit "C0" or "U0" in the format. This mode remains in
                effect until the next mode change, or until the end of the
                "()" group it (directly) applies to.

                Using "C0" to get Unicode characters while using "U0" to get
                non-Unicode bytes is not necessarily obvious. Probably only
                the first of these is what you want:

                    $ perl -CS -E 'say "\x{3B1}\x{3C9}"' |
                      perl -CS -ne 'printf "%v04X\n", $_ for unpack("C0A*", $_)'
                    03B1.03C9
                    $ perl -CS -E 'say "\x{3B1}\x{3C9}"' |
                      perl -CS -ne 'printf "%v02X\n", $_ for unpack("U0A*", $_)'
                    CE.B1.CF.89
                    $ perl -CS -E 'say "\x{3B1}\x{3C9}"' |
                      perl -C0 -ne 'printf "%v02X\n", $_ for unpack("C0A*", $_)'
                    CE.B1.CF.89
                    $ perl -CS -E 'say "\x{3B1}\x{3C9}"' |
                      perl -C0 -ne 'printf "%v02X\n", $_ for unpack("U0A*", $_)'
                    C3.8E.C2.B1.C3.8F.C2.89

                Those examples also illustrate that you should not try to use
                "pack"/"unpack" as a substitute for the Encode module.

            *   You must yourself do any alignment or padding by inserting,
                for example, enough "x"es while packing. There is no way for
                pack() and unpack() to know where characters are going to or
                coming from, so they handle their output and input as flat
                sequences of characters.

            *   A "()" group is a sub-TEMPLATE enclosed in parentheses. A
                group may take a repeat count either as postfix, or for
                unpack(), also via the "/" template character. Within each
                repetition of a group, positioning with "@" starts over at 0.
                Therefore, the result of

                    pack("@1A((@2A)@3A)", qw[X Y Z])

                is the string "\0X\0\0YZ".

            *   "x" and "X" accept the "!" modifier to act as alignment
                commands: they jump forward or back to the closest position
                aligned at a multiple of "count" characters. For example, to
                pack() or unpack() a C structure like

                    struct {
                        char   c;    /* one signed, 8-bit character */
                        double d;
                        char   cc[2];
                    }

                one may need to use the template "c x![d] d c[2]". This
                assumes that doubles must be aligned to the size of double.

                For alignment commands, a "count" of 0 is equivalent to a
                "count" of 1; both are no-ops.

            *   "n", "N", "v" and "V" accept the "!" modifier to represent
                signed 16-/32-bit integers in big-/little-endian order. This
                is portable only when all platforms sharing packed data use
                the same binary representation for signed integers; for
                example, when all platforms use two's-complement
                representation.

            *   Comments can be embedded in a TEMPLATE using "#" through the
                end of line. White space can separate pack codes from each
                other, but modifiers and repeat counts must follow
                immediately. Breaking complex templates into individual
                line-by-line components, suitably annotated, can do as much to
                improve legibility and maintainability of pack/unpack formats
                as "/x" can for complicated pattern matches.

            *   If TEMPLATE requires more arguments than pack() is given,
                pack() assumes additional "" arguments. If TEMPLATE requires
                fewer arguments than given, extra arguments are ignored.

            Examples:

                $foo = pack("WWWW",65,66,67,68);
                # foo eq "ABCD"
                $foo = pack("W4",65,66,67,68);
                # same thing
                $foo = pack("W4",0x24b6,0x24b7,0x24b8,0x24b9);
                # same thing with Unicode circled letters.
                $foo = pack("U4",0x24b6,0x24b7,0x24b8,0x24b9);
                # same thing with Unicode circled letters.  You don't get the
                # UTF-8 bytes because the U at the start of the format caused
                # a switch to U0-mode, so the UTF-8 bytes get joined into
                # characters
                $foo = pack("C0U4",0x24b6,0x24b7,0x24b8,0x24b9);
                # foo eq "\xe2\x92\xb6\xe2\x92\xb7\xe2\x92\xb8\xe2\x92\xb9"
                # This is the UTF-8 encoding of the string in the
                # previous example

                $foo = pack("ccxxcc",65,66,67,68);
                # foo eq "AB\0\0CD"

                # NOTE: The examples above featuring "W" and "c" are true
                # only on ASCII and ASCII-derived systems such as ISO Latin 1
                # and UTF-8.  On EBCDIC systems, the first example would be
                #      $foo = pack("WWWW",193,194,195,196);

                $foo = pack("s2",1,2);
                # "\001\000\002\000" on little-endian
                # "\000\001\000\002" on big-endian

                $foo = pack("a4","abcd","x","y","z");
                # "abcd"

                $foo = pack("aaaa","abcd","x","y","z");
                # "axyz"

                $foo = pack("a14","abcdefg");
                # "abcdefg\0\0\0\0\0\0\0"

                $foo = pack("i9pl", gmtime);
                # a real struct tm (on my system anyway)

                $utmp_template = "Z8 Z8 Z16 L";
                $utmp = pack($utmp_template, @utmp1);
                # a struct utmp (BSDish)

                @utmp2 = unpack($utmp_template, $utmp);
                # "@utmp1" eq "@utmp2"

                sub bintodec {
                    unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
                }

                $foo = pack('sx2l', 12, 34);
                # short 12, two zero bytes padding, long 34
                $bar = pack('s@4l', 12, 34);
                # short 12, zero fill to position 4, long 34
                # $foo eq $bar
                $baz = pack('s.l', 12, 4, 34);
                # short 12, zero fill to position 4, long 34

                $foo = pack('nN', 42, 4711);
                # pack big-endian 16- and 32-bit unsigned integers
                $foo = pack('S>L>', 42, 4711);
                # exactly the same
                $foo = pack('s<l<', -42, 4711);
                # pack little-endian 16- and 32-bit signed integers
                $foo = pack('(sl)<', -42, 4711);
                # exactly the same

            The same template may generally also be used in unpack().

    unpack TEMPLATE,EXPR
    unpack TEMPLATE
            "unpack" does the reverse of "pack": it takes a string and expands
            it out into a list of values. (In scalar context, it returns
            merely the first value produced.)

            If EXPR is omitted, unpacks the $_ string. See perlpacktut for an
            introduction to this function.

            The string is broken into chunks described by the TEMPLATE. Each
            chunk is converted separately to a value. Typically, either the
            string is a result of "pack", or the characters of the string
            represent a C structure of some kind.

            The TEMPLATE has the same format as in the "pack" function. Here's
            a subroutine that does substring:

                sub substr {
                    my($what,$where,$howmuch) = @_;
                    unpack("x$where a$howmuch", $what);
                }

            and then there's

                sub ordinal { unpack("W",$_[0]); } # same as ord()

            In addition to fields allowed in pack(), you may prefix a field
            with a %<number> to indicate that you want a <number>-bit checksum
            of the items instead of the items themselves. Default is a 16-bit
            checksum. Checksum is calculated by summing numeric values of
            expanded values (for string fields the sum of "ord($char)" is
            taken; for bit fields the sum of zeroes and ones).

            For example, the following computes the same number as the System
            V sum program:

                $checksum = do {
                    local $/;  # slurp!
                    unpack("%32W*",<>) % 65535;
                };

            The following efficiently counts the number of set bits in a bit
            vector:

                $setbits = unpack("%32b*", $selectmask);

            The "p" and "P" formats should be used with care. Since Perl has
            no way of checking whether the value passed to "unpack()"
            corresponds to a valid memory location, passing a pointer value
            that's not known to be valid is likely to have disastrous
            consequences.

            If there are more pack codes or if the repeat count of a field or
            a group is larger than what the remainder of the input string
            allows, the result is not well defined: the repeat count may be
            decreased, or "unpack()" may produce empty strings or zeros, or it
            may raise an exception. If the input string is longer than one
            described by the TEMPLATE, the remainder of that input string is
            ignored.

=head1 PORTING CAVEATS

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5pack . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan and an earlier
version that only lived in the Perl 6 Ecosystem.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
