use v6;

unit role Cofra::Singleton[Str $key];

my %SINGLETONS;

method instance(::?CLASS: |args) {
    %SINGLETONS{ $key } //= self.new(|args);
}

=begin pod

=head1 NAME

Cofra::Singleton - when there can only be one

=head1 SYNOPSIS

    use Cofra::Singleton;

    unit class MyApp::One does Cofra::Singleton['myapp-one'];

    # much later
    use MyApp::One;

    my $thing = MyApp::One.instance;

=head1 DESCRIPTION

For those objects where you want to make sure there is only ever one of them in
the whole process.

=head1 METHODS

=head2 method instance

    method instance(::?CLASS: |args)

Calls the C<.new> method of the object with the given C<|args> (though, if you're being properly purist, you should never pass args because passing args defeats part of how the singleton pattern works). After the first object is constructed, that object will be reused for every future call to the C<.instance> method.

=end pod
