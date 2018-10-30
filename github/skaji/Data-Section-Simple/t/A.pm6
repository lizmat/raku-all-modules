use v6;
unit class A;
use Data::Section::Simple;

method foo {
    my %all = get-data-section(content => CALLER::UNIT::<$=finish>);
    return %all;
}
