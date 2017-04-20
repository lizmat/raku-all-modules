
use Net::FTP::Conn;
use Net::FTP::Config;
use Net::FTP::Buffer;
use Net::FTP::Format;
use experimental :pack;

unit class Net::FTP::Transfer is Net::FTP::Conn;

has $.ascii;

#	%args
#	host port passive ascii family encoding
method new (*%args) {
	%args<listen> = !%args<passive>;
    %args<input-line-separator> = "\r\n";
	self.bless(|%args);
}

submethod BUILD(:$!ascii) {
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
    my @infos;my $i = 0;

    while (my $buf = self.recv(:bin($bin))) {
        @infos.push: $buf;
    }

    return @infos;
}

method read(Bool :$bin? = False) {
    return self.recv(:bin($bin.defined));
}

# vim: ft=perl6
