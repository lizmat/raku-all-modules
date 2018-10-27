# Copyright 2017 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use NativeCall;

my class TCCBinary is export {
    has $.state;
    has $.bytes;

    proto method lookup($, $?) {*}
    multi method lookup($name) { $!state.get_symbol($name) }
    multi method lookup($name, $type) {
        nativecast $type, $!state.get_symbol($name);
    }

    method close {
        $!state.delete;
        $!state = Nil;
        self;
    }
}
