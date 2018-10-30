use v6;

unit class Path::Iterator;
has Callable:D @!rules;
our enum Prune is export(:prune) <PruneInclusive PruneExclusive>;

submethod BUILD(:@!rules) { }
method !rules() {
	return @!rules;
}

my multi rulify(Callable $rule) {
	return $rule;
}
my multi rulify(Path::Iterator:D $rule) {
	return $rule!rules;
}
proto method and(*@ --> Path::Iterator:D) { * }
multi method and(Path::Iterator:D $self: *@also --> Path::Iterator:D) {
	return self.bless(:rules(|@!rules, |@also.map(&rulify)));
}
multi method and(Path::Iterator:U: *@also --> Path::Iterator:D) {
	return self.bless(:rules(|@also.map(&rulify)));
}
multi method none(Path::Iterator:U: *@no --> Path::Iterator:D) {
	return self.or(|@no).not;
}
multi method none(Path::Iterator: Callable $rule --> Path::Iterator:D) {
	return self.and: sub ($item, *%options) { return negate($rule($item, |%options)) };
}

my multi negate(Bool $value) {
	return !$value;
}
my multi negate(Prune $value) {
	return Prune(+!$value)
}
method not(--> Path::Iterator:D) {
	my $obj = self;
	return self.bless(:rules[sub ($item, *%opts) {
		return negate($obj!test($item, |%opts))
	}]);
}
my multi unrulify(Callable $rule) {
	return Path::Iterator.and($rule);
}
my multi unrulify(Path::Iterator $iterator) {
	return $iterator;
}
proto method or(*@ --> Path::Iterator:D) { * }
multi method or(Path::Iterator:U: $rule --> Path::Iterator:D) {
	return unrulify($rule);
}
multi method or(Path::Iterator:U: *@also --> Path::Iterator:D) {
	my @iterators = |@also.map(&unrulify);
	my @rules = sub ($item, *%opts) {
		my $ret = False;
		for @iterators -> $iterator {
			given $iterator!test($item, |%opts) {
				when * === True {
					return True;
				}
				when PruneExclusive {
					$ret = $_;
				}
				when PruneInclusive {
					$ret = $_ if $ret === False;
				}
			}
		}
		return $ret;
	}
	return self.bless(:@rules);
}
method skip(*@garbage --> Path::Iterator:D) {
	my @iterators = |@garbage.map(&unrulify);
	self.and: sub ($item, *%opts) {
		for @iterators -> $iterator {
			if $iterator!test($item, |%opts) !== False {
				return PruneInclusive;
			}
		}
		return True;
	};
}

method !test(IO::Path $item, *%args) {
	my $ret = True;
	for @!rules -> &rule {
		my $value = rule($item, |%args);
		return $value unless $value;
		$ret = $value if $value === PruneExclusive;
	}
	return $ret;
}

my sub add-method(Str $name, Method $method) {
	$method.set_name($name);
	$?CLASS.^add_method($name, $method);
}
my sub add-boolean(Str $sub-name, &rule) {
	add-method($sub-name, method (--> Path::Iterator:D) {
		self.and: &rule;
	});
	add-method("not-$sub-name", method (--> Path::Iterator:D) {
		self.none: &rule;
	});
}
my sub add-matchable(Str $sub-name, &match-sub) {
	add-method($sub-name, method (Mu $matcher, *%opts --> Path::Iterator:D) {
		self.and: match-sub($matcher, |%opts);
	});
	add-method("not-$sub-name", method (Mu $matcher, *%opts --> Path::Iterator:D) {
		self.none: match-sub($matcher, |%opts);
	});
}

add-matchable('name', sub (Mu $name) { sub ($item, *%) { $item.basename ~~ $name } });
add-matchable('ext', sub (Mu $ext) { sub ($item, *%) { $item.extension ~~ $ext } });
add-matchable('path', sub (Mu $path) { sub ($item, *%) { $item ~~ $path } });

