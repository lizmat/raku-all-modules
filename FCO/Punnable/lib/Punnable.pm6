=begin pod

=head1 SYNOPSIS

=begin code
use Punnable;
role R {
	method r {...}
}
make-punnable(R);
my $or = R.new;     # runs OK
say $or;
$or.r               # fail executing stub code
=end code

=end pod

#| make-punnable transforms a role into a punnable role
#| that means that if that role has stub methods, the created
#| class will have the same methods.
sub make-punnable(\Role) is export {
	Role.HOW does role {
		#| Override the original make_pun to create stubmethods on the class
		method make_pun($obj) {
			my $pun := Metamodel::ClassHOW.new_type(:name(self.name($obj)));

			for $obj.^methods.grep({.?yada}).map: {.name} -> $stub {
				$pun.^add_method($stub, method () is hidden-from-backtrace {...})
			}

			$pun.^add_role: $obj;
			$pun.^compose;
			my $why := self.WHY;
			if $why {
				$pun.set_why(self.WHY);
			}
			$pun
		}
	}
}
