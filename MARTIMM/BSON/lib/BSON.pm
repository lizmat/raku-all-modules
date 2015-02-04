class BSON:ver<0.5.1>;

use BSON::ObjectId;


method encode ( %h ) {

    return self._document( %h );
}

method decode ( Buf $b ) {

    return self._document( $b.list );
}


# BSON Document
# document ::= int32 e_list "\x00"

# The int32 is the total number of bytes comprising the document.

multi method _document ( %h ) {
    
    my $l = self._e_list( %h.pairs );

    return self._int32( $l.elems + 5 ) ~ $l ~ Buf.new( 0x00 );
}

multi method _document ( Array $a ) {

    my $s = $a.elems;

    my $i = self._int32( $a );

    my %h = self._e_list( $a );

    die 'Parse error' unless $a.shift ~~ 0x00;

    die 'Parse error' unless $s ~~ $a.elems + $i;

    return %h;
}


# Sequence of elements
# e_list ::= element e_list
# | ""

multi method _e_list ( *@p ) {

    my Buf $b = Buf.new( );

    for @p -> $p {
        $b = $b ~ self._element( $p );
    }

    return $b;
}

multi method _e_list ( Array $a ) {

    my @p;
    while $a[ 0 ] !~~ 0x00 {
        push @p, self._element( $a );
    }

    return @p;
}

multi method _element ( Pair $p ) {

    given $p.value {

        when Str {
            # UTF-8 string
            # "\x02" e_name string

            return Buf.new( 0x02 ) ~ self._e_name( $p.key ) ~ self._string( $p.value );
        }

        when Hash {
            # Embedded document
            # "\x03" e_name document

            return Buf.new( 0x03 ) ~  self._e_name( $p.key ) ~ self._document( $_ );
        }

        when Array {
            # Array
            # "\x04" e_name document

            # The document for an array is a normal BSON document
            # with integer values for the keys,
            # starting with 0 and continuing sequentially.
            # For example, the array ['red', 'blue']
            # would be encoded as the document {'0': 'red', '1': 'blue'}.
            # The keys must be in ascending numerical order.

            my %h = .kv;

            return Buf.new( 0x04 ) ~  self._e_name( $p.key ) ~ self._document( %h );
        }

        when Buf {
            # Binary data
            # "\x05" e_name int32 subtype byte*
            # subtype is '\x00' for the moment (Generic binary subtype)
            #
            return [~] Buf.new( 0x05 ),
                       self._e_name( $p.key ),
                       self._binary( 0x00, $_);
        }

        when BSON::ObjectId {
            # ObjectId
            # "\x07" e_name (byte*12)

            return Buf.new( 0x07 ) ~ self._e_name( $p.key ) ~ .Buf;
        }

        when Bool {

            if .Bool {
                # Boolean "true"
                # "\x08" e_name "\x01

                return Buf.new( 0x08 ) ~ self._e_name( $p.key ) ~ Buf.new( 0x01 );
            }
            else {
                # Boolean "false"
                # "\x08" e_name "\x00

                return Buf.new( 0x08 ) ~ self._e_name( $p.key ) ~ Buf.new( 0x00 );
            }

        }

        when not .defined {
            # Null value
            # "\x0A" e_name

            return Buf.new( 0x0A ) ~ self._e_name( $p.key );
        }

        when Int {
            # 32-bit Integer
            # "\x10" e_name int32

            return Buf.new( 0x10 ) ~ self._e_name( $p.key ) ~ self._int32( $p.value );
        }

        default {

            die 'Sorry, not yet supported type: ' ~ .WHAT;
        }

    }

}

