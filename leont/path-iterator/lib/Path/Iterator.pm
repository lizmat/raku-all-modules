use v6;

unit class Path::Iterator;
has Sub @!rules;
our enum Prune is export(:prune) <Prune-Inclusive Prune-Exclusive>;

my %priority = (
	0 => <depth skip-hidden>,
	1 => <skip skip-dir skip-subdir skip-vcs>,
	2 => <name ext>,
	4 => <content line-match shebang>
).flatmap: { ($_ => $^pair.key for @($^pair.value)) };

our sub finder(*%options) is export(:find) {
	my @keys = %options.keys.sort: { %priority{$_} // 3 };
	return (Path::Iterator, |@keys).reduce: -> $current, $key {
		my $value = %options{$key};
		my $capture = do given $key {
			when any(<skip-dir skip-subdir depth name ext size path inode device mode nlinks uid gid accessed changed modified>) {
				\($value);
			}
			when any(<and or none skip>) {
				\(|@($value));
			}
			when 'shebang' {
				my ($regex, %options) = @($value);
				$regex === True ?? \(|%options) !! \($regex, |%options);
			}
			when any(<contents line-match>) {
				my ($regex, %options) = @($value);
				\($regex, |%options);
			}
			default {
				\();
			}
		}
		$current."$key"(|$capture);
	}
}

our sub find(*@dirs, *%options) is export(:DEFAULT :find) {
	my %in-options = %options<follow-symlinks order sorted loop-safe relative visitor as map>:delete:p;
	return finder(|%options).in(|@dirs, |%in-options);
}

submethod BUILD(:@!rules) { }
method !rules() {
	return @!rules;
}

my multi rulify(Sub $rule) {
	return $rule;
}
my multi rulify(Path::Iterator:D $rule) {
	return |$rule!rules;
}
multi method and(Path::Iterator:D $self: *@also) {
	return self.bless(:rules(|@!rules, |@also.map(&rulify)));
}
multi method and(Path::Iterator:U: *@also) {
	return self.bless(:rules(|@also.map(&rulify)));
}
method none(Path::Iterator:U: *@no) {
	return self.or(|@no).not;
}
method not() {
	my $obj = self;
	return self.bless(:rules[sub ($item, *%opts) {
		given $obj!test($item, |%opts) -> $original {
			when Prune {
				return Prune(+!$original);
			}
			default {
				return !$original;
			}
		}
	}]);
}
my multi unrulify(Sub $rule) {
	return Path::Iterator.and($rule);
}
my multi unrulify(Path::Iterator:D $iterator) {
	return $iterator;
}
multi method or(Path::Iterator:U: $rule) {
	return unrulify($rule);
}
multi method or(Path::Iterator:U: *@also) {
	my @iterators = |@also.map(&unrulify);
	my @rules = sub ($item, *%opts) {
		my $ret = False;
		for @iterators -> $iterator {
			given $iterator!test($item, |%opts) {
				when * === True {
					return True;
				}
				when Prune-Exclusive {
					$ret = $_;
				}
				when Prune-Inclusive {
					$ret = $_ if $ret === False;
				}
			}
		}
		return $ret;
	}
	return self.bless(:@rules);
}
method skip(*@garbage) {
	my @iterators = |@garbage.map(&unrulify);
	self.and: sub ($item, *%opts) {
		for @iterators -> $iterator {
			if $iterator!test($item, |%opts) !== False {
				return Prune-Inclusive;
			}
		}
		return True;
	};
}

method !test(IO::Path $item, *%args) {
	for @!rules -> &rule {
		unless rule($item, |%args) -> $value {
			return $value;
		}
	}
	return True;
}

method name(Mu $name) {
	self.and: sub ($item, *%) { $item.basename ~~ $name };
}
multi method ext(Mu $ext) {
	self.and: sub ($item, *%) { $item.extension ~~ $ext };
}
method path(Mu $path) {
	self.and: sub ($item, *%) { $item ~~ $path };
}
method dangling() {
	self.and: sub ($item, *%) { $item.l and not $item.e };
}
method not-dangling() {
	self.and: sub ($item, *%) { not $item.l or $item.e };
}

my %X-tests = %(
	:r('readable'),    :R('r-readable'),
	:w('writable'),    :W('r-writable'),
	:x('executable'),  :X('r-executable'),
	:o('owned'),       :O('r-owned'),

	:e('exists'),      :f('file'),
	:z('empty'),       :d('directory'),
	:s('nonempty'),    :l('symlink'),

	:u('setuid'),      :S('socket'),
	:g('setgid'),      :b('block'),
	:k('sticky'),      :c('character'),
	:p('fifo'),        :t('tty'),
);
for %X-tests.kv -> $test, $method {
	$?CLASS.^add_method: $method,       anon method () { return self.and: sub ($item, *%) { ?$item."$test"() } };
	$?CLASS.^add_method: "not-$method", anon method () { return self.and: sub ($item, *%) { !$item."$test"() } };
}

{
	use nqp;
	my %stat-tests = %(
		inode  => nqp::const::STAT_PLATFORM_INODE,
		device => nqp::const::STAT_PLATFORM_DEV,
		mode   => nqp::const::STAT_PLATFORM_MODE,
		nlinks => nqp::const::STAT_PLATFORM_NLINKS,
		uid    => nqp::const::STAT_UID,
		gid    => nqp::const::STAT_GID,
	);
	for %stat-tests.kv -> $method, $constant {
		$?CLASS.^add_method: $method, anon method (Mu $matcher) {
			self.and: sub ($item, *%) { nqp::stat(nqp::unbox_s(~$item), $constant) ~~ $matcher }
		}
	}
}
for <accessed changed modified> -> $time-method {
	$?CLASS.^add_method: $time-method, anon method (Mu $matcher) {
		self.and: sub ($item, *%) { $item."$time-method"() ~~ $matcher }
	}
}
$?CLASS.^compose;

method size(Mu $size) {
	self.and: sub ($item, *%) { $item.f && $item.s ~~ $size };
}
multi method depth(Range $depth-range) {
	self.and: sub ($item, :$depth, *%) {
		return do given $depth {
			when $depth-range.max {
				Prune-Exclusive;
			}
			when $depth-range {
				True;
			}
			when * < $depth-range.min {
				False;
			}
			default {
				Prune-Inclusive;
			}
		}
	};
}
multi method depth(Int $depth) {
	return self.depth($depth..$depth);
}
multi method depth(Mu $depth-match) {
	self.and: sub ($item, :$depth, *%) {
		return $depth ~~ $depth-match;
	}
}

method skip-dir(Mu $pattern) {
	self.and: sub ($item, *%) {
		if $item.basename ~~ $pattern && $item.d {
			return Prune-Inclusive;
		}
		return True;
	}
}
method skip-subdirs(Mu $pattern) {
	self.and: sub ($item, :$depth, *%) {
		if $depth > 0 && $item.basename ~~ $pattern && $item.d {
			return Prune-Inclusive;
		}
		return True;
	}
}
method skip-hidden() {
	self.and: sub ($item, :$depth, *%) {
		if $depth > 0 && $item.basename ~~ rx/ ^ '.' / {
			return Prune-Inclusive;
		}
		return True;
	}
}
my $vcs-dirs = any(<.git .bzr .hg _darcs CVS RCS .svn>, |($*DISTRO.name eq 'mswin32' ?? '_svn' !! ()));
my $vcs-files = none(rx/ '.#' $ /, rx/ ',v' $ /);
method skip-vcs() {
	return self.skip-dir($vcs-dirs).name($vcs-files);
}

method shebang(Mu $pattern = rx/ ^ '#!' /, *%opts) {
	self.and: sub ($item, *%) {
		return False unless $item.f;
		return $item.lines(|%opts)[0] ~~ $pattern;
	}
}
method contents(Mu $pattern, *%opts) {
	self.and: sub ($item, *%) {
		return False unless $item.f;
		return $item.slurp(|%opts) ~~ $pattern;
	}
}
method line-match(Mu $pattern, *%opts) {
	self.and: sub ($item, *%) {
		return False unless $item.f;
		for $item.lines(|%opts) -> $line {
			return True if $line ~~ $pattern;
		}
		return False;
	}
}

my &is-unique = $*DISTRO.name ne any(<MSWin32 os2 dos NetWare symbian>)
	?? sub (Bool %seen, IO::Path $item) {
		use nqp;
		my $inode = nqp::stat(nqp::unbox_s(~$item), nqp::const::STAT_PLATFORM_INODE);
		my $device = nqp::stat(nqp::unbox_s(~$item), nqp::const::STAT_PLATFORM_DEV);
		my $key = "$inode\-$device";
		return False if %seen{$key};
		return %seen{$key} = True;
	}
	!! sub (Bool %seen, IO::Path $item) { return True };

enum Order is export(:DEFAULT :order) < BreadthFirst PreOrder PostOrder >;

my %as{Any:U} = ((Str) => { ~$_ }, (IO::Path) => Sub);
method in(*@dirs,
	Bool:D :$follow-symlinks = True,
	Order:D :$order = BreadthFirst,
	Bool:D :$sorted = True,
	Bool:D :$loop-safe = True,
	Bool:D :$relative = False,
	Any:U :$as = IO::Path,
	:&map = %as{$as},
	:&visitor,
) {
	my @queue = (@dirs || '.').map(*.IO).map: { ($^path, 0, $^path, Bool) };

	my Bool %seen;
	my $seq := gather while @queue {
		my ($item, $depth, $origin, $result) = @( @queue.shift );

		without ($result) {
			$result = self!test($item, :$depth, :$origin);

			visitor($item) if &visitor && $result;

			if $result !~~ Prune && $item.d && (!$loop-safe || is-unique(%seen, $item)) && ($follow-symlinks || !$item.l) {
				my @next = $item.dir.map: { ($^child, $depth + 1, $origin, Bool) };
				@next .= sort if $sorted;
				given $order {
					when BreadthFirst {
						@queue.append: @next;
					}
					when PostOrder {
						@next.push: ($item, $depth, $origin, $result);
						@queue.prepend: @next;
						next;
					}
					when PreOrder {
						@queue.prepend: @next;
					}
				}
			}
		}

		take $relative ?? $item.relative($origin).IO !! $item if $result;
	}
	return &map ?? $seq.map(&map) !! $seq;
}
