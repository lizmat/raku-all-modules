
use Net::FTP::Conn;
use Net::FTP::Config;
use Net::FTP::Buffer;
use Net::FTP::Format;

unit class Net::FTP::Transfer is Net::FTP::Conn;

has $.ascii;

#	%args 
#	host port passive ascii family encoding
method new (*%args is copy) {
	%args<listen> = %args<passive>;
    %args<input-line-separator> = "\r\n";
	nextsame(|%args);
}

method readlist() {
	my @infos;

	while (my $buf = self.recv(:bin)) {
		for split($buf, Buf.new(0x0d, 0x0a)) {
			push @infos, format($_.unpack("A*"));
		}
	}

	@infos;
}

method readline() {
    return self.getline();
}

method readlines() {
    my @lines;

    while my $line = self.readline() {
        @lines.push: $line;
    }

    return @lines;
}

method readall(Bool :$bin? = False) {
    my @infos;

    while (my $buf = self.recv(:bin($bin))) {
        @infos.push: $buf;
    }

    return @infos;
}

method read(Bool :$bin? = False) {
    return self.recv(:bin($bin.defined));
}

# vim: ft=perl6
