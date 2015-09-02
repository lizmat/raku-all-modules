class Path::Iterator {
	has @.rules;
	enum Prune <Prune-inclusive Prune-exclusive>;

	my multi rulify(Callable $rule) {
		return $rule;
	}
	my multi rulify(Path::Iterator:D $rule) {
		return $rule.rules;
	}
	method and(Path::Iterator:D $self: *@also) {
		return self.bless(:rules(@!rules, @also.map(&rulify)));
	}
	method not(*@no) {
		my $obj = self.new.and(|@no);
		return self.and(sub ($item) {
			given $obj.test($item) -> $original {
				when Prune {
					return Prune(+!$original);
				}
				default {
					return !$original;
				}
			}
		});
	}
	my multi unrulify(Callable $rule) {
		return Path::Iterator.new(:rules[$rule]);
	}
	my multi unrulify(Path::Iterator:D $iterator) {
		return $iterator;
	}
	method or(*@also) {
		my @iterators = self, @also.map(&unrulify);
		my $rule = sub ($item) {
			for @iterators -> $iterator {
				return True if $iterator.test($item);
			}
			return False;
		}
		return self.bless(:rules[$rule]);
	}
	method skip(*@garbage) {
		my $obj = self.new.or(|@garbage);
		self.and(sub ($item, $base) {
			given $obj.test($item, $base) {
				when Prune {
					return Prune-inclusive;
				}
				when True {
					return Prune-inclusive;
				}
				when False {
					return True;
				}
			}
		});
	}

	method test($item) {
		for @!rules -> &rule {
			return False if not rule($item);
		}
		return True;
	}

	method name($name) {
		self.and: sub ($item) { $item.basename ~~ $name };
	}
	method dangling() {
		self.and: sub ($item) { $item.l && !$item.e };
	}

	BEGIN {
		my $package = $?CLASS;
		my %X-tests = %(
			:r('readable'),    :R('r_readable'),
			:w('writable'),    :W('r_writable'),
			:x('executable'),  :X('r_executable'),
			:o('owned'),       :O('r_owned'),

			:e('exists'),      :f('file'),
			:z('empty'),       :d('directory'),
			:s('nonempty'),    :l('symlink'),

			:u('setuid'),      :S('socket'),
			:g('setgid'),      :b('block'),
			:k('sticky'),      :c('character'),
			:p('fifo'),        :t('tty'),
		);
		for %X-tests.kv -> $test, $method {
			my $rule = sub ($item) { ?$item."$test"() };
			$package.HOW.add_method: $package, $method, method () { return self.and($rule); };
			$package.HOW.add_method: $package, "not-$method", method () { return self.not($rule) };
		}
	}
	method size ($size) {
		self.and: sub ($item) { $item.f && $item.s ~~ $size };
	}
	method depth (Range $depth-range) {
		self.and: sub ($item) {
			my $depth = ...;
			return do given $depth {
				when $depth-range.max {
					Prune-exclusive;
				}
				when $depth-range {
					True;
				}
				when * < $depth-range.min {
					False;
				}
				default {
					Prune-inclusive;
				}
			}
		};
	}
	method skip-dirs(*@patterns) {
		self.and: sub ($item) {
			if $item.d && $item ~~ any(@patterns) {
				return Prune(False);
			}
			return True;
		}
	}
	method skip-subdirs(*@patterns) {
		self.and: sub ($item) {
			if $item.d && $item.Str ne $item.basename && $item ~~ any(@patterns) {
				return Prune(False);
			}
			return True;
		}
	}
	method shebang($pattern) {
		self.and: sub ($item) {
			return False unless $item.f;
			my $first = $item.lines[0];
			return $first ~~ $pattern;
		}
	}
	method contents($pattern) {
		self.and: sub ($item) {
			return False unless $item.f;
			my $content = $item.slurp;
			return $content ~~ $pattern;
		}
	}
	method line-match($pattern) {
		self.and: sub ($item) {
			return False unless $item.f;
			for $item.lines -> $line {
				return True if $line ~~ $pattern;
			}
			return False;
		}
	}

	method !is-unique(IO::Path $item, *%opts) {
		return True; # XXX
	}
	method iter(*@dirs, Bool :$follow-symlinks = True, Bool :$depthfirst = False, Bool :$sorted = True, Bool :$loop-safe = True, Bool :$relative = False, :&visitor?, :&error-handler = sub ($item, $reason) { die sprintf "%s: %s\n", $item, $reason }) {
		@dirs = '.' if not @dirs;
		my @queue = @dirs.map: -> $filename {
			my $path = $filename.IO;
			[ $path, 0, $path ];
		};

		gather {
			while @queue.elems {
				my ($item, $depth, $origin) = @( @queue.shift );

				redo if not $follow-symlinks and $item.l;

				my $result = @!rules ?? self.test($item) !! True;

				if &visitor && $result {
					visitor($item);
				}

				if $item.d && $result !~~ Prune && (!$loop-safe || self!is-unique($item)) {
					my $depth-p1 = $depth + 1;
					my @next = $item.dir(test => none('.', '..')).map: -> $child { [ $child, $depth + 1, $origin ] };
					@next .= sort if $sorted;
					# depthfirst
					@queue.push: @next;
				}

				take $relative ?? $item.relative($origin) !! $item if $result;
			}
		}
	}
}

