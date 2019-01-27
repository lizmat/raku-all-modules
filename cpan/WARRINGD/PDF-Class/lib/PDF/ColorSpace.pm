use v6;

use PDF::COS::Array;

class PDF::ColorSpace
    is PDF::COS::Array {

    # See [PDF 32000 Section 8.6.3 Color Space Families]

    use PDF::COS::Name;
    use PDF::COS::Tie;

    has PDF::COS::Name $.Subtype is index(0, :required);

    method type {'ColorSpace'}
    method subtype {$.Subtype}
    #| enforce tie-ins between self[0] & the class name. e.g.
    #| PDF::ColorSpace::CalGray should have self[0] == 'CalGray'
    method cb-init {
        for self.^mro {
            my Str $class-name = .^name;

            if $class-name ~~ /^ 'PDF::' (\w+) '::' (\w+) $/ {

		die "bad class-name $class-name: $class-name"
		    unless ~$0 eq $.type;

                my Str $subtype = ~$1;

		self[0] //= PDF::COS.coerce( :name($subtype) );

		die "conflict between class-name $class-name ($subtype) and array[0] type /{self[0]}"
		    unless self.Subtype eq $subtype;

		self[1] //= { :WhitePoint[ 1.0, 1.0, 1.0 ] };

                last;
            }
        }
    }
}
