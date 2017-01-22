use v6;

use IRC::Client;
use PerlStore::FileStore;

class IRC::Client::Plugin::UserPoints {

	has Str $.db-file-name
		is readonly
		= 'userPoints.txt';

	# Load the hash from $db-file-name if it is readable and writable
	has %!user-points
		=  ( $!db-file-name.IO.r && $!db-file-name.IO.w )
			?? from_file( $!db-file-name )
			!! Hash.new;

	has Str $.command-prefix
		is readonly
		where .chars > 0 && .chars <=1
		= '!';

	has Int $.target-points where * > 0 = 42;

	# TODO Overflow check : -1 point if overflow
	# TODO Reduce message because spamming
	# TODO Save the current channel when adding a point
	multi method irc-all( $e where /^ (\w+) ([\+\+ | \-\-]) [\s+ (<[ \w \s ]>+) ]? $/ ) {
		my Str $user-name = $0.Str;
		my Str $operation = $1.Str;
		my $category =  $2.Str
			?? $2
			!! 'main';

		# Check if $user-name is different from message sender
		return "Influencing points of himself is not possible."
			if $e.nick() ~~ $user-name;

		my $operation-name = '';

		given $operation {
			when '++' {
				%!user-points{$user-name}{$category} += 1 when '++';
				$operation-name = 'Adding';
			}
			when '--' {
				%!user-points{$user-name}{$category} -= 1 when '--';
				$operation-name = 'Removing';
			}
		}

		# Remove user's category if it reaches 0
		%!user-points{$user-name}{$category}:delete
			unless %!user-points{$user-name}{$category};

		# Remove user if he has no categories
		%!user-points{$user-name}:delete
			unless %!user-points{$user-name};

		# Save scores
		to_file( $!db-file-name, %!user-points );

		return %!user-points{$user-name}{$category} == $!target-points
			?? "Congratulations, $user-name reached $!target-points in $category!"
			!! "$operation-name one point to $user-name in « $category » category";
	}

	# TODO Total for !scores
	multi method irc-all( $e where { my $p = $!command-prefix; $e ~~ /^ $p "scores" [ \h+ $<nicks> = \w+]* $/ } ) {

		unless keys %!user-points {
			return "No attributed points, yet!"
		}

		my @nicks = $<nicks>
			?? $<nicks>».Str
			!! keys %!user-points;

		for @nicks -> $user-name {
			my @rep;
			unless %!user-points{$user-name}:exists {
				$e.reply: "« $user-name » does not have any points yet.";
				next;
			}
			for %!user-points{$user-name} -> %cat {
				for kv %cat -> $k, $v {
					push @rep, "$v in $k";
				}
			}
			$e.reply: "« $user-name » has some points : { join( ', ', @rep ) }";
		}
	}

	multi method irc-all( $e where { my $p = $!command-prefix; $e ~~ /^ $p "sum" [ \h+ $<nicks> = \w+]* $/ } ) {
		my $sum;

		my @nicks = $<nicks>
			?? $<nicks>».Str
			!! keys %!user-points;

		for @nicks -> $user-name {
			next unless %!user-points{$user-name}:exists;

			for %!user-points{$user-name} -> %cat {
				for kv %cat -> $k, $v {
					$sum += $v;
				}
			}
		}

		return "Total points : $sum";
	}

}
