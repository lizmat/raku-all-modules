# Copyright 2017 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use TinyCC::Compiler;
sub EXPORT { Map.new((tcc => TCC.new)) }
