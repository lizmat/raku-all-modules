

unit class Net::FTP::Conn;

has $.SOCKET;
has $.host;
has $.port;
has $.conn;

#	%args
#	host port family encoding client
method new (*%args) {
	self.bless(|%args);
}

submethod BUILD(:$SOCKET = IO::Socket::INET,
		:$host,
		:$port = 21,
		*%args) {
	$!SOCKET	= $SOCKET;
	$!host		= $host;
	$!port 		= $port;
	$!conn 		= $!SOCKET.new(:host($!host), :port($port), |%args);
	fail("Connect failed!") unless $!conn ~~ $!SOCKET;
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
