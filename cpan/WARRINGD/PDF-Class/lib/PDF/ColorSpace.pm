use v6;

use PDF::DAO::Array;

class PDF::ColorSpace
    is PDF::DAO::Array {

    # See [PDF 1.7 Section 4.5 Color Spaces]

    use PDF::DAO::Name;
    use PDF::DAO::Tie;
    has PDF::DAO::Name $.Subtype is index(0, :required);

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

		self[0] //= PDF::DAO.coerce( :name($subtype) );

		die "conflict between class-name $class-name ($subtype) and array[0] type /{self[0]}"
		    unless self.Subtype eq $subtype;

		self[1] //= { :WhitePoint[ 1.0, 1.0, 1.0 ] };

                last;
            }
        }
    }
}
