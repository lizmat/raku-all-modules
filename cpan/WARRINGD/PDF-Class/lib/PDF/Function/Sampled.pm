use v6;

use PDF::Function;

#| /FunctionType 0 - Sampled
#| see [PDF 1.7 Section 3.9.1 Type 0 (Sampled) Functions]
class PDF::Function::Sampled
    is PDF::Function {

    use PDF::DAO::Tie;
    # see [PDF 1.7 TABLE 3.36 Additional entries specific to a type 0 function dictionary]

    has UInt @.Size is entry(:required);  #| (Required) An array of m positive integers specifying the number of samples in each input dimension of the sample table.

    subset Sample of Int where 1|2|4|8|16|24|32;
    has Sample $.BitsPerSample is entry(:required); #| (Required) The number of bits used to represent each sample. (If the function has multiple output values, each one occupies BitsPerSample bits.) Valid values are 1, 2, 4, 8, 12, 16, 24, and 32.

    subset OrderInt of Int where 1|3;
    has OrderInt $.Order is entry;        #| (Optional) The order of interpolation between samples. Valid values are 1 and 3, specifying linear and cubic spline interpolation, respectively.

    has Numeric @.Encode is entry;        #| (Optional) An array of 2 × m numbers specifying the linear mapping of input values into the domain of the function’s sample table. Default value: [ 0 (Size0 − 1) 0 (Size1 − 1) … ].

    has Numeric @.Decode is entry;        #| (Optional) An array of 2 × n numbers specifying the linear mapping of sample values into the range appropriate for the function’s output values. Default value: same as the value of Range.

    # (Optional) Other attributes of the stream that provides the sample values, as appropriate

    use PDF::IO::Util :pack;
    class Transform
        is PDF::Function::Transform {
        has UInt $.bpc is required;
        has UInt @.size is required;
        has Range @.encode = @!size.map: { 0..$_ };
        has Range @.decode = self.range;
        has Blob $.samples is required;
        has UInt $!m;
        has UInt $!n;

        submethod TWEAK {
            $!m = self.domain.elems;
            $!n = self.range.elems;
            die "size/domain lengths differ" unless +@!size == $!m;
            die "encode/domain lengths differ" unless +@!encode == $!m;
            die "decode/range lengths differ" unless +@!decode == $!n;
        }

        method !base-index(@e) {
            my Int $index = 0;
            my $factor = $!n;
            for 0 ..^ $!m -> \x {
                $index += @e[x].floor * $factor;
                $factor *= @!size[x];
            }
            $index;
        }

        method !approximate(@e) {
            my \index = self!base-index(@e);
            my \n-samples = $!samples.elems;
            my @base = (0 ..^ $!n).map: -> \y { $!samples[index + y] }
            my @samples = @base.list;
            my $offset = $!n;
            for 0 ..^ $!m -> \x {
                my \weight = @e[x] - @e[x].floor;
                unless weight =~= 0 {
                    my \neighbour = index + $offset;
                    last if neighbour >= n-samples;
                    for 0 ..^ $!n -> \y {
                        my \this = $!samples[neighbour + y];
                        @samples[y] += (this - @base[y]) * weight;
                    }
                }
                $offset *= @!size[x];
            }
            @samples;
        }

        method calc(@in where .elems == $!m) {
            my Numeric @x = (@in.list Z @.domain).map: { $.clip(.[0], .[1]) };
            my Numeric @e = (@x Z @.domain Z @!encode).map: { $.interpolate(.[0], .[1], .[2]) };
            @e = (@e Z @!size).map: { $.clip(.[0], 0 .. (.[1]-1)) }
            my @samples = self!approximate(@e);
            my @out = (0 ..^ $!n).map: -> \y {
                $.interpolate(@samples[y], 0 .. 2 ** $!bpc - 1, @!decode[y]);
            }
            [(@out Z @.range).map: { $.clip(.[0], .[1]) }];
        }
    }
    method calculator {
        my Range @domain = @.Domain.map: -> $a, $b { Range.new($a, $b) };
        my Range @range = @.Range.map: -> $a, $b { Range.new($a, $b) };
        my @size = @.Size;
        my Range @encode = do with $.Encode {
            .keys.map: -> $k1, $k2 { .[$k1] .. .[$k2] }
        }
        else {
            @size.map: { 0 .. ($_-1) };
        }
        my Range @decode = do with $.Decode {
            .keys.map: -> $k1, $k2 { .[$k1] .. .[$k2] }
        }
        else {
            @range;
        }
        my $bpc = $.BitsPerSample;
        my Blob $samples = unpack($.decoded, $bpc);

        Transform.new: :@domain, :@range, :@size, :@encode, :@decode, :$samples, :$bpc;
    }
    #| run the calculator function
    method calc(@in) {
        $.calculator.calc(@in);
    }
}
