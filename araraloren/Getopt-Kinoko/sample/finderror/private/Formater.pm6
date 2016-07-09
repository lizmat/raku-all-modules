
use v6;

use Errno;
use RefOptionSet;
use NIException;

role Formater does RefOptionSet {
	method format(Errno $errno) {
		X::NotImplement.new().throw();
	}
}

class Formater::Normal does Formater {
	method format(Errno $errno) {
		my \optset := self.optset();
		my Str @ret;
		my ($need-errno, $need-number, $need-comment) = 
			(optset{'errno'}, optset{'number'}, optset{'comment'});

		if optset{'show-all'} ||
			 (!$need-errno && !$need-number && !$need-comment) {
			$need-errno = $need-number = $need-comment = True;
		}

		@ret.push: $errno.errno if $need-errno;
		@ret.push: $errno.number if $need-number;
		@ret.push: $errno.comment if $need-comment;

		@ret.join("\t");
	}
}

class Formater::Table does Formater {

}
