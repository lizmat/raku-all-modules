use v6.d;
unit module Foo::Plugin::Test;
use OO::Plugin;

plugin TestPlugin {
}

plugin Sample after TestPlugin {
}
