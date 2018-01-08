use v6;

use PDF::DAO::Stream;

#| /FunctionType 1..7 - the Function dictionary delegates

class PDF::Function
    is PDF::DAO::Stream {

    use PDF::DAO::Tie;

    # see TABLE 3.35 Entries common to all function dictionaries

    subset FunctionTypeInt of UInt where 0|2|3|4;

    has FunctionTypeInt $.FunctionType is entry(:required);
    has Numeric @.Domain is entry(:required);  #| (Required) An array of 2 × m numbers, where m is the number of input values. For each i from 0 to m − 1
    has Numeric @.Range is entry;              #| (Required for type 0 and type 4 functions, optional otherwise; see below) An array of 2 × n numbers, where n is the number of output values.

    # from PDF Spec 1.7 table 3.35
    constant FunctionTypes = <Sampled n/a Exponential Stitching PostScript>;
    constant FunctionNames = %( FunctionTypes.pairs.invert );
    method type {'Function'}
    method subtype { FunctionTypes[ $.FunctionType ] }

    #| see also PDF::Class::Loader
    method delegate-function(Hash :$dict!) {

	use PDF::DAO::Util :from-ast;
	my UInt $function-type = from-ast $dict<FunctionType>;

	unless $function-type ~~ FunctionTypeInt {
	    note "unknown /FunctionType $dict<FunctionType> - supported range is 0,2,3,4";
	    return self.WHAT;
	}

	my $subtype = FunctionTypes[$function-type];
	PDF::DAO.loader.find-delegate( 'Function', $subtype );
    }

    method cb-init {
        for self.^mro {
            my Str $class-name = .^name;

            if $class-name ~~ /^ 'PDF::' (\w+) ['::' (\w+)]? $/ {
		my Str $type = ~$0;
		my Str $function = ~$1
		    if $1;

		die "invalid function class: $class-name"
		    unless $type eq $.type
		    && $function
		    && (FunctionNames{ $function }:exists);

		my FunctionTypeInt $function-type = FunctionNames{ $function };

		self<FunctionType> //= $function-type;

		die "conflict between class-name $class-name /FunctionType. Expected $function-type, got self<FunctionType>"
		    unless self<FunctionType> == $function-type;

                last;
            }
        }

    }
}
