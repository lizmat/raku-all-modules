# Copyright 2017 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

sub EXPORT {
    (try require TinyCC::Resources::Win64::DLL) !=== Nil
        or die 'TinyCC::Win64 requires TinyCC::Resources::Win64';

    ::('TinyCC::Resources::Win64::DLL').setenv;
    BEGIN Map.new;
}
