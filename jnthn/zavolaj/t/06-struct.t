use lib '.';
use t::CompileTestLib;
use NativeCall;
use Test;

plan 19;

compile_test_lib('06-struct');

class MyStruct is repr('CStruct') {
    has int    $.int;
    has num    $.num;
    has int8   $.byte;
    has num32  $.float;
    has CArray $.arr;

    method init() {
        $!int = 42;
        $!byte = 7;
        $!num = -3.7e0;
        $!float = 3.14e0;
        my $arr := CArray[int].new();
        $arr[0] = 1;
        $arr[1] = 2;
        $!arr := $arr;
    }
}

# Workaround a Rakudo-bug where $!arr := CArray[int].new() won't work if $.arr
# is declared as type CArray[int].
class MyStruct2 is repr('CStruct') {
    has int         $.int;
    has num         $.num;
    has int8        $.byte;
    has num32       $.float;
    has CArray[int] $.arr;
}

class IntStruct is repr('CStruct') {
    has int $.first;
    has int $.second;

    # Work around struct members not being containerized yet.
    method init {
        $!first  = 13;
        $!second = 17;
    }
}

class NumStruct is repr('CStruct') {
    has num $.first;
    has num $.second;

    # Work around struct members not being containerized yet.
    method init {
        $!first  = 0.9e0;
        $!second = 3.14e0;
    }
}

class StructStruct is repr('CStruct') {
    has IntStruct $.a;
    has NumStruct $.b;

    # Work around struct members not being containerized yet.
    method init {
        $!a := IntStruct.new;
        $!b := NumStruct.new;
        $!a.init;
        $!b.init;
    }
}

class StringStruct is repr('CStruct') {
    has Str $.first;
    has Str $.second;

    method init {
        $!first  := 'Lorem';
        $!second := 'ipsum';
    }
}

class PointerThing is repr('CPointer') {
    sub _deref(PointerThing $x) returns int is native('./06-struct') { * }
    method deref() { return _deref(self); }
}

class PointerStruct is repr('CStruct') {
    has PointerThing $.p;
}

sub ReturnAStruct() returns MyStruct2 is native('./06-struct') { * }
sub TakeAStruct(MyStruct $arg)        is native('./06-struct') { * }

sub ReturnAStructStruct() returns StructStruct is native('./06-struct') { * }
sub TakeAStructStruct(StructStruct $arg)       is native('./06-struct') { * }

sub ReturnAPointerStruct() returns PointerStruct is native('./06-struct') { * }

sub ReturnAStringStruct() returns StringStruct is native('./06-struct') { * }
sub TakeAStringStruct(StringStruct $arg)       is native('./06-struct') { * }

# Perl-side tests:
my MyStruct $obj .= new;
$obj.init;

is $obj.int,    42,     'getting int';
is_approx $obj.num,   -3.7e0,  'getting num';
is $obj.byte,   7,      'getting int8';
is_approx $obj.float,  3.14e0, 'getting num32';
is $obj.arr[1], 2,      'getting CArray and element';

# C-side tests:
my $cobj = ReturnAStruct;

is $cobj.int,    17,      'getting int from C-created struct';
is_approx $cobj.num,    4.2e0,   'getting num from C-created struct';
is $cobj.byte,   13,      'getting int8 from C-created struct';
is_approx $cobj.float,  -6.28e0, 'getting num32 from C-created struct';
is $cobj.arr[0], 2,       'C-created array member, elem 1';
is $cobj.arr[1], 3,       'C-created array member, elem 2';
is $cobj.arr[2], 5,       'C-created array member, elem 3';

my StructStruct $ss = ReturnAStructStruct();
is $ss.a.first,   7, 'field 1 from struct 1 in struct';
is $ss.a.second, 11, 'field 2 from struct 1 in struct';

is_approx $ss.b.first,  3.7e0, 'field 1 from struct 2 in struct';
is_approx $ss.b.second, 0.1e0, 'field 2 from struct 2 in struct';

my PointerStruct $x = ReturnAPointerStruct();
is $x.p.deref, 19, 'CPointer object in struct';

my StringStruct $strstr = ReturnAStringStruct();
is $strstr.first,  'OMG!',     'first string in struct';
is $strstr.second, 'Strings!', 'second string in struct';

TakeAStruct($obj);

my StructStruct $ss2 .= new();
$ss2.init;

TakeAStructStruct($ss2);

my StringStruct $strstr2 .= new();
$strstr2.init;
#$strstr2.first  := "Lorem";
#$strstr2.second := "ipsum";
TakeAStringStruct($strstr2);

# vim:ft=perl6
