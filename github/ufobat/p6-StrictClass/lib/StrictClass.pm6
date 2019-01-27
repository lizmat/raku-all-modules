use v6.c;
unit role StrictClass:ver<0.0.3>;

method new(*%pars) {
    my @attrs = %pars.keys.grep: {
        so $_ ne ::?CLASS.^attributes.map(*.name.substr: 2).any
    };
    die "Attributes not expected: @attrs.join(", ")" if @attrs;
    nextsame;
};

=begin pod

=head1 NAME

StrictClass - Make your object constructors blow up on unknown attributes

=head1 SYNOPSIS

    use StrictClass;

    class MyClass does StrictClass {
        has $.foo;
        has $.bar;
    }

    MyClass.new( :foo(1), :bar(2), :baz('makes you explode'));

=head1 DESCRIPTION

Simply using this role for your class makes your `new` "strict". This is a great way to catch small typos.

=head1 AUTHOR

Martin Barth <martin@senfdax.de>

=head1 THANKS TO

 * FCO aka SmokeMaschine from #perl6 IRC channel for this code.
 * Dave Rolsky for his perl5 module `MooseX::StrictContructor`.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Martin Barth

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
