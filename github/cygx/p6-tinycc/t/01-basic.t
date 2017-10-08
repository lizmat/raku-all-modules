use Test;

use lib 'lib';
use TinyCC::Bundled;
use TinyCC;

plan 1;

my \CODE = q{
    int main(void) {
        return 42;
    }
};

is tcc.compile(CODE).run, 42, 'return 42';
