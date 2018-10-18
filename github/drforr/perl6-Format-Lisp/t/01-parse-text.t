use v6;

use Test;
use Format::Lisp;

plan 28;

my $fl = Format::Lisp.new;

#
# It may not be apparent why I'm sorting on the last character. Mostly it's
# because figuring out what directive the first dirctive of a string is
# amounts to building a fairly complex regexp.
#

# XXX No !" tests?
# XXX No "" tests?
# XXX No #" tests?
# XXX No $" tests?

subtest {
	my @options =
		Q{X~#%},
		Q{X~V%},
		Q{~#%},
		Q{~%},
		Q{~@_A~%},
		Q{~V%},
		Q{~~~D%},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, '%';

subtest {
	my @options =
		Q{X~%~&},
		Q{X~&},
		Q{X~v&},
		Q{X~~~D&},
		Q{~#&},
		Q{~&},
		Q{~0&},
		Q{~v&},
		Q{~~~D&},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, '&';

# XXX No `" tests?

subtest {
	my @options =
		Q{(~:@{~A~:^,~})},
		Q{(~:{~A~:^,~})},
		Q{(~A ~A)},
		Q{~(XXyy~AuuVV~)},
		Q{~(aBc ~(def~) GHi~)},
		Q{~(aBc ~:(def~) GHi~)},
		Q{~(aBc ~@(def~) GHi~)},
		Q{~(~c~)},
		Q{~:(aBc ~(def~) GHi~)},
		Q{~:(aBc ~:(def~) GHi~)},
		Q{~:(aBc ~@(def~) GHi~)},
		Q{~:(aBc ~@:(def~) GHi~)},
		Q{~:(this is a TEST.~)},
		Q{~:(this is7a TEST.~)},
		Q{~:@(aBc ~(def~) GHi~)},
		Q{~:@(aBc ~@(def~) GHi~)},
		Q{~:@(this is AlSo A teSt~)},
		Q{~@(!@#$%^&*this is a TEST.~)},
		Q{~@(aBc ~(def~) GHi~)},
		Q{~@(aBc ~:(def~) GHi~)},
		Q{~@(aBc ~@(def~) GHi~)},
		Q{~@(aBc ~@:(def~) GHi~)},
		Q{~@(this is a TEST.~)},
		Q{~@:(aBc ~:(def~) GHi~)},
		Q{~@:(aBc ~@:(def~) GHi~)},
		Q{~@:(~c~)},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, ')';

# XXX No *" tests?
# XXX No +" tests?

subtest {
	my @options =
		Q{'~c,},
		Q{~d,},
		Q{~~~d,},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, ',';

# XXX No -" tests?
# XXX No ." tests?

subtest {
	my @options =
		Q{~',@/cl-test::function-for-format-slash-19/},
		Q{~'X:/cl-test::function-for-format-slash-19/},
		Q{~-1@/cl-test::function-for-format-slash-19/},
		Q{~/CL-TEST::FUNCTION-FOR-FORMAT-SLASH-9/},
		Q{~/PPRINT-LINEAR/},
		Q{~/cL-tESt:FUNCTION:FOR::FORMAT:SLASH:11/},
		Q{~/cl-test::function-for-format-slash-19/},
		Q{~/cl-test:FUNCTION-FOR-FORMAT-SLASH-10/},
		Q{~/pPrINt-lINeaR/},
		Q{~/pprint-linear/},
		Q{~1,2,3,4,5,6,7,8,9,10@/cl-test::function-for-format-slash-19/},
		Q{~18@:/cl-test::function-for-format-slash-19/},
		Q{~:/cl-test::function-for-format-slash-19/},
		Q{~:/pprint-linear/},
		Q{~:@/cl-test::function-for-format-slash-19/},
		Q{~@/cl-test::function-for-format-slash-19/},
		Q{~@/pprint-linear/},
		Q{~@:/cl-test::function-for-format-slash-19/},
		Q{~@:/pprint-linear/},
		Q{~v,v,v,v,v,v,v,v,v,v@/cl-test::function-for-format-slash-19/},
		Q{~v/cl-test::function-for-format-slash-19/},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, '/';

# XXX No [0-9]" tests?
# XXX No :" tests?
# XXX No ;" tests?
# XXX No <" tests?
# XXX No =" tests?

subtest {
	my @options =
		Q{XXX~<MMM~-1I~:@_MMMMM~:>},
		Q{XXX~<MMM~1I~:@_MMMMM~:>},
		Q{XXX~<MMM~I~:@_MMMMM~:>},
		Q{XXX~<MMM~vI~:@_MMMMM~:>},
		Q{XXX~<MMM~vI~:@_MMMMM~:>},
		Q{~%X ~,,1<~%X ~:;AAA~;BBB~;CCC~>},
		Q{~%X ~<~%X ~0,30:;AAA~>~<~%X ~0,30:;BBB~>~<~%X ~0,30:;CCC~>},
		Q{~%X ~<~%X ~0,3:;AAA~>,~<~%X ~0,3:;BBB~>,~<~%X ~0,3:;CCC~>},
		Q{~%X ~<~%X ~0,3:;AAA~>~<~%X ~0,3:;BBB~>~<~%X ~0,3:;CCC~>},
		Q{~,,1,',<~A~;~A~>},
		Q{~,,1,v<~A~;~A~>},
		Q{~,,1<~A~;~A~>},
		Q{~,,2<~A~;~A~>},
		Q{~,,v<~A~;~A~>},
		Q{~,v<~A~;~A~>},
		Q{~,v<~A~>},
		Q{~10:<abcdef~>},
		Q{~10:@<abcdef~>},
		Q{~10@<abcdef~>},
		Q{~13,,2<aaa~;bbb~;ccc~>},
		Q{~4@<~>},
		Q{~5:@<~>},
		Q{~6:<~>},
		Q{~6<abc~;def~^~>},
		Q{~6@<abc~;def~^~>},
		Q{~:<MMM~I~:@_MMMMM~:>},
		Q{~:<M~-1:i~:@_M~:>},
		Q{~:<M~-2:i~:@_M~:>},
		Q{~:<M~1:I~@:_M~:>},
		Q{~:<[~;~@{~A~^/~}~:>},
		Q{~:<[~;~@{~A~^/~}~;]~:>},
		Q{~:<~;~@{~A~^/~}~;]~:>},
		Q{~:<~@{~A~^ ~}~:>},
		Q{~:<~@{~A~^*~}~:>},
		Q{~:<~A~:>},
		Q{~:@<**~@;~@{~A~^       ~}~:@>},
		Q{~:@<~@{~A~^            ~:_~}~:>},
		Q{~:@<~@{~A~^            ~}~:@>},
		Q{~:@<~@{~A~^ ~_~}~:>},
		Q{~:@<~@{~A~^ ~}~:@>},
		Q{~:@<~@{~A~^~}~:@>},
		Q{~:@<~A~:>},
		Q{~<(~;M~-1:i~:@_M~;)~:>},
		Q{~<(~;M~:I~:@_M~;)~:>},
		Q{~<(~;M~v:i~:@_M~;)~:>},
		Q{~<ABC~;~v,0:T~;DEF~:>},
		Q{~<MMM~1I~:@_MMMMM~:>},
		Q{~<MMM~I~:@_MMMMM~:>},
		Q{~<M~3:i~:@_M~:>},
		Q{~<M~:i~:@_M~:>},
		Q{~<XXXXXX~;YYYYYYY~^~;ZZZZZ~>},
		Q{~<XXXXXX~;YYYYYYY~^~>},
		Q{~<XXXXXX~^~>},
		Q{~<XXXX~;~v,1:@t~:>},
		Q{~<XXX~;~,1:@t~;YYY~:>},
		Q{~<XXX~;~1,1:@t~;YYY~:>},
		Q{~<XXX~;~1,:@t~;YYY~:>},
		Q{~<XXX~;~1:@t~;YYY~:>},
		Q{~<XXX~;~:@t~;YYY~:>},
		Q{~<X~;~0,v:T~;Y~:>},
		Q{~<[~;XXXX~2,0:T~;]~:>},
		Q{~<[~;~,0:T~;]~:>},
		Q{~<[~;~0,0:T~;]~:>},
		Q{~<[~;~0,1:T~;]~:>},
		Q{~<[~;~0,:T~;]~:>},
		Q{~<[~;~0:T~;]~:>},
		Q{~<[~;~1,0:T~;]~:>},
		Q{~<[~;~2,0:T~;]~:>},
		Q{~<~/pprint-tabular/~:>},
		Q{~<~4:/pprint-tabular/~:>},
		Q{~<~:/pprint-tabular/~:>},
		Q{~<~:@/pprint-tabular/~:>},
		Q{~<~;~A~:>},
		Q{~<~;~A~;~:>},
		Q{~<~<XXXXXX~;YYYYYYY~^~>~>},
		Q{~<~<~A~^xxx~:>yyy~:>},
		Q{~<~>},
		Q{~<~@/pprint-tabular/~:>},
		Q{~<~@{~A~^*~}~:>},
		Q{~<~A~:>},
		Q{~<~A~;~A~>},
		Q{~<~A~>},
		Q{~<~A~^xxxx~:>},
		Q{~<~v:/pprint-tabular/~:>},
		Q{~@:<~@{~A~^ ~:_~}~:>},
		Q{~@:<~@{~A~^ ~}~:>},
		Q{~@:<~A~:>},
		Q{~@<**~@;~@{~A~^       ~}~:@>},
		Q{~@<**~@;~@{~A~^       ~}~;XX~:@>},
		Q{~@<~;~A~:>},
		Q{~@<~;~A~;~:>},
		Q{~@<~@{~A~^ ~_~}~:>},
		Q{~@<~@{~A~^*~}~:>},
		Q{~@<~A~:>},
		Q{~A~<~A~v,v:t~:>},
		Q{~A~<~v,v:@t~:>},
		Q{~A~~<~A~~~D,~D:T~~:>}, # Actually not a <>
		Q{~v,,,v<~A~>},
		Q{~v,,v<~A~>},
		Q{~v<~A~>},
		Q{~~~d,,,'~c<~~A~~>}, # Actually not a <>
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, '>';

subtest {
	my @options =
		Q{~?},
		Q{~@?},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, '?';

subtest {
	my @options =
		Q{~#,#@A},
		Q{~#,#A},
		Q{~#@A},
		Q{~#@a},
		Q{~#A},
		Q{~#a},
		Q{~-100000000000000000000a},
		Q{~-100A},
		Q{~10,,,v@A},
		Q{~10,,,v@a},
		Q{~10,,,vA},
		Q{~10,,,va},
		Q{~3,,+2A},
		Q{~3,,-1A},
		Q{~3,,0A},
		Q{~3,,v@A},
		Q{~3,,vA},
		Q{~3,1a},
		Q{~3,3@a},
		Q{~4,#@A},
		Q{~4,#A},
		Q{~4,,,'X@a},
		Q{~4,,,'XA},
		Q{~4,,,@A},
		Q{~4,,,a},
		Q{~4,,va},
		Q{~4,3a},
		Q{~4,4@a},
		Q{~5,#@A},
		Q{~5,#a},
		Q{~5,3@a},
		Q{~5,3A},
		Q{~5,v@A},
		Q{~5,vA},
		Q{~7,3@a},
		Q{~7,3A},
		Q{~:A},
		Q{~:a},
		Q{~? ~A},
		Q{~@? ~A},
		Q{~@A},
		Q{~@[X~]Y~A},
		Q{~@a},
		Q{~@{~2,#^~A~}X~A},
		Q{~AY~?X~A},
		Q{~AY~@?X~A},
		Q{~A},
		Q{~A~*~A},
		Q{~A~0*~A},
		Q{~A~1{~A~*~A~}~A},
		Q{~A~1{~A~0*~A~}~A},
		Q{~A~1{~A~:*~A~}~A},
		Q{~A~1{~A~A~A~2:*~A~A~}~A},
		Q{~A~1{~A~A~A~:*~A~}~A},
		Q{~A~1{~A~A~v@*~A~A~}~A},
		Q{~A~:*~A},
		Q{~A~?X~A},
		Q{~A~@?X~A},
		Q{~A~A~0:*~A},
		Q{~A~A~1@*~A~A},
		Q{~A~A~2:*~A},
		Q{~A~A~2@*~A~A},
		Q{~A~A~3@*~A~A},
		Q{~A~A~:*~A},
		Q{~A~A~@*~A~A},
		Q{~A~A~v:*~A},
		Q{~A~A~v@*~A~A},
		Q{~A~v*~A},
		Q{~A~{~A~*~A~}~A},
		Q{~A~{~A~A~0@*~A~A~}~A},
		Q{~A~{~A~A~1@*~A~}~A},
		Q{~A~{~A~A~@*~A~A~}~A},
		Q{~A~{~A~A~A~3:*~A~A~A~A~}~A},
		Q{~A~{~A~A~A~A~4:*~^~A~A~A~A~}~A},
		Q{~A~{~A~A~A~A~v*~^~A~A~A~A~}~A},
		Q{~A~{~A~A~A~A~v:*~^~A~}~A},
		Q{~V:@A},
		Q{~V:@a},
		Q{~V:A},
		Q{~V:a},
		Q{~V@:A},
		Q{~V@:a},
		Q{~V@A},
		Q{~V@a},
		Q{~VA},
		Q{~Va},
		Q{~a},
		Q{~v,,2A},
		Q{~v:@A},
		Q{~v:@a},
		Q{~v:A},
		Q{~v:a},
		Q{~v@:A},
		Q{~v@:a},
		Q{~v@A},
		Q{~v@a},
		Q{~vA},
		Q{~va},
		Q{~{~2,#^~A~}~A},
		Q{~~~d:a},
		Q{~~~d@:A},
		Q{~~~d@a},
		Q{~~~da},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'A';

subtest {
	my @options =
		Q{~#B},
		Q{~#b},
		Q{~+10@B},
		Q{~+10b},
		Q{~,,'*,v:B},
		Q{~,,,#:B},
		Q{~,,,#:b},
		Q{~,,,#@:B},
		Q{~,,V,V:b},
		Q{~,,V,V@:B},
		Q{~,,v,v:@b},
		Q{~,,v,v:B},
		Q{~,,v:B},
		Q{~,,v:b},
		Q{~-1000000000000000000B},
		Q{~-1b},
		Q{~6,vB},
		Q{~:@b},
		Q{~:B},
		Q{~:b},
		Q{~@:B},
		Q{~@B},
		Q{~@b},
		Q{~B},
		Q{~V,V,V,VB},
		Q{~b},
		Q{~db},
		Q{~v,v,v,vb},
		Q{~v,vB},
		Q{~v,vb},
		Q{~vb},
		Q{~~~d@b},
		Q{~~~db},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'B';

subtest {
	my @options =
		Q{#\\~:c},
		Q{'~c},
		Q{~:@C},
		Q{~:C},
		Q{~:c},
		Q{~@:C},
		Q{~@:c},
		Q{~@C},
		Q{~@c},
		Q{~C},
		Q{~c},
		Q{~~,,'~c:~c},
		Q{~~~d,'~c~c},
		Q{~~~d@~c},
		Q{~~~d~c},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'C';

subtest {
	my @options =
		Q{~#D},
		Q{~#d},
		Q{~+10@d},
		Q{~+10d},
		Q{~,,'*,v:d},
		Q{~,,,#:@d},
		Q{~,,,#:D},
		Q{~,,,#:d},
		Q{~,,,#@:D},
		Q{~,,v,v:@D},
		Q{~,,v,v:@d},
		Q{~,,v,v:D},
		Q{~,,v,v:d},
		Q{~,,v:d},
		Q{~-1000000000000000000d},
		Q{~-1d},
		Q{~6,vD},
		Q{~:d},
		Q{~@:d},
		Q{~@D},
		Q{~@d},
		Q{~D},
		Q{~dd},
		Q{~d},
		Q{~v,v,v,vD},
		Q{~v,v,v,vd},
		Q{~v,v@D},
		Q{~v,v@d},
		Q{~v,vD},
		Q{~v,vd},
		Q{~vD},
		Q{~vd},
		Q{~~,,'~c:d},
		Q{~~~d,'~cd},
		Q{~~~d@d},
		Q{~~~dd},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'D';

# XXX No ~e tests?

subtest {
	my @options =
		Q{~,,,,',f},
		Q{~,,,,VF},
		Q{~,,,,vf},
		Q{~,,,vF},
		Q{~,,2f},
		Q{~,,Vf},
		Q{~,,vf},
		Q{~,2F},
		Q{~,vf},
		Q{~0,0f},
		Q{~0f},
		Q{~1,1,,f},
		Q{~10,1,,,'*F},
		Q{~10,1,,,'*f},
		Q{~10,1,,f},
		Q{~2,1F},
		Q{~2,1f},
		Q{~2,2F},
		Q{~2,2f},
		Q{~2f},
		Q{~3,2F},
		Q{~3,2f},
		Q{~3@F},
		Q{~3F},
		Q{~3f},
		Q{~4,0,,'*f},
		Q{~4,2,-1F},
		Q{~4,2,-1f},
		Q{~4,2,0F},
		Q{~4,2,0f},
		Q{~4,2,1f},
		Q{~4,2@F},
		Q{~4,2@f},
		Q{~4,2F},
		Q{~4,2f},
		Q{~4@F},
		Q{~4@f},
		Q{~4F},
		Q{~4f},
		Q{~5,1,,'*F},
		Q{~5,1,,'*f},
		Q{~F},
		Q{~VF},
		Q{~f},
		Q{~v,v,v,v,vf},
		Q{~v,vf},
		Q{~vf},
		Q{~~,,,,'~cf},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'F';

# XXX No trailing-g tests?
# XXX No trailing-h tests?
# XXX No trailing-i tests?
# XXX No trailing-j tests?
# XXX No trailing-k tests?
# XXX No trailing-l tests?
# XXX No trailing-m tests?
# XXX No trailing-n tests?

subtest {
	my @options =
		Q{~#o},
		Q{~+10@O},
		Q{~+10o},
		Q{~,,'*,v:o},
		Q{~,,,#:@o},
		Q{~,,,#:o},
		Q{~,,,#@:O},
		Q{~,,V,v:O},
		Q{~,,v,V@:O},
		Q{~,,v,v:@o},
		Q{~,,v,v:O},
		Q{~,,v:o},
		Q{~-1000000000000000000o},
		Q{~-1O},
		Q{~6,vO},
		Q{~:@o},
		Q{~:O},
		Q{~:o},
		Q{~@:o},
		Q{~@O},
		Q{~@o},
		Q{~O},
		Q{~V,Vo},
		Q{~o},
		Q{~v,V@O},
		Q{~v,v,v,vo},
		Q{~v,v@o},
		Q{~v,vO},
		Q{~vO},
		Q{~vo},
		Q{~~~d@o},
		Q{~~~do},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'O';

subtest {
	my @options =
		Q{~@P},
		Q{~@p},
		Q{~D cat~:P},
		Q{~D cat~:p},
		Q{~D penn~:@P},
		Q{~D penn~:@p},
		Q{~D penn~@:P},
		Q{~D penn~@:p},
		Q{~P},
		Q{~p},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'P';

# XXX No trailing-q tests?

subtest {
	my @options =
		Q{~#r},
		Q{~+10r},
		Q{~10,#r},
		Q{~10,+8r},
		Q{~10,,,v:r},
		Q{~10,-1000000000000000r},
		Q{~10,-1r},
		Q{~10,0r},
		Q{~10,12,vr},
		Q{~10,vr},
		Q{~10r},
		Q{~16,,,,#:r},
		Q{~2,,,,1000000000000000000r},
		Q{~2,12,,'*:r},
		Q{~2:r},
		Q{~2r},
		Q{~3,14,'X,',:R},
		Q{~3@:r},
		Q{~3r},
		Q{~8,,,,v:R},
		Q{~8,10:@r},
		Q{~8@R},
		Q{~:@r},
		Q{~:r},
		Q{~@:R},
		Q{~@R},
		Q{~@r},
		Q{~dr},
		Q{~r},
		Q{~v,v,v,v,vr},
		Q{~vr},
		Q{~~~D,~D,'*r},
		Q{~~~D,~DR},
		Q{~~~d,,,'~c,~d:R},
		Q{~~~d:R},
		Q{~~~dR},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'R';

subtest {
	my @options =
		Q{~10,,,v@S},
		Q{~10,,,v@s},
		Q{~10,,,vS},
		Q{~10,,,vs},
		Q{~3,,+2S},
		Q{~3,,-1S},
		Q{~3,,0S},
		Q{~3,,V@S},
		Q{~3,,vS},
		Q{~3,,vs},
		Q{~3,1s},
		Q{~3,3@s},
		Q{~4,,,'X@s},
		Q{~4,,,'XS},
		Q{~4,,,@S},
		Q{~4,,,s},
		Q{~4,,vs},
		Q{~4,3s},
		Q{~4,4@s},
		Q{~5,3@s},
		Q{~5,3S},
		Q{~5,v@S},
		Q{~5,vS},
		Q{~5,vS},
		Q{~7,3@s},
		Q{~7,3S},
		Q{~:s},
		Q{~@S},
		Q{~S},
		Q{~V,,2s},
		Q{~V:s},
		Q{~V@:s},
		Q{~s},
		Q{~v,,2S},
		Q{~v:@s},
		Q{~v:@s},
		Q{~v:S},
		Q{~v@:s},
		Q{~v@S},
		Q{~vS},
		Q{~~~d:s},
		Q{~~~d@:S},
		Q{~~~d@s},
		Q{~~~dS},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'S';

subtest {
	my @options =
		Q{ ~v,vT},
		Q{XXXXX~2,0T},
		Q{~0,0T},
		Q{~0,1T},
		Q{~0,vT},
		Q{~1,0T},
		Q{~1,1@t},
		Q{~A~v,vt},
		Q{~A~~~D,~DT},
		Q{~v,0T},
		Q{~v,1@T~0,v@t},
		Q{~v,1@t},
		Q{~v,v@t},
		Q{~~~d,~d@t},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'T';

# XXX No trailing-u tests?
# XXX No trailing-v tests?

subtest {
	my @options =
		Q{X},
		Q{~#X},
		Q{~#x},
		Q{~+10@X},
		Q{~+10x},
		Q{~,,'*,v:x},
		Q{~,,,#:X},
		Q{~,,,#:x},
		Q{~,,,#@:X},
		Q{~,,V:x},
		Q{~,,v,V:@x},
		Q{~,,v,v:@x},
		Q{~,,v,v:X},
		Q{~,,v:X},
		Q{~,,v:x},
		Q{~-1000000000000000000x},
		Q{~-1X},
		Q{~6,vX},
		Q{~:@x},
		Q{~:X},
		Q{~:x},
		Q{~@:x},
		Q{~@X},
		Q{~@x},
		Q{~V,vx},
		Q{~X},
		Q{~dx},
		Q{~v,V@X},
		Q{~v,v,v,vx},
		Q{~v,v@x},
		Q{~v,vX},
		Q{~vx},
		Q{~x},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'X';

subtest {
	my @options =
		Q{XX~10,20:@tYY},
		Q{XX~10,20@:tYY},
		Q{XX~10:tYY},
		Q{X~AY},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'Y';

subtest {
	my @options =
		Q{a~?z},
		Q{a~@?z},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'Z';

# XXX no [" tests
# XXX no \" tests

subtest {
	my @options =
		Q{~#[A~:;B~]},
		Q{~#[A~;B~]},
		Q{~-1[a~;b~;c~;d~]},
		Q{~0[a~;b~;c~;d~]},
		Q{~100000000000000000000000000000000[a~;b~;c~;d~]},
		Q{~1[a~;b~;c~;d~]},
		Q{~4[a~;b~;c~;d~]},
		Q{~:[a~;b~]},
		Q{~V[a~;b~;c~;d~;e~;f~;g~;h~;i~]},
		Q{~[a~:;b~]},
		Q{~[a~;b~;c~;d~:;e~]},
		Q{~[a~;b~;c~;d~;e~;f~;g~;h~;i~]},
		Q{~[a~]},
		Q{~[~:;a~]},
		Q{~[~]},
		Q{~v[a~;b~;c~;d~:;e~]},
		Q{~v[a~;b~;c~;d~;e~;f~;g~;h~;i~]},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, ']';

subtest {
	my @options =
		Q{A             ~_},
		Q{A ~:@_A ~:@_A ~:@_A ~:@_A ~:@_},
		Q{A ~:@_A ~:@_A ~:@_A ~:@_},
		Q{A ~:_A ~:_A ~:_A ~:_A ~:_A ~:_A ~:_A ~:_A ~:_A ~:_},
		Q{A ~:_A ~:_A ~:_A ~:_A ~:_},
		Q{A ~@:_A },
		Q{A ~@:_A ~@:_A ~@:_A ~@:_},
		Q{A ~@_A ~@_A ~@_A ~@_A ~@_A ~@_A ~@_A ~@_A ~@_A ~@_},
		Q{A ~@_A ~@_A ~@_A ~@_A ~@_},
		Q{A ~@_A ~@_A ~@_A ~@_},
		Q{A ~_A ~_A ~_A ~_A ~_A ~_A ~_A ~_A ~_A ~_},
		Q{A ~_A ~_A ~_A ~_A ~_},
		Q{A ~_A ~_A ~_A ~_},
		Q{A ~_A ~_A ~_A ~_~%A ~_A ~_A ~_A ~_},
		Q{AAAA ~:@_},
		Q{AAAA ~_},
		Q{B ~_},
		Q{D ~_},
		Q{~%A~@_},
		Q{~W~W~:_~W~W~:_~W~W~:_~W~W~:_~W~W~:_},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, '_';

# XXX No {" tests?

subtest {
	my @options =
		Q{~0|},
		Q{~V|},
		Q{~|},
		Q{~~~D|},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, '|';

subtest {
	my @options =
		Q{~#:@{A~:}},
		Q{~#:{~A~}},
		Q{~#@{~A~}},
		Q{~#{~A~}},
		Q{~#{~}},
		Q{~0:@{~A~:}},
		Q{~0:{XYZ~}},
		Q{~0@{~A~^~A~}},
		Q{~0{FOO~:}},
		Q{~0{~A~^~A~}},
		Q{~0{~}},
		Q{~1@{FOO~}},
		Q{~1@{~A~^~A~}},
		Q{~1{FOO~:}},
		Q{~1{~A~^~A~}},
		Q{~1{~}},
		Q{~2:{XYZ~}},
		Q{~2:{~A~}},
		Q{~2{FOO~:}},
		Q{~2{FOO~}},
		Q{~3{~}},
		Q{~:@{(~A ~A)~}},
		Q{~:@{~#,#,#:^~A~}},
		Q{~:@{~#,#,#^~A~}},
		Q{~:@{~#,#,2:^~A~}},
		Q{~:@{~#,#,3^~A~}},
		Q{~:@{~#,#:^~A~}},
		Q{~:@{~#,#^~A~}},
		Q{~:@{~#,1:^~A~}},
		Q{~:@{~#,1^~A~}},
		Q{~:@{~#,2,#:^~A~}},
		Q{~:@{~#,2,2:^~A~}},
		Q{~:@{~#,3,#^~A~}},
		Q{~:@{~#,3,3^~A~}},
		Q{~:@{~#,v:^~A~}},
		Q{~:@{~#:^~A~}},
		Q{~:@{~#^~A~}},
		Q{~:@{~'X,'X:^~A~}},
		Q{~:@{~'X,'Y:^~A~}},
		Q{~:@{~'X:^~A~}},
		Q{~:@{~'x,'x^~A~}},
		Q{~:@{~'x,3^~A~}},
		Q{~:@{~0,1:^~A~}},
		Q{~:@{~0,3,#^~A~}},
		Q{~:@{~0,v^~A~}},
		Q{~:@{~0:^~A~}},
		Q{~:@{~1,#:^~A~}},
		Q{~:@{~1,#^~A~}},
		Q{~:@{~1,0,1^~A~}},
		Q{~:@{~1,1,1^~A~}},
		Q{~:@{~1,1,v:^~A~}},
		Q{~:@{~1,1:^~A~}},
		Q{~:@{~1,2,1:^~A~}},
		Q{~:@{~1,2,1^~A~}},
		Q{~:@{~1,2,3:^~A~}},
		Q{~:@{~1,2,3^~A~}},
		Q{~:@{~1,2,v^~A~}},
		Q{~:@{~1,3,#:^~A~}},
		Q{~:@{~1,V:^~A~}},
		Q{~:@{~1,v,2:^~A~}},
		Q{~:@{~1,v,3^~A~}},
		Q{~:@{~1,v,v^~A~}},
		Q{~:@{~1,v^~A~}},
		Q{~:@{~1:^~A~}},
		Q{~:@{~2,#,3:^~A~}},
		Q{~:@{~2,#,3^~A~}},
		Q{~:@{~2,1,3:^~A~}},
		Q{~:@{~2,V,v:^~A~}},
		Q{~:@{~2,v^~A~}},
		Q{~:@{~3,#,#:^~A~}},
		Q{~:@{~3,#,#^~A~}},
		Q{~:@{~3,'x^~A~}},
		Q{~:@{~3,2,1^~A~}},
		Q{~:@{~:^~A~}},
		Q{~:@{~A~:}},
		Q{~:@{~A~^~A~A~}},
		Q{~:@{~A~}},
		Q{~:@{~V,#:^~A~}},
		Q{~:@{~V,v,3:^~A~}},
		Q{~:@{~V,v:^~A~}},
		Q{~:@{~V:^~A~}},
		Q{~:@{~v,1,v^~A~}},
		Q{~:@{~v,1:^~A~}},
		Q{~:@{~v,2,2:^~A~}},
		Q{~:@{~v,2,3^~A~}},
		Q{~:@{~v,2,v:^~A~}},
		Q{~:@{~v,3^~A~}},
		Q{~:@{~v,3^~A~}},
		Q{~:@{~v,v,V:^~A~}},
		Q{~:@{~v,v^~A~}},
		Q{~:@{~v,v^~A~}},
		Q{~:@{~v:^~A~}},
		Q{~:@{~v^~A~}},
		Q{~:@{~}},
		Q{~:{(~A ~A)~}},
		Q{~:{ABC~:}},
		Q{~:{~#,#,#:^~A~}},
		Q{~:{~#,#,#^~A~}},
		Q{~:{~#,#,2:^~A~}},
		Q{~:{~#,#,3^~A~}},
		Q{~:{~#,#:^~A~}},
		Q{~:{~#,#^~A~}},
		Q{~:{~#,1:^~A~}},
		Q{~:{~#,1^~A~}},
		Q{~:{~#,2,#:^~A~}},
		Q{~:{~#,2,2:^~A~}},
		Q{~:{~#,3,#^~A~}},
		Q{~:{~#,3,3^~A~}},
		Q{~:{~#,v:^~A~}},
		Q{~:{~#:^~A~}},
		Q{~:{~#^~A~#^~A~#^~A~#^~A~}},
		Q{~:{~#^~A~}},
		Q{~:{~'X,'X:^~A~}},
		Q{~:{~'X,'Y:^~A~}},
		Q{~:{~'X:^~A~}},
		Q{~:{~'x,'x^~A~}},
		Q{~:{~'x,3^~A~}},
		Q{~:{~0,1:^~A~}},
		Q{~:{~0,3,#^~A~}},
		Q{~:{~0,v^~A~}},
		Q{~:{~0:^~A~}},
		Q{~:{~1,#:^~A~}},
		Q{~:{~1,#^~A~}},
		Q{~:{~1,0,1^~A~}},
		Q{~:{~1,1,1^~A~}},
		Q{~:{~1,1,v:^~A~}},
		Q{~:{~1,1:^~A~}},
		Q{~:{~1,2,1:^~A~}},
		Q{~:{~1,2,1^~A~}},
		Q{~:{~1,2,3:^~A~}},
		Q{~:{~1,2,3^~A~}},
		Q{~:{~1,2,v^~A~}},
		Q{~:{~1,2,v^~A~}},
		Q{~:{~1,3,#:^~A~}},
		Q{~:{~1,V:^~A~}},
		Q{~:{~1,v,2:^~A~}},
		Q{~:{~1,v,3^~A~}},
		Q{~:{~1,v,v^~A~}},
		Q{~:{~1,v^~A~}},
		Q{~:{~1:^~A~}},
		Q{~:{~2,#,3:^~A~}},
		Q{~:{~2,#,3^~A~}},
		Q{~:{~2,1,3:^~A~}},
		Q{~:{~2,V,v:^~A~}},
		Q{~:{~2,v^~A~}},
		Q{~:{~3,#,#:^~A~}},
		Q{~:{~3,#,#^~A~}},
		Q{~:{~3,'x^~A~}},
		Q{~:{~3,2,1^~A~}},
		Q{~:{~3,v^~A~}},
		Q{~:{~:^~A~}},
		Q{~:{~A~0^~A~A~}},
		Q{~:{~A~:}},
		Q{~:{~A~^~A~A~}},
		Q{~:{~V,#:^~A~}},
		Q{~:{~V,v,3:^~A~}},
		Q{~:{~V,v:^~A~}},
		Q{~:{~V:^~A~}},
		Q{~:{~v,1,v^~A~}},
		Q{~:{~v,1:^~A~}},
		Q{~:{~v,2,2:^~A~}},
		Q{~:{~v,2,3^~A~}},
		Q{~:{~v,2,v:^~A~}},
		Q{~:{~v,3^~A~}},
		Q{~:{~v,3^~A~}},
		Q{~:{~v,v,V:^~A~}},
		Q{~:{~v,v^~A~}},
		Q{~:{~v:^~A~}},
		Q{~:{~v^~A~}},
		Q{~:{~}},
		Q{~@:{~#^~A~#^~A~#^~A~#^~A~}},
		Q{~@:{~3,v^~A~}},
		Q{~@:{~A~0^~A~A~}},
		Q{~@{ ~}},
		Q{~@{X ~A Y Z~}},
		Q{~@{X ~A~^ Y ~A~^ ~}},
		Q{~@{X~:}},
		Q{~@{~#,#,#^~A~}},
		Q{~@{~#,#,v^~A~}},
		Q{~@{~#,#^~A~}},
		Q{~@{~#,1,2^~A~}},
		Q{~@{~#,3^~A~}},
		Q{~@{~',,',^~A~}},
		Q{~@{~'X,v^~A~}},
		Q{~@{~'X^~A~}},
		Q{~@{~0,v,v^~A~}},
		Q{~@{~0,v^~A~}},
		Q{~@{~1,1,v^~A~}},
		Q{~@{~1,2,v^~A~}},
		Q{~@{~1,v,v^~A~}},
		Q{~@{~1,v^~A~}},
		Q{~@{~1{~A~}~}},
		Q{~@{~A~A~0^~A~}},
		Q{~@{~A~A~v^~A~}},
		Q{~@{~A~}},
		Q{~@{~v,'X^~A~}},
		Q{~@{~v,1,v^~A~}},
		Q{~@{~v,v,v^~A~}},
		Q{~@{~v,v^~A~}},
		Q{~@{~{~A~}~}},
		Q{~@{~}},
		Q{~V:@{~A~}},
		Q{~V:{X~}},
		Q{~V@:{~A~}},
		Q{~V{FOO~:}},
		Q{~V{~A~}},
		Q{~V{~}},
		Q{~v:@{~A~}},
		Q{~v:{ABC~:}},
		Q{~v:{~A~:}},
		Q{~v:{~A~}},
		Q{~v@{~A~}},
		Q{~v@{~}},
		Q{~v{~A~}},
		Q{~v{~a~}},
		Q{~{ ~}},
		Q{~{FOO~:}},
		Q{~{X Y Z~}},
		Q{~{X ~A~^ Y ~A~^ ~}},
		Q{~{~#,#,#^~A~}},
		Q{~{~#,#,v^~A~}},
		Q{~{~#,#^~A~}},
		Q{~{~#,1,2^~A~}},
		Q{~{~#,3^~A~}},
		Q{~{~',,',^~A~}},
		Q{~{~'X,v^~A~}},
		Q{~{~'X^~A~}},
		Q{~{~(~C~C~0^~C~)W~}},
		Q{~{~0,v,v^~A~}},
		Q{~{~0,v^~A~}},
		Q{~{~1,1,v^~A~}},
		Q{~{~1,2,v^~A~}},
		Q{~{~1,v,v^~A~}},
		Q{~{~1,v^~A~}},
		Q{~{~1{~A~}~}},
		Q{~{~:(~C~C~0^~C~)U~}},
		Q{~{~@(~CA ~Cb ~0^~C~)V~}},
		Q{~{~@:(~CA ~Cb ~0^~C~)W~}},
		Q{~{~A~:}},
		Q{~{~A~@?~A~}},
		Q{~{~A~A~0^~A~}},
		Q{~{~A~A~v^~A~}},
		Q{~{~A~}},
		Q{~{~[X~;Y~0^NO~;Z~;~^~]~}},
		Q{~{~[X~;Y~;Z~:;~0^~]~}},
		Q{~{~[X~;Y~;Z~;~0^~]~}},
		Q{~{~v,'X^~A~}},
		Q{~{~v,1,v^~A~}},
		Q{~{~v,v,v^~A~}},
		Q{~{~v,v^~A~}},
		Q{~{~{~A~}~}},
		Q{~{~}},
		Q{~:@{~A ~A~}},
		Q{~:{~A~}},
		Q{~{~A~}},
		Q{~:@{~A~}},
		Q{~:{~A~}},
		Q{~{~A~}},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, '}';

subtest {
	my @options =
		Q{~#~},
		Q{~v~},
		Q{~~},
		Q{~~~D~~},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, '~';

subtest {
	my @options =
		Q{1~<X~<Y~:>Z~>2},
		Q{~:<foo~;~A~;bar~A~:>},
		Q{~:<foo~@;~A~;bar~A~:>},
		Q{~:<foo~A~;~A~:>},
		Q{~:<foo~A~;~A~;bar~:>},
		Q{~:<foo~A~@;~A~:>},
		Q{~:<foo~A~@;~A~;bar~:>},
		Q{~:<~;~A~;bar~A~:>},
		Q{~:<~@;~A~;bar~A~:>},
		Q{~< ~W ~>},
		Q{~< ~_ ~>},
		Q{~< ~i ~>},
		Q{~<X~:;Y~>~I},
		Q{~<X~:;Y~>~W},
		Q{~<X~:;Y~>~_},
		Q{~<foo~;~A~;bar~A~:>},
		Q{~<foo~@;~A~;bar~A~:>},
		Q{~<foo~A~;~A~:>},
		Q{~<foo~A~;~A~;bar~:>},
		Q{~<foo~A~@;~A~:>},
		Q{~<foo~A~@;~A~;bar~:>},
		Q{~<~:;~>~<~:>},
		Q{~<~:>~<~:;~>},
		Q{~<~;~A~;bar~A~:>},
		Q{~<~@;~A~;bar~A~:>},
		Q{~@<foo~;~A~;bar~A~:>},
		Q{~@<foo~@;~A~;bar~A~:>},
		Q{~@<foo~A~;~A~:>},
		Q{~@<foo~A~;~A~;bar~:>},
		Q{~@<foo~A~@;~A~:>},
		Q{~@<foo~A~@;~A~;bar~:>},
		Q{~@<~;~A~;bar~A~:>},
		Q{~@<~@;~A~;bar~A~:>},
		Q{~_~<X~:;Y~>},
		Q{~i~<X~:;Y~>},
		Q{~w~<X~:;Y~>},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, '>';

subtest {
	my @options =
		Q{AAAA~1,1:TBBB~<XXX~:;YYY~>ZZZ},
		Q{~<XXX~1,1:TYYY~>},
		Q{~<XXX~:;YYY~>ZZZ~4,5:tWWW},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'Z';

#`(
subtest {
	my @options =
		qq{~\n   X},
		qq{A~:\n X},
		qq{A~@\n X},
	;
	for @options -> $str {
		ok $fl._match( $str ), $str;
	}
}, 'newline';
)

subtest {
	my @failing-options =
		Q[~{],
		Q[~}],
		Q[~(],
		Q[~)],
		Q[~<],
		Q[~>],
#		Q[~;], # tilde-Semi outside balanced block
	;
	for @failing-options -> $str {
		nok $fl._match( $str ), $str;
	}
}, 'failing';

done-testing;

# vim: ft=perl6
