use v6;
use Test;
use AttrX::Lazy;

plan 6;

class Foo {
    has $.bar is lazy;
    has $.build_count = 0;

    method !build_bar() {
        $!build_count++;
        return "baz";
    }
}

my $instance = Foo.new();
is $instance.bar, "baz", "Building of the attribute is correct";
$instance.bar for ^10;
is $instance.build_count, 1, "Build has been done only once";

class Foo2 {
    has $.bar is lazy( builder => 'my_custom_builder' );
    has $.build_count = 0;

    method !my_custom_builder() {
        $!build_count++;
        return "baz";
    }
}

$instance = Foo2.new();
is $instance.bar, "baz", "Building of the attribute is correct, with custom builder";
$instance.bar for ^10;
is $instance.build_count, 1, "Build has been done only once";

throws-like { EVAL q[
    use AttrX::Lazy;
    class Foo3 {
        has $.bar is lazy;
    }
]; }, Exception, "Builder method not provided", message => q[No builder private method 'build_bar' found, can't create lazy accessor $.bar'];

throws-like { EVAL q[
    use AttrX::Lazy;
    class Foo4 {
        has $.bar is lazy;

        method !build_bar { "baz" }
        method bar() { }
    }
]; }, Exception, "Public method with the name of the accessor defined", message => q[A method 'bar' already exists, can't create lazy accessor $.bar'];
