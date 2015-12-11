
unit module Net::FTP::Config;

enum FTP is export <
	FAIL OK
>;

enum MODE is export <
	ASCII BINARY
>;

enum FILE is export <
	NORMAL DIR LINK SOCKET PIPE CHAR BLOCK
>;

enum SOCKET_CLASS is export <
	INET ASYNC SSL
>;

# vim: ft=perl6
