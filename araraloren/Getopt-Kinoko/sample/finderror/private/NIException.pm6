
use v6;

unit class X::NotImplement is Exception;

has $.msg handles <Str>;

method message() {
	$!msg;
}