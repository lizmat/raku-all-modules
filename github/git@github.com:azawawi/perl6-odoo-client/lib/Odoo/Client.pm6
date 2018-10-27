use v6;
use JSON::RPC::Client;
use Odoo::Client::Model;

unit class Odoo::Client;

=begin pod

=head1 Name

Odoo::Client - A simple Odoo ERP client that uses JSON RPC

=head1 Synopsis

    use v6;
    use Odoo::Client;

    my $odoo = Odoo::Client.new(
        hostname => "localhost",
        port     => 8069
    );

    my $uid = $odoo.login(
        database => "<database>",
        username => '<email>',
        password => "<password>"
    );

    printf("Logged on with user id '%d'\n", $uid);

=head1 Description

A simple L<Odoo|http://odoo.com> ERP client that uses JSON RPC.

=head1 Documentation

=head2 Attributes

=end pod

has JSON::RPC::Client $!client;
has Str $!database;
has Str $!username;
has Str $!password;
has Int $!uid;

=begin pod

=head2 Methods

=head3 new(Str :$hostname, Int :$port)

Returns a Odoo::Client object that is associated with Odoo instance. You need to
call C<login> to actually start doing useful operations.
=end pod
submethod BUILD(Str :$hostname, Int :$port) {
    my $url = sprintf("http://%s:%d/jsonrpc", $hostname, $port);
    $!client = JSON::RPC::Client.new(url => $url);
}

=begin pod
=head3 version returns Hash

Returns a hash of Odoo version information.
=end pod
method version() returns Hash {
    my $version = $!client.call(
        service => "common",
        method  => "version",
        args    => []
    );
    return $version;
}

=begin pod
=head3 login(Str :$database, Str :$username, Str :$password) {

Logins to the Odoo database with provided authentication credentials.
=end pod
method login(Str :$database, Str :$username, Str :$password) {
    my $uid = $!client.call(
        service => "common",
        method  => "login",
        args    => [$database, $username, $password]
    );
    if $uid.defined {
        $!database = $database;
        $!username = $username;
        $!password = $password;
        $!uid      = $uid;
    }
    return $uid;
}

=begin pod
=head3 invoke(Str :$model, Str :$method, :$method-args)

Invoke a method on a model and returns its results
=end pod
multi method invoke(Str :$model, Str :$method, :$method-args) {
    my @args = [$!database, $!uid, $!password, $model, $method, $method-args];
    my $result = $!client.call(
        service => "object",
        method  => "execute",
        args    => @args
    );
    return $result;
}

=begin pod
=head3 model(Str $name)

Returns an C<Odoo::Client::Model> model. This is a helper method.

=end pod
#TODO should create a model proxy by queries fields for that model
method model(Str $name) {

    # Create the model proxy
    my $model = Odoo::Client::Model.new(
        :client(self),
        :name($name)
    );

    # Workaround for button-immediate-install
    if $name eq 'ir.module.module' {
        #TODO make this more generic by querying Odoo model
        $model.^add_method('button-immediate-install', method ($args){
            my $result = $!client.invoke(
                model       => 'ir.module.module',
                method      => 'button_immediate_install',
                method-args => $args
            );
            return $result;
        })
    }

    return $model;
}

=begin pod
=head1 See Also

=item L<JSON::RPC|https://github.com/bbkr/jsonrpc>
=item L<Odoo ERP|http://odoo.com>
=item L<JSON-RPC Library|https://www.odoo.com/documentation/10.0/howtos/backend.html#json-rpc-library>

=head1 Author

Ahmad M. Zawawi, L<azawawi|https://github.com/azawawi> on C<#perl6>

=head1 LICENSE

MIT License

=end pod
