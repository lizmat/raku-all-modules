class Git::PurePerl::Protocol::Git is Git::PurePerl::Protocol;

has Str $.hostname = die 'hostname is required';
has Int $.port = 9418;
has Str $.project is rw = die 'project is required';

sub connect_socket {
    my $socket = IO::Socket::INET.new:
        host => $.hostname,
        :$.port,
        proto => 'TCP';
    self.read_socket = $socket;
    self.write_socket = $socket;

    self.send_line( "git-upload-pack "
            ~ $.project
            ~ "\0host="
            ~ $.hostname
            ~ "\0" );
}

# vim: ft=perl6
