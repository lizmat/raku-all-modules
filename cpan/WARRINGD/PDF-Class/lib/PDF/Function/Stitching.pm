use v6;

use PDF::Function;

#| /FunctionType 3 - Stitching
#| see [PDF 32000 Section 7.4.10 Type 3 (Stitching) Functions]
class PDF::Function::Stitching
    is PDF::Function {

    # see [PDF 32000 Table 41 -  Additional entries specific to a type 3 function dictionary]
    ## use ISO_32000::Type_3_Function;
    ## also does ISO_32000::Type_3_Function;

    use PDF::COS::Tie;

    has @.Functions is entry(:required);       # (Required) An array of k 1-input functions making up the stitching function. The output dimensionality of all functions must be the same, and compatible with the value of Range if Range is present.
    has Numeric @.Bounds is entry(:required);   # (Required) An array of k − 1 numbers that, in combination with Domain, define the intervals to which each function from the Functions array applies. Bounds elements must be in order of increasing value, and each value must be within the domain defined by Domain.
    has Numeric @.Encode is entry(:required);  # (Required) An array of 2 × k numbers that, taken in pairs, map each subset of the domain defined by Domain and the Bounds array to the domain of the corresponding function.

    class Transform
        is PDF::Function::Transform {
        has Range @.bounds is required;
        has Range @.encode is required;
        has PDF::Function::Transform @.functions is required;
        has UInt $!k;

        submethod TWEAK {
            die "stitching function should have one input"
                unless self.domain.elems == 1;
            $!k = @!functions.elems;
            die "Encode array length does not match Functions array"
                unless @!encode == $!k;
            die "bounds array length error"
                unless @!bounds.elems == $!k;
        }

        method calc(@in where .elems == 1) {
            my Numeric $x = self.clip(@in[0], @.domain[0]);
            my UInt $i = @!bounds.pairs.first({.value.min <= $x <= .value.max}).key;
            my Numeric $e = $.interpolate($x, @.bounds[$i], @.encode[$i]);
            my @out = @!functions[$i].calc([$e]);
            @out = [(@out Z @.range).map: { self.clip(.[0], .[1]) }]
                if @.range;
            @out;
        }
    }

    method calculator {
        my Range @domain = @.Domain.map: -> $a, $b { Range.new($a, $b) };
        my Range @range = do with $.Range {
            .map: -> $a, $b { Range.new($a, $b) }
        }
        my Range @encode = do given $.Encode {
            .keys.map: -> $k1, $k2 { .[$k1] .. .[$k2] }
        }
        my Range @bounds;
        my PDF::Function::Transform @functions = @.Functions.map: { .calculator };
        my $k = @functions.elems;
        my @Bounds = @.Bounds;
        die "Bounds array length error: {@Bounds.elems} != {$k-1}"
            unless @Bounds.elems == $k-1;
        @bounds[0] = @domain[0].min .. @Bounds[0];
        for 1 ..^ ($k-1) {
            @bounds[$_] = @Bounds[$_-1] .. @Bounds[$_];
        }
        @bounds[$k-1] = @Bounds[$k-2] .. @domain[0].max;
        Transform.new: :@domain, :@range, :@encode, :@functions, :@bounds;
    }
    #| run the calculator function
    method calc(@in) {
        $.calculator.calc(@in);
    }
}
