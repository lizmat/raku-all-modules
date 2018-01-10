#!/usr/bin/env perl6

use lib $*PROGRAM.sibling: '../lib';
use CoreHackers::Q;

multi MAIN('a', *@args) {
    CoreHackers::Q.new.run: @args;
}

multi MAIN('o', *@args) {
    CoreHackers::Q.new.run: @args, :opt;
}

multi MAIN('z', *@args) {
    CoreHackers::Q.new.zero-run: @args, :opt;
}
