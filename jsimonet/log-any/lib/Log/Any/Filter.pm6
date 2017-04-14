use v6.c;

use Log::Any::Definitions;

class Log::Any::Filter {
	proto method filter returns Bool { * }
}

class Log::Any::FilterBuiltIN is Log::Any::Filter {
	has Pair @.checks where .value ~~ Str | Regex | List;
	has %.severities = %Log::Any::Definitions::SEVERITIES;

	# TODO: gives the ability to filter on the dateTime ?
	method filter( :$msg!, :$severity!, :$category! ) returns Bool {

		for @!checks -> $f {
			given $f.key {
				when 'severity' {
					given $f.value {
						when /^ '<=' / {
							return False unless %!severities{$severity} <= %!severities{$f.value.substr(2)};
						}
						when /^ '>=' / {
							return False unless %!severities{$severity} >= %!severities{$f.value.substr(2)};
						}
						when /^ '<' / {
							return False unless %!severities{$severity} < %!severities{$f.value.substr(1)};
						}
						when /^ '>' / {
							return False unless %!severities{$severity} > %!severities{$f.value.substr(1)};
						}
						when /^ '=' / {
							return False unless %!severities{$severity} == %!severities{$f.value.substr(1)};
						}
						when /^ '!=' / {
							return False unless %!severities{$severity} !== %!severities{$f.value.substr(2)};
						}
						when Str {
							return False unless $severity ~~ $f.value;
						}
						when Array {
							return so $severity ~~ any( %!severities{$f.value}:k );
						}
						default {
							return False;
						}
					}
				}
				when 'category' {
					#note "checking $f.key() with $f.value().perl()";
					return False unless $category ~~ $f.value();
				}
				when 'msg' {
					#note "checking $f.key() with $f.value().perl()";
					if $msg {
						return False unless $msg ~~ $f.value();
					}
				}
				default {
					#note "default, oops";
					return False;
				}
			}
		}
		return True;
	}
}
