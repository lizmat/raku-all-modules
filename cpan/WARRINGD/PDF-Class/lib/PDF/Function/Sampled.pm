use v6;

use PDF::Function;

#| /FunctionType 0 - Sampled
# see [PDF 1.7 Section 3.9.1 Type 0 (Sampled) Functions]
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
}
