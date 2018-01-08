use v6;

use PDF::Content::XObject;
use PDF::Content::Graphics;
use PDF::Content::Resourced;

role PDF::Pattern
    does PDF::Content::XObject['Form']
    does PDF::Content::Graphics
    does PDF::Content::Resourced {

    use PDF::DAO;
    use PDF::DAO::Tie;
    use PDF::DAO::Name;
    #| /Type entry is optional, but should be /Pattern when present
    my subset Name-Pattern of PDF::DAO::Name where 'Pattern';
    has Name-Pattern $.Type is entry;
    my subset PatternTypeInt of Int where 1|2;
    has PatternTypeInt $.PatternType is entry(:required);  #| (Required) A code identifying the type of pattern that this dictionary describes; must be 1 for a tiling pattern, or 2 for a shading pattern.
    has Numeric @.Matrix is entry(:len(6));                #| (Optional) An array of six numbers specifying the pattern matrix (see Section 4.6.1, “General Properties of Patterns”). Default value: the identity matrix [ 1 0 0 1 0 0 ].

    my enum PatternTypes is export(:PatternTypes) « :Tiling(1) :Shading(2) »;
    my constant PatternNames = %( PatternTypes.enums.invert );

    method type    { 'Pattern' }
    method subtype { PatternNames[ self<PatternType> ] }

    #| see also PDF::Class::Loader
    method delegate-pattern(Hash :$dict!) {

	use PDF::DAO::Util :from-ast;
	my Int $type-int = from-ast $dict<PatternType>;

	unless $type-int ~~ PatternTypeInt {
	    note "unknown /PatternType $dict<PatternType> - supported range is 1..7";
	    return self.WHAT;
	}

	my $subtype = PatternNames{~$type-int};
	PDF::DAO.loader.find-delegate( 'Pattern', $subtype );
    }

    method cb-init {

        for self.^mro {
            my Str $class-name = .^name;

            if $class-name ~~ /^ 'PDF::' (\w+) ['::' (\w+)]? $/ {
                my Str $type-name = ~$0;

                if self<Type>:exists {
                    # /Type already set. check it agrees with the class name
                    die "conflict between class-name $class-name ($type-name) and dictionary /Type /{self<Type>}"
                        unless self<Type> eq $.type;
                }

                if $1 {
                    my Str $subtype = ~$1;
		    die "$class-name has unknown subtype $subtype"
			unless PatternTypes.enums{$subtype}:exists;

		    self<PatternType> //= PatternTypes.enums{$subtype};

		    die "conflict between class-name $class-name ($subtype) and /PatternType /{self<PatternType>.value}"
			unless self<PatternType> == PatternTypes.enums{$subtype};
                }

                last;
            }
        }

    }

}
