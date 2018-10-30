# Copyright 2017 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

when ?%*ENV<LIBTCC> {}
when $*DISTRO.is-win && $*KERNEL.bits == 64 {
    ::('TinyCC::Resources::Win64::DLL').setenv
        if (try require TinyCC::Resources::Win64::DLL) !=== Nil;
}
