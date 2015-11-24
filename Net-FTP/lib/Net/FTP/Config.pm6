
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


# vim: ft=perl6