add-boolean('dangling', sub ($item, *%) { $item.l and not $item.e });

my %X-tests = %(
	:r('readable'),
	:w('writable'),
	:x('executable'),

	:rw('read-writable'),
	:rwx('read-write-executable')

	:e('exists'),
	:f('file'),
	:d('directory'),
	:l('symlink'),
	:z('empty'),
);
for %X-tests.kv -> $test, $method {
	add-boolean($method, sub ($item, *%) { ?$item."$test"() });
}

{
	use nqp;
	my %stat-tests = %(
		inode  => nqp::const::STAT_PLATFORM_INODE,
		device => nqp::const::STAT_PLATFORM_DEV,
		nlinks => nqp::const::STAT_PLATFORM_NLINKS,
		uid    => nqp::const::STAT_UID,
		gid    => nqp::const::STAT_GID,
	);
	for %stat-tests.kv -> $method, $constant {
		add-matchable($method, sub (Mu $matcher) { sub ($item, *%) { nqp::stat(nqp::unbox_s(~$item), $constant) ~~ $matcher } });
	}
}
for <accessed changed modified mode> -> $stat-method {
	add-matchable($stat-method, sub (Mu $matcher) { sub ($item, *%) { $item."$stat-method"() ~~ $matcher } });
}

add-matchable('size', sub (Mu $size) { sub ($item, *%) { $item.f && $item.s ~~ $size }; });

proto method depth($ --> Path::Iterator:D) { * }
multi method depth(Range $depth-range where .is-int --> Path::Iterator:D) {
	my ($min, $max) = $depth-range.int-bounds;
	self.and: sub ($item, :$depth, *%) {
		return do given $depth {
			when $max {
				PruneExclusive;
			}
			when $depth-range {
				True;
			}
			when * < $min {
				False;
			}
			default {
				PruneInclusive;
			}
		}
	};
}
multi method depth(Int $depth --> Path::Iterator:D) {
	return self.depth($depth..$depth);
}
multi method depth(Mu $depth-match --> Path::Iterator:D) {
	sub ($item, :$depth, *%) {
		return $depth ~~ $depth-match;
	}
}

proto method not-depth($ --> Path::Iterator:D) { * }
multi method not-depth(Range $depth-range where .is-int --> Path::Iterator:D) {
	my ($min, $max) = $depth-range.int-bounds;
	if $min == 0 {
		return self.depth(($max + 1) .. Inf);
	}
	elsif $max == Inf {
		return self.depth(^$min);
	}
	else {
		nextsame;
	}
}
multi method not-depth(Int $depth --> Path::Iterator:D) {
	return self.not-depth($depth..$depth);
}
multi method not-depth(Mu $depth-match --> Path::Iterator:D) {
	self.and: sub ($item, :$depth, *%) {
		return $depth !~~ $depth-match;
	}
}

method skip-dir(Mu $pattern --> Path::Iterator:D) {
	self.and: sub ($item, *%) {
		if $item.basename ~~ $pattern && $item.d {
			return PruneInclusive;
		}
		return True;
	}
}
method skip-subdir(Mu $pattern --> Path::Iterator:D) {
	self.and: sub ($item, :$depth, *%) {
		if $depth > 0 && $item.basename ~~ $pattern && $item.d {
			return PruneInclusive;
		}
		return True;
	}
}
method skip-hidden( --> Path::Iterator:D) {
	self.and: sub ($item, :$depth, *%) {
		if $depth > 0 && $item.basename ~~ rx/ ^ '.' / {
			return PruneInclusive;
		}
		return True;
	}
}
my $vcs-dirs = any(<.git .bzr .hg _darcs CVS RCS .svn>, |($*DISTRO.name eq 'mswin32' ?? '_svn' !! ()));
my $vcs-files = none(rx/ '.#' $ /, rx/ ',v' $ /);
method skip-vcs(--> Path::Iterator:D) {
	return self.skip-dir($vcs-dirs).name($vcs-files);
}

