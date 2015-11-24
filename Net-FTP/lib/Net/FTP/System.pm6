
use NativeCall;

unit module Net::FTP::System;

sub time () returns int is native('libc.so.6') is export { * }

class tm is repr('CStruct') is export {
	has int $.sec;
	has int $.min;
	has int $.hour;
	has int $.mday;
	has int $.mon;
	has int $.year;
	has int $.wday;
	has int $.yday;
	has int $.isdst;

	method sec() { $!sec }

	method init {
		$!sec = $!min = $!hour =
		$!mday = $!mon = $!year =
		$!wday = $!yday = $!isdst = 0;
	}
}

sub gmtime (Pointer) returns Pointer is native('libc.so.6') is export { * }

# vim: ft=perl6
