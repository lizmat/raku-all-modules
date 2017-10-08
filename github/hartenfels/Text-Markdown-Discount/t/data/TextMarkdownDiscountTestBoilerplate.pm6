unit module TextMarkdownDiscountTestBoilerplate;
# This module just defines a bunch of stuff used in the other tests.

# Don't really want to use `File::Temp` just for these tests or write
# my own broken temporary file function. `tmpnam` isn't too unbroken
# either, but it's good enough for these tests.
use NativeCall;
sub tmpnam(Pointer[int8] --> Str) is native(Str) { * }
sub tmpname() is export { tmpnam(Pointer[int8]) } # calls `tmpnam(NULL)`

# This'll resolve to this repository's `t/data` folder.
our $data is export = $?FILE.IO.dirname;


class TestFile
{
    has $.file;

    multi method new(Str $file) { self.bless(:$file) }

    method   md(         ) { "$data/$.file.md"                     }
    method html(Str $mod?) { "$data/$.file\.{"$mod." if $mod}html" }
    method from(         ) { slurp self.md                         }
    method   to(Str $mod?) { slurp self.html($mod)                 }
};

our $simple is export = TestFile.new('simple');
our $html   is export = TestFile.new( 'html' );
