use Staticish;

class StaticFoo is Static {
    has $.foo is rw;
    method say-foo(Str $say = "say") {
        $say ~ " " ~ $!foo;
    }
}

