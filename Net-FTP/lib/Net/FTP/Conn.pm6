

unit class Net::FTP::Conn;

has $.SOCKET;
has $.host;
has $.port;
has $!conn;

#	%args
#	host port family encoding client
method new (*%args is copy) {
	unless %args<port> {
		%args<port> = 21;
	}
	unless %args<SOCKET> {
		%args<SOCKET> = IO::Socket::INET;
	}
	self.bless(|%args)!connect(|%args);
}

method !connect(*%args) {
	$!conn = $!SOCKET.new(|%args);
	fail("Connect failed!") unless $!conn ~~ $!SOCKET;
	self;
}

multi method sendcmd(Str $cmd) {
	$!conn.print: $cmd ~ "\r\n";
}

multi method sendcmd(Str $cmd, Str $para) {
	$!conn.print: $cmd ~ " $para" ~ "\r\n";
}

method recv (:$bin?) {
    $bin ?? $!conn.recv(:bin) !! $!conn.recv();
}

method getline() {
    $!conn.get();
}

method lines() {
    $!conn.lines();
}

multi method send(Str $str) {
	$!conn.print: $str;
}

multi method send(Buf $buf) {
	$!conn.write: $buf;	
}

method close() {
	$!conn.close(); 
}

method host() {
	$!host;
}

method port() {
	$!port;
}

# vim: ft=perl6