add-matchable('shebang', sub (Mu $pattern = rx/ ^ '#!' /, *%opts) {
	sub ($item, *%) {
		return False unless $item.f;
		return $item.lines(|%opts)[0] ~~ $pattern;
	}
});
add-matchable('contents', sub (Mu $pattern, *%opts) {
	sub ($item, *%) {
		return False unless $item.f;
		return $item.slurp(|%opts) ~~ $pattern;
	}
});
add-matchable('line', sub (Mu $pattern, *%opts) {
	sub ($item, *%) {
		return False unless $item.f;
		for $item.lines(|%opts) -> $line {
			return True if $line ~~ $pattern;
		}
		return False;
	}
});

$?CLASS.^compose;

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

my %as{Any:U} = ((Str) => { ~$_ }, (IO::Path) => Block);
multi method in(Path::Iterator:D:
	*@dirs,
	Bool:D :$follow-symlinks = True,
	Bool:D :$report-symlinks = $follow-symlinks,
	Order:D :$order = BreadthFirst,
	Bool:D :$sorted = True,
	Bool:D :$loop-safe = True,
	Bool:D :$relative = False,
	Any:U :$as = IO::Path,
	:&map = %as{$as},
	--> Seq:D
) {
	my @queue = (@dirs || '.').map(*.IO).map: { ($^path, 0, $^path, Bool) };

	my Bool $check-symlinks = !$follow-symlinks || !$report-symlinks;
	my Bool %seen;
	my $seq := gather while @queue {
		my ($item, $depth, $base, $result) = @( @queue.shift );

		without ($result) {
			my $is-link = $check-symlinks ?? $item.l !! False;
			next if $is-link && !$report-symlinks;

			$result = self!test($item, :$depth, :$base);
			my $prune = $result ~~ Prune || $is-link && !$follow-symlinks;

			if !$prune && $item.d && (!$loop-safe || is-unique(%seen, $item)) {
				my @next = $item.dir.map: { ($^child, $depth + 1, $base, Bool) };
				@next .= sort if $sorted;
				given $order {
					when BreadthFirst {
						@queue.append: @next;
					}
					when PostOrder {
						@next.push: ($item, $depth, $base, $result);
						@queue.prepend: @next;
						next;
					}
					when PreOrder {
						@queue.prepend: @next;
					}
				}
			}
		}

		take $relative ?? $item.relative($base).IO !! $item if $result;
	}
	return &map ?? $seq.map(&map) !! $seq;
}

multi method in(Path::Iterator:U: *@dirs, *%options --> Seq:D){
	return self.new.in(|@dirs, |%options);
}

my %priority = (
	0 => <skip-hidden skip skip-dir skip-subdir skip-vcs>,
	1 => <depth>,
	2 => <name ext path>,
	4 => <content line shebang>,
	5 => <not>
).flatmap: { ($_ => $^pair.key for @($^pair.value)) };

our sub finder(Path::Iterator :$base = Path::Iterator, *%options --> Path::Iterator) is export(:find) {
	my @keys = %options.keys.sort: { %priority{$_} // 3 };
	return ($base, |@keys).reduce: -> $object, $name {
		my $method = $object.^lookup($name);
		die "Finder key $name invalid" if not $method.defined or $method.signature.returns !~~ Path::Iterator;
		my $value = %options{$name};
		my $capture = $value ~~ Capture ?? $value !! do given $method.signature.count - 1 {
			when 0 {
				\();
			}
			when 1 {
				\($value);
			}
			when Inf {
				\(|@($value).map: -> $entry { $entry ~~ Hash|Pair ?? finder(|%($entry)) !! $entry });
			}
		}
		$object.$method(|$capture);
	}
}

our sub find(*@dirs, *%options --> Seq:D) is export(:DEFAULT :find) {
	my %in-options = %options<follow-symlinks order sorted loop-safe relative as map>:delete:p;
	return finder(|%options).in(|@dirs, |%in-options);
}