# Test elements see http://bsonspec.org/spec.html
#
# Basic types are;
#
# byte 	        1 byte (8-bits)
# int32 	4 bytes (32-bit signed integer, two's complement)
# int64 	8 bytes (64-bit signed integer, two's complement)
# double 	8 bytes (64-bit IEEE 754 floating point)
#
multi method _element ( Array $a ) {

    # Type is given in first byte.
    #
    given $a.shift {


        when 0x01 {
            # Double precision 
            # "\x01" e_name Num

            return self._e_name( $a ) => self._double64( $a );
        }

        when 0x02 {
            # UTF-8 string
            # "\x02" e_name string

            return self._e_name( $a ) => self._string( $a );
        }

        when 0x03 {
            # Embedded document
            # "\x03" e_name document

            return self._e_name( $a )  => self._document( $a );
        }

        when 0x04 {
            # Array
            # "\x04" e_name document

            # The document for an array is a normal BSON document
            # with integer values for the keys,
            # starting with 0 and continuing sequentially.
            # For example, the array ['red', 'blue']
            # would be encoded as the document {'0': 'red', '1': 'blue'}.
            # The keys must be in ascending numerical order.

            return self._e_name( $a ) => [ self._document( $a ).values ];
        }

        when 0x05 {
            # Binary
            # "\x05 e_name int32 subtype byte*
            # subtype = byte \x00 .. \x05, \x80
            
            return self._e_name( $a ) => self._binary( $a );
        }

        when 0x06 {
            # Undefined and deprecated
            # parse error
            
            die "Parse error. Undefined(0x06) is deprecated.";
        }

        when 0x07 {
            # ObjectId
            # "\x07" e_name (byte*12)

            my $n = self._e_name( $a );

            my @a;
            @a.push( $a.shift ) for ^ 12;

            return $n => BSON::ObjectId.new( Buf.new( @a ) );
        }

        when 0x08 {
            my $n = self._e_name( $a );

            given $a.shift {

                when 0x01 {
                    # Boolean "true"
                    # "\x08" e_name "\x01

                    return $n => Bool::True;
                }

                when 0x00 {
                    # Boolean "false"
                    # "\x08" e_name "\x00

                    return $n => Bool::False;
                }

                default {

                    die 'Parse error';
                }

            }

        }

        when 0x0A {
            # Null value
            # "\x0A" e_name

            return self._e_name( $a ) => Any;
        }

        when 0x10 {
            # 32-bit Integer
            # "\x10" e_name int32

            return self._e_name( $a ) => self._int32( $a );
        }

        default {

            # Number of bytes must be taken from $a otherwise a parse
            # error will occur later on.
            #
            return X::NYI.new(feature => "Type $_")
#            die 'Sorry, not yet supported type: ' ~ $_;
        }

    }

}


# Binary buffer
#
multi method _binary ( Int $sub_type, Buf $b ) {

     return [~] self._int32($b.elems), Buf.new( $sub_type, $b.list);
}

multi method _binary ( Array $a ) {

    # Get length
    my $lng = self._int32( $a );
    
    # Get subtype
    my $sub_type = $a.shift;

    # Most of the tests are not necessary because of arbitrary sizes.
    # UUID and MD5 can be tested.
    #
    given $sub_type {
        when 0x00 {
            # Generic binary subtype
        }

        when 0x01 {
            # Function
        }
        
        when 0x02 {
            # Binary (Old - deprecated)
            die 'Code (0x02) Deprecated binary data';
        }
        
        when 0x03 {
            # UUID (Old - deprecated)
            die 'UUID(0x03) Deprecated binary data';
        }

        when 0x04 {
            # UUID. According to http://en.wikipedia.org/wiki/Universally_unique_identifier
            # the universally unique identifier is a 128-bit (16 byte) value.
            die 'UUID(0x04) Binary string parse error' unless $lng ~~ 16;
        }
        
        when 0x05 {
            # MD5. This is a 16 byte number (32 character hex string)
            die 'UUID(0x04) Binary string parse error' unless $lng ~~ 16;
        }

        when 0x80 {
            # User defined. That is, all other codes 0x80 .. 0xFF
        }
    }

    # Just return part of the array.
    return Buf.new( $a.splice( 0, $lng));
}



# 4 bytes (32-bit signed integer)
multi method _int32 ( Int $i ) {
    
    return Buf.new( $i % 0x100, $i +> 0x08 % 0x100, $i +> 0x10 % 0x100, $i +> 0x18 % 0x100 );
}

multi method _int32 ( Array $a ) {

    return [+] $a.shift, $a.shift +< 0x08, $a.shift +< 0x10, $a.shift +< 0x18;
}

