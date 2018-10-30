
use v6;

unit class Odoo::Client::Model;

has $.client;
has Str $.name;

=begin pod

=head1 Name

Odoo::Client::Model - An oddo client model

=head1 Synopsis

    my $user-model = $odoo.model( 'res.users' );
    my $user-ids   = $user-model.search( [] );
    say "user-ids: " ~ $user-ids.perl;

=head1 Description

This provides CRUD and search/filter operation on the selected Odoo model.

=head1 Documentation

=head2 Methods

=end pod

=begin pod
=head3 create(%args)

=end pod
method create( %args ) {
    return $.client.invoke(
        model       => $.name,
        method      => 'create',
        method-args => %args
    );
}

=begin pod
=head3 search(%args)

=end pod
method search( *@args ) {
    return $.client.invoke(
        model  => $.name,
        method => 'search',
        method-args  => @args
    );
}

=begin pod
=head3 read(%args)

=end pod
method read( *@args ) {
    return $.client.invoke(
        model  => $.name,
        method => 'read',
        method-args   => @args
    );
}
