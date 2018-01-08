use v6;

use PDF::Function;

#| /FunctionType 2 - Exponential
#| see [PDF 1.7 Section 3.9.2 Type 2 (Exponential Interpolation) Functions]
class PDF::Function::Exponential
    is PDF::Function {

    use PDF::DAO::Tie;
    # see [PDF 1.7 TABLE 3.37 Additional entries specific to a type 2 function dictionary]
    has Numeric @.C0 is entry;          #| (Optional) An array of n numbers defining the function result when x = 0.0. Default value: [ 0.0 ].
    has Numeric @.C1 is entry;          #| (Optional) An array of n numbers defining the function result when x = 1.0. Default value: [ 1.0 ].
    has Numeric $N is entry(:required); #| (Required) The interpolation exponent. Each input value x will return n values, given by yj = C0j + xN × (C1j − C0j ), for 0 ≤ j < n.
}