# 8 bytes (64-bit number)
multi method _double64 ( Num $r ) {
    
    my $sign = $r.sign == -1 ?? True !! False;
    
    my $exponent = 1023;
    my @bits = $r.base(2).split('');
#say $r.base(2);
    if @bits[0] eq 0 {
        # Remove first two characters '0.'.
        @bits.splice( 0, 2),

        do for @bits -> $bit {
            if $bit eq '0' {
                $exponent--;

                # remove the 0 character
                @bits.shift;
            }
            
            else {
                $exponent--;

                # remove the 1 character
                @bits.shift;
                last;
            }
        }
    }
    
    else {
        my $idx = 0;
        do for @bits -> $bit {
            if $bit eq '.' {
                # Remove the dot
                @bits.splice( $idx, 1);
                $exponent++;
                last;
            }
            
            else {
                $idx++;
                $exponent++;
            }
        }

        # Remove the first 1
        @bits.shift;
    }


#say "E: $exponent, ", $exponent.fmt('%04X');;

    my Int $i = $sign ?? 0x8000_0000_0000_0000 !! 0;
    $i = $i +| ($exponent +< 52);
    my $bit-pattern = 1 +< 51;
    do for @bits -> $bit {
        $i = $i +| $bit-pattern if $bit eq '1';

        $bit-pattern = $bit-pattern +> 1;
    }

#say "I: ", $i.fmt('%16x');
    my Buf $a = self._int64($i);
    
    return $a;
}

# We have to do some simulation using the information on
# http://en.wikipedia.org/wiki/Double-precision_floating-point_format#Endianness
# until better times come.
#
multi method _double64 ( Array $a ) {

    # Test special cases
    #
    # 0x 0000 0000 0000 0000 = 0
    # 0x 8000 0000 0000 0000 = -0
    # 0x 7ff0 0000 0000 0000 = Inf
    # 0x fff0 0000 0000 0000 = -Inf

    my Int $i = self._int64( $a );
    my Bool $sign = $i +& 63 ?? True !! False;

    # Significand + implicit bit
    my $significand =  0x10000000000000 +| ($i +& 0xFFFFFFFFFFFFF);

    # Exponent - bias (1023) - the number of bits for precision
    my $exponent = (($i +& 0x7FF0000000000000) +> 52) - 1023 - 52;

#say sprintf( "I: %016x -> %x, %x, %x", $i, $significand, $exponent, $sign);
#say "E: {$exponent-52}";

    my Num $value = Num.new((2 ** $exponent) * $significand);
#say "V: $value: ", $value == Inf ?? Inf !! $value.base(2);

    return $value; #X::NYI.new(feature => "Type Double");
}

# 8 bytes (64-bit int)
multi method _int64 ( Int $i ) {
    
    return Buf.new( $i % 0x100, $i +> 0x08 % 0x100, $i +> 0x10 % 0x100
                  , $i +> 0x18 % 0x100, $i +> 0x20 % 0x100, $i +> 0x28 % 0x100
                  , $i +> 0x30 % 0x100, $i +> 0x38 % 0x100
                  );
}

multi method _int64 ( Array $a ) {

    return [+] $a.shift, $a.shift +< 0x08, $a.shift +< 0x10, $a.shift +< 0x18
             , $a.shift +< 0x20, $a.shift +< 0x28, $a.shift +< 0x30
             , $a.shift +< 0x38
             ;
}


# Key name
# e_name ::= cstring

multi method _e_name ( Str $s ) {

    return self._cstring( $s );
}

multi method _e_name ( Array $a ) {

    return self._cstring( $a );
}


# String
# string ::= int32 (byte*) "\x00"

# The int32 is the number bytes in the (byte*) + 1 (for the trailing '\x00').
# The (byte*) is zero or more UTF-8 encoded characters.

multi method _string ( Str $s ) {

    my $b = $s.encode( 'UTF-8' );
    return self._int32( $b.bytes + 1 ) ~ $b ~ Buf.new( 0x00 );
}

multi method _string ( Array $a ) {

    my $i = self._int32( $a );

    my @a;
    @a.push( $a.shift ) for ^ ( $i - 1 );
    
    die 'Parse error' unless $a.shift ~~ 0x00;

    return Buf.new( @a ).decode( );
}


# CString
# cstring ::= (byte*) "\x00"

# Zero or more modified UTF-8 encoded characters followed by '\x00'.
# The (byte*) MUST NOT contain '\x00', hence it is not full UTF-8.

multi method _cstring ( Str $s ) {

    die "Forbidden 0x00 sequence in $s" if $s ~~ /\x00/;

    return $s.encode( ) ~ Buf.new( 0x00 );
}

multi method _cstring ( Array $a ) {

    my @a;
    while $a[ 0 ] !~~ 0x00 {
        @a.push( $a.shift );
    }

    die 'Parse error' unless $a.shift ~~ 0x00;

    return Buf.new( @a ).decode( );
}
