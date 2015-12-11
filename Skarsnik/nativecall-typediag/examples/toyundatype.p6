use v6;

use NativeCall;
use NativeCall::TypeDiag;

class wrong_rgba_color_s is repr('CStruct'){
	has	int32 $.red;
	has	int32 $.blue;
	has 	int32 $.green;
}

class rgba_color_s is repr('CStruct'){
	has	int32 $.red;
	has	int32 $.blue;
	has 	int32 $.green;
	has 	int32 $.alpha;
}


#struct s_toyunda_sub {
#        usigned int     start;
#        usigned int     stop;
#        char*   text;
#        rgba_color_t    color1;
#        rgba_color_t    color2;
#        rgba_color_t    tmpcolor;
#        float   positionx;
#        float   positiony;
#        float   position2x;
#        float   position2y;
#        float   fadingpositionx;
#        float   fadingpositiony;
#        int     size;
#        int     size2;
#        int fadingsize;
#        char*   image;
#};

class toyunda_subtitle_s is repr('CStruct') {
	has	int32 	$.start;
	has	int32	$.stop;

	has	Str	$.text;
	HAS	rgba_color_s	$.color1;
	HAS	rgba_color_s	$.color2;
	has	rgba_color_s	$.tmpcolor; # it should be HAS

	has	num32		$.positionx;
	has	num32		$.positiony;
	has	num32		$.position2x;
	has	num32		$.position2y;
	has	num32		$.fadingpositionx;
	has	num32		$.fadingpositiony;

	has	int32		$.size;
	has	int32		$.size2;
	has	int32		$.fadingsize;

	has	str		$.image; # bad use of str
}

my @h = <toyundatype.h>;
my @l;
@nctd-extracompileroptions = "-I", "./";
diag-struct("rgba_color_t", wrong_rgba_color_s, :cheaders(@h));
say "----";
diag-struct("toyunda_sub_t", toyunda_subtitle_s, :cheaders(@h));
say "\n Some function \n";

sub foo1(Str $a, Int $b) is native('whatever') { * };

sub foo2(Num $a, Int $b) is native('whatever') { * };

sub foo3(Str $a, int32 $b) is native('whatever') returns Int { * };

diag-functions(:functions([&foo1, &foo2, &foo3]));

