use v6;

use IRC::Client;
use PerlStore::FileStore;

class IRC::Client::Plugin::UserPoints {

	has Str $.db-file-name
		is readonly
		= 'userPoints.txt';

	has $.list-scores-max-user where * > 0 = +Inf;

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

	has Bool %.msg-confirm;

	# TODO Overflow check : -1 point if overflow
	# TODO Reduce message because spamming
	# TODO Save the current channel when adding a point
	multi method irc-all( $e where /^ (\w+) ([\+\+ | \-\-]) [\s+ (<-[ \n ]>+) ]? \s* $/ ) {
		my Str $user-name = $0.Str;
		my Str $operation = $1.Str;
		my $category = $2
			?? $2.Str
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

		if $e.?channel && %!msg-confirm{$e.?channel} {
			return %!user-points{$user-name}{$category} == $!target-points
				?? "Congratulations, $user-name reached $!target-points in $category!"
				!!  "$operation-name one point to $user-name in « $category » category";
		}

		Nil; # Do not generate message response
	}

	# TODO Total for !scores
	multi method irc-all( $e where { my $p = $!command-prefix; $e ~~ /^ $p "scores" [ \h+ $<nicks> = \w+]* \s* $/ } ) {
		unless $e.?channel {
			return;
		}

		unless keys %!user-points {
			return "No attributed points, yet!"
		}

		my @nicks = $<nicks>
			?? $<nicks>».Str
			!! keys %!user-points;

		if @nicks.elems > $!list-scores-max-user {
			return "Too much results, please be more specific in your request.";
		}

		for @nicks -> $user-name {
			my @rep;
			unless %!user-points{$user-name}:exists {
				$e.reply: "« $user-name » does not have any points yet.";
				next;
			}
			my $response = "« $user-name » points: ";
			for %!user-points{$user-name} -> %cat {
				for kv %cat -> $k, $v {
					# Check if the size is less than 512
					# "user: categ: 42, categ2: 42"
					if $e.channel.codes + $e.nick.codes + 2 + $response.codes + "$k: $v, ".codes + 20 > 512 {
						$e.reply: $response;
						$response = '... ';
					}
					$response ~= "$k: $v, ";
				}
				$response ~~ s/ ', ' $//;
				$e.reply: $response;
			}
		}
	}

	multi method irc-all( $e where { my $p = $!command-prefix; $e ~~ /^ $p "sum" [ \h+ $<nicks> = \w+]* \s* $/ } ) {
		my $sum = 0;

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

		return $sum
			?? "Total points : $sum"
			!! "No attributed points yet!";
	}

}
