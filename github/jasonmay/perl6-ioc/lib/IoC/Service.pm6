role IoC::Service {
    has Str $.name is rw;
    has Str $.lifecycle;

    # for singletons
    has Any $.instance;

    method initialize($new) {
        if $.instance {
            die "Instance of $.name already initialized"
        }
        $!instance = $new;
    }
};

=begin pod

=head1 NAME

IoC::Service

=head1 SYNOPSIS

  my $service = IoC::Service.new(...);

=head1 DESCRIPTION

Used in the container class for each component. See L<IoC::Container>
for an example of use of this class.

=head1 LIFECYCLES

Some (but not all) services allow you to supply a specific lifecycle of the
service. Right now, there is either C<Singleton> or no lifecycile at all, i.e.
a new object is created upon retrieval.

=head1 DEPENDENCY INJECTION

Some services allow you to choose dependencies, which will inject values right
into your object's attributes upon construction time. Currently the only syntax
for supplying a dependency is a hashref where the key is the I<service> and the
value is the I<attribute>. See L<IoC::Container> or the tests for examples.

=head1 METHODS

=item C<get>

Returns the actual object the service represents

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or post an issue
to http://github.com/jasonmay/perl6-ioc/

=head1 REFERENCE

=item L<IoC::Container>

=head1 SEE ALSO

=item IoC::ConstructorInjection

=item IoC::BlockInjection

=item IoC::Literal

=head1 AUTHOR

Jason May, <jason.a.may@gmail.com>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=end pod
