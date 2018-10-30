# Copyright 2017 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use NativeCall;

sub LIB { once %*ENV<LIBTCC> // BEGIN %*ENV<LIBTCC> // 'tcc' }

my class TCCState is repr<CPointer> is export {
    sub new(--> TCCState)
        is native(&LIB) is symbol<tcc_new> {*}

    method new { new }

    method delete()
        is native(&LIB) is symbol<tcc_delete> {*}

    method set_lib_path(Str)
        is native(&LIB) is symbol<tcc_set_lib_path> {*}

    method set_error_func(Pointer, & (Pointer, Str))
        is native(&LIB) is symbol<tcc_set_error_func> {*}

    method set_options(Str)
        is native(&LIB) is symbol<tcc_set_options> {*}

    method add_include_path(Str --> int32)
        is native(&LIB) is symbol<tcc_add_include_path> {*}

    method add_sysinclude_path(Str --> int32)
        is native(&LIB) is symbol<tcc_add_sysinclude_path> {*}

    method define_symbol(Str, Str)
        is native(&LIB) is symbol<tcc_define_symbol> {*}

    method undefine_symbol(Str)
        is native(&LIB) is symbol<tcc_undefine_symbol> {*}

    method add_file(Str --> int32)
        is native(&LIB) is symbol<tcc_add_file> {*}

    method compile_string(Str --> int32)
        is native(&LIB) is symbol<tcc_compile_string> {*}

    method set_output_type(int32 --> int32)
        is native(&LIB) is symbol<tcc_set_output_type> {*}

    method add_library_path(Str --> int32)
        is native(&LIB) is symbol<tcc_add_library_path> {*}

    method add_library(Str --> int32)
        is native(&LIB) is symbol<tcc_add_library> {*}

    method add_symbol(Str, Pointer --> int32)
        is native(&LIB) is symbol<tcc_add_symbol> {*}

    method output_file(Str --> int32)
        is native(&LIB) is symbol<tcc_output_file> {*}

    method run(int32, CArray[Str] --> int32)
        is native(&LIB) is symbol<tcc_run> {*}

    method relocate(Pointer --> int32)
        is native(&LIB) is symbol<tcc_relocate> {*}

    method get_symbol(Str --> Pointer)
        is native(&LIB) is symbol<tcc_get_symbol> {*}
}
