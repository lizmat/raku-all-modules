use v6;

use PDF::Function;

#| /FunctionType 3 - Stitching
#| see [PDF 1.7 Section 3.9.3 Type 3 (Stitching) Functions]
class PDF::Function::Stitching
    is PDF::Function {

    use PDF::DAO::Tie;

    # see [PDF 1.7 TABLE 3.38 Additional entries specific to a type 3 function dictionary]
    has @.Functions is entry(:required);       #| (Required) An array of k 1-input functions making up the stitching function. The output dimensionality of all functions must be the same, and compatible with the value of Range if Range is present.
    has Numeric @.Bounds is entry(:required);   #| (Required) An array of k − 1 numbers that, in combination with Domain, define the intervals to which each function from the Functions array applies. Bounds elements must be in order of increasing value, and each value must be within the domain defined by Domain.
    has Numeric @.Encode is entry(:required);  #| (Required) An array of 2 × k numbers that, taken in pairs, map each subset of the domain defined by Domain and the Bounds array to the domain of the corresponding function.
}
