# Name NativeCall::Typediag

# Synopsis

```perl
use v6;
use Gumbo::Binding;
use NativeCall::TypeDiag;
my @headers = <gumbo.h>;
my @libs = <-lgumbo>;

my %typ;
# Construct the type from the exported stuff
for Gumbo::Binding::EXPORT::DEFAULT::.keys -> $export {
  if ::($export).REPR eq 'CStruct' {
    #convert foo_bar_s to FooBar
    my $cname = $export.subst(/_s$/, '');
    my @t = $cname.split('_').map: {.tc};
    %typ{@t.join('')} = ::($export);
  }
}
diag-cstructs(:cheaders(@headers), :types(%typ), :clibs(@libs));
```


# Description

A module that provide functions to look at your native types. Comparing with the their C equivalent.


## diag-struct ($ctypename, $nctype, :@cheaders, :@clibs = ())

Analyse the size of the fields of a CStruct and compare them to their C counterpart. It also show potential mistakes

return true if there is no error.

@cheaders is what you need to include to compile a C file using the lib. @clibs is extra options to the compiler.

## diag-cstructs(:@cheaders, :@clibs = (), :%types)

Analyse a given list of structures

%types pairs must look like this :
`"C name of the struct" => ::("name of NC type")`

return true if there is no error.

## diag-functions(:@functions)

REMOVED. It's now part of NativeCall

## @nctd-extracompileroptions

An array that is passed as option to the compiler `cc`

## Example

From one example in the examples folder.

```perl
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
	has	rgba_color_s	$.tmpcolor;

	has	num32		$.positionx;
	has	num32		$.positiony;
	has	num32		$.position2x;
	has	num32		$.position2y;
	has	num32		$.fadingpositionx;
	has	num32		$.fadingpositiony;

	has	int32		$.size;
	has	int32		$.size2;
	has	int32		$.fadingsize;

	has	str		$.image;
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

```

Its output

```
Compiling a test file, this assume field names are the same
-Perl6 name : wrong_rgba_color_s, C Name : rgba_color_t
__has int32  $red : c-size=4 | nc-size=4 -- : 
__has int32  $blue : c-size=4 | nc-size=4 -- : 
__has int32  $green : c-size=4 | nc-size=4 -- : 
-Size given by sizeof and nativesizeof : C:16/NC:12
-Calculated total sizes : C:12/NC:12
Your representation is smaller than the cstruct, but total size of fields match. Did you forget a field?
----
Compiling a test file, this assume field names are the same
-Perl6 name : toyunda_subtitle_s, C Name : toyunda_sub_t
__has int32  $start : c-size=4 | nc-size=4 -- : 
__has int32  $stop : c-size=4 | nc-size=4 -- : 
__has Str  $text : c-size=4 | nc-size=4 -- : 
__HAS rgba_color_s  $color1 : c-size=16 | nc-size=16 -- : 
__HAS rgba_color_s  $color2 : c-size=16 | nc-size=16 -- : 
__has rgba_color_s  $tmpcolor : c-size=16 | nc-size=4 -- DONT MATCH: C size match nativesizeof(rgba_color_s). put HAS instead of has 
__has num32  $positionx : c-size=4 | nc-size=4 -- : 
__has num32  $positiony : c-size=4 | nc-size=4 -- : 
__has num32  $position2x : c-size=4 | nc-size=4 -- : 
__has num32  $position2y : c-size=4 | nc-size=4 -- : 
__has num32  $fadingpositionx : c-size=4 | nc-size=4 -- : 
__has num32  $fadingpositiony : c-size=4 | nc-size=4 -- : 
__has int32  $size : c-size=4 | nc-size=4 -- : 
__has int32  $size2 : c-size=4 | nc-size=4 -- : 
__has int32  $fadingsize : c-size=4 | nc-size=4 -- : 
__has str  $image : c-size=4 | nc-size=4 -- : You should replace your 'str' type with 'Str'
-Size given by sizeof and nativesizeof : C:100/NC:88
-Calculated total sizes : C:100/NC:88

 Some function 

foo1 - Not a valid parameter type for parameter [2] $b : Int
-->For Numerical type, use the appropriate int32/int64/num64...
foo2 - Not a valid parameter type for parameter [1] $a : Num
-->For Numerical type, use the appropriate int32/int64/num64...
foo2 - Not a valid parameter type for parameter [2] $b : Int
-->For Numerical type, use the appropriate int32/int64/num64...
Int foo3 - You should not return a non NC type (like Int inplace of int32), truncating errors can appear with different architectures

```