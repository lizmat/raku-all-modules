use Test;
use NativeCall;

use lib 'lib';
use TinyCC::Bundled;
use TinyCC::State;

enum <_ MEM EXE DLL OBJ PRE>;

my ($state, $error);
my $dummy := nativecast(Pointer, blob8.new(42));

plan 6;

$state := try TCCState.new;
ok defined($state), 'new'
    or bail-out 'cannot continue without state';

$state.set_error_func($dummy, -> $ptr, $msg {
    ok True, 'set_error_func (error func entered)';
    ok $dummy == $ptr, 'set_error_func (argument passed)';
    $error = $msg;
});

$state.add_file('file-that-does-not-exist');
ok 1, 'set_error_func (error func exited)';
ok $error ~~ Str:D, 'set_error_func (error msg set)';

ok $_, 'delete' given try {
    $state.delete;
    1;
}

#    method set_lib_path(Str)
#        is native(&LIB) is symbol<tcc_set_lib_path> {*}
#
#    method set_options(Str)
#        is native(&LIB) is symbol<tcc_set_options> {*}
#
#    method add_include_path(Str --> int32)
#        is native(&LIB) is symbol<tcc_add_include_path> {*}
#
#    method add_sysinclude_path(Str --> int32)
#        is native(&LIB) is symbol<tcc_add_sysinclude_path> {*}
#
#    method define_symbol(Str, Str)
#        is native(&LIB) is symbol<tcc_define_symbol> {*}
#
#    method undefine_symbol(Str)
#        is native(&LIB) is symbol<tcc_undefine_symbol> {*}
#
#    method add_file(Str --> int32)
#        is native(&LIB) is symbol<tcc_add_file> {*}
#
#    method compile_string(Str --> int32)
#        is native(&LIB) is symbol<tcc_compile_string> {*}
#
#    method set_output_type(int32 --> int32)
#        is native(&LIB) is symbol<tcc_set_output_type> {*}
#
#    method add_library_path(Str --> int32)
#        is native(&LIB) is symbol<tcc_add_library_path> {*}
#
#    method add_library(Str --> int32)
#        is native(&LIB) is symbol<tcc_add_library> {*}
#
#    method add_symbol(Str, Pointer --> int32)
#        is native(&LIB) is symbol<tcc_add_symbol> {*}
#
#    method output_file(Str --> int32)
#        is native(&LIB) is symbol<tcc_output_file> {*}
#
#    method run(int32, CArray[Str] --> int32)
#        is native(&LIB) is symbol<tcc_run> {*}
#
#    method relocate(Pointer --> int32)
#        is native(&LIB) is symbol<tcc_relocate> {*}
#
#    method get_symbol(Str --> Pointer)
#        is native(&LIB) is symbol<tcc_get_symbol> {*}
