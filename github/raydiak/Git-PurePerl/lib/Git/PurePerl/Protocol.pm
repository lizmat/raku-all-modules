class Git::PurePerl::Protocol::Git { ... };

class Git::PurePerl::Protocol {
#`[[[
use Git::PurePerl::Protocol::Git;
use Git::PurePerl::Protocol::SSH;
use Git::PurePerl::Protocol::File;
]]]

has Str $.remote = die "remote is required";
has $.read_socket is rw;
has $.write_socket is rw;

submethod new (:$remote!, |args) {
    given $remote {
        when m{^'git://'(.*?\@)?(.*?)(\/.*)} {
            Git::PurePerl::Protocol::Git.new(
                :$remote,
                |args,
                hostname => ~$1,
                project => ~$2,
            )
        }
        #`[[[
        when m{^'file://'(\/.*)} {
            Git::PurePerl::Protocol::File.new(
                :$remote,
                |args,
                path => ~$0,
            );
        }
        when m{^'ssh://'((.*?)\@)?(.*?)(\/.*)}
                     | m{^((.*?)\@)?(.*?)\:(.*)} {
            Git::PurePerl::Protocol::SSH.new(
                :$remote,
                |%args,
                $0 ?? (username => ~$0) !! (),
                hostname => ~$1,
                path => ~$2,
            );
        }
        ]]]
        die 'unrecognized remote';
    }
}

method connect {
    self.connect_socket;

    my %sha1s;
    while ( my $line = self.read_line() ) {

        # warn "S $line";
        my ( $sha1, $name ) = ~«@($line ~~ /^ (<[a..z0..9]>+) ' ' (.*?) [ \0 | \n | $ ]/);

        #use YAML; warn Dump $line;
        %sha1s{$name} = $sha1;
    }
    %sha1s;
}

method fetch_pack (Str:D $sha1) {
    self.send_line: "want $sha1 side-band-64k\n";

#send_line(
#    "want 0c7b3d23c0f821e58cd20e60d5e63f5ed12ef391 multi_ack side-band-64k ofs-delta\n"
#);
    self.send_line: '';
    self.send_line: 'done';

    my $pack;

    while ( my $line = self.read_line() ) {
        if ( $line ~~ s/^"\x02"// ) {
            print $line;
        } elsif ( $line ~~ /^NAK\n/ ) {
        } elsif ( $line ~~ s/^"\x01"// ) {
            $pack ~= $line;
        } else {
            die "Unknown line: $line";
        }

        #say "s $line";
    }
    return $pack.encode: 'latin-1';
}

method send_line ($line is copy) {
    $line = $line.encode: 'latin-1' unless $line ~~ Blob;
    my $length = $line.bytes;
    if ( $length == 0 ) {
    } else {
        $length += 4;
    }

    #warn "length $length";
    my $prefix = sprintf( "%04X", $length );
    my $text = $prefix.encode('latin-1') ~ $line;

    # warn "$text";
    self.write_socket.write: $text;
}

method read ($len) {
    my $ret = Buf[uint8].new;
    while $ret.bytes < $len {
        my $data = $.read_socket.read: $len - $ret.bytes;
        if (not defined $data) {
            die "error: $!";
        } elsif ( $data.bytes == 0 ) {
            die "EOF"
        }
        $ret ~= $data;
    }
    return $ret;
}

method read_line {
    my $socket = self.read_socket;

    my $prefix = self.read(4).decode: 'latin-1';

    return if $prefix eq '0000';

    # warn "read prefix [$prefix]";

    my $len = 0;
    for ^4 -> $n {
        my $c = substr $prefix, $n, 1;
        $len +<= 4;

        if ( $c ge '0' && $c le '9' ) {
            $len += ord($c) - ord('0');
        } elsif ( $c ge 'a' && $c le 'f' ) {
            $len += ord($c) - ord('a') + 10;
        } elsif ( $c ge 'A' && $c le 'F' ) {
            $len += ord($c) - ord('A') + 10;
        }
    }

    self.read($len - 4).decode: 'latin-1';
}

} # close ::Protocol



class Git::PurePerl::Protocol::Git is Git::PurePerl::Protocol {
    has Str $.hostname = die 'hostname is required';
    has Int $.port = 9418;
    has Str $.project is rw = die 'project is required';

    method connect_socket {
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
} # close ::Protocol::Git



# vim: ft=perl6
