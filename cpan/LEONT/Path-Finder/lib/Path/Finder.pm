use v6;

unit class Path::Finder:ver<0.1.0>;

use IO::Glob;

has Callable:D @!rules;
our enum Prune is export(:prune) <PruneInclusive PruneExclusive>;

submethod BUILD(:@!rules) { }
method !rules() {
	return @!rules;
}

our enum Precedence is export(:traits) <Skip Depth Name Stat Content And None Or Not>;

our role Constraint {
	has Precedence:D $.precedence is required;
}

multi sub trait_mod:<is>(Method $method, Precedence:D :$constraint!) is export(:traits) {
	trait_mod:<of>($method, Path::Finder:D);
	return $method does Constraint($constraint);
}

my multi rulify(Callable $rule) {
	return $rule;
}
my multi rulify(Path::Finder:D $rule) {
	return $rule!rules;
}
proto method and(*@) is constraint(And) { * }
multi method and(Path::Finder:D $self: *@also) {
	return self.bless(:rules(flat @!rules, @also.map(&rulify)));
}
multi method and(Path::Finder:U: *@also) {
	return self.bless(:rules(flat @also.map(&rulify)));
}
proto method none(|) is constraint(None) { * }
multi method none(Path::Finder:U: *@no) {
	return self.or(|@no).not;
}
multi method none(Path::Finder:D: Callable $rule) {
	return self.and: sub ($item, *%options) { return negate($rule($item, |%options)) };
}

my multi negate(Bool() $value) {
	return !$value;
}
my multi negate(Prune $value) {
	return Prune(+!$value)
}
method not() {
	my $obj = self;
	return self.bless(:rules[sub ($item, *%opts) {
		return negate($obj!test($item, |%opts))
	}]);
}
my multi unrulify(Callable $rule) {
	return Path::Finder.and($rule);
}
my multi unrulify(Path::Finder $iterator) {
	return $iterator;
}
proto method or(*@) is constraint(Or) { * }
multi method or(Path::Finder:U: $rule) {
	return unrulify($rule);
}
multi method or(Path::Finder:U: *@also)  {
	my @iterators = |@also.map(&unrulify);
	my @rules = sub ($item, *%opts) {
		my $ret = False;
		for @iterators -> $iterator {
			given $iterator!test($item, |%opts) {
				when PruneExclusive {
					return PruneExclusive;
				}
				when * === True {
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
method skip(*@garbage) is constraint(Skip) {
	my @iterators = |@garbage.map(&unrulify);
	self.and: sub ($item, *%opts) {
		for @iterators -> $iterator {
			my $var = $iterator!test($item, |%opts);
			if $var || $var ~~ Prune {
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

my multi sub globulize(Any $name) {
	return $name;
}
my multi sub globulize(Str $name) {
	return glob($name);
}

method name(Mu $name) is constraint(Name) {
	my $matcher = globulize($name);
	self.and: sub ($item, *%) { $item.basename ~~ $matcher };
}

method ext(Mu $ext) is constraint(Name) {
	self.and: sub ($item, *%) { $item.extension ~~ $ext };
}

method path(Mu $path) is constraint(Name) {
	my $matcher = globulize($path);
	self.and: sub ($item, *%) { ~$item ~~ $matcher };
}

method relpath(Mu $path ) is constraint(Name) {
	my $matcher = globulize($path);
	self.and: sub ($item, :$base, *%) { $item.relative($base) ~~ $matcher };
}

method io(Mu $path) is constraint(Name) {
	self.and: sub ($item, *%) { $item ~~ $path };
}

method dangling(Bool $value = True) is constraint(Stat) {
	self.and: sub ($item, *%) { ($item.l && !$item.e) == $value };
}

method readable(Bool $value = True) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.r == $value };
}
method writable(Bool $value = True) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.w == $value };
}
method executable(Bool $value = True) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.x == $value };
}
method read-writable(Bool $value = True) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.rw == $value };
}
method read-write-executable(Bool $value = True) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.rwx == $value };
}
method exists(Bool $value = True) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.e == $value };
}
method file(Bool $value = True) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.f == $value };
}
method directory(Bool $value = True) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.d == $value };
}
method symlink(Bool $value = True) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.l == $value }
}
method empty(Bool $value = True) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.z == $value };
}

{
	use nqp;
	method inode(Mu $inode) is constraint(Stat) {
		self.and: sub ($item, *%) { nqp::stat(nqp::unbox_s(~$item), nqp::const::STAT_PLATFORM_INODE) ~~ $inode};
	}
	method device(Mu $device) is constraint(Stat) {
		self.and: sub ($item, *%) { nqp::stat(nqp::unbox_s(~$item), nqp::const::STAT_PLATFORM_DEV) ~~ $device };
	}
	method nlinks(Mu $nlinks) is constraint(Stat) {
		self.and: sub ($item, *%) { nqp::stat(nqp::unbox_s(~$item), nqp::const::STAT_PLATFORM_NLINKS) ~~ $nlinks };
	}
	method uid(Mu $uid) is constraint(Stat) {
		self.and: sub ($item, *%) { nqp::stat(nqp::unbox_s(~$item), nqp::const::STAT_UID) ~~ $uid };
	}
	method gid(Mu $gid) is constraint(Stat) {
		self.and: sub ($item, *%) { nqp::stat(nqp::unbox_s(~$item), nqp::const::STAT_GID) ~~ $gid };
	}
}

method accessed(Mu $accessed) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.accessed ~~ $accessed };
}
method changed(Mu $changed) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.changed ~~ $changed };
}
method modified(Mu $modified) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.modified ~~ $modified };
}

method mode(Mu $mode) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.mode ~~ $mode };
}
method size(Mu $size) is constraint(Stat) {
	self.and: sub ($item, *%) { $item.s ~~ $size };
}

proto method depth($) is constraint(Depth) { * }
multi method depth(Range $depth-range where .is-int) {
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
multi method depth(Int $depth) {
	return self.depth($depth..$depth);
}
multi method depth(Mu $depth-match) {
	self.and: sub ($item, :$depth, *%) {
		return $depth ~~ $depth-match;
	}
}

method skip-dir(Mu $pattern) is constraint(Skip) {
	self.and: sub ($item, *%) {
		if $item.basename ~~ $pattern && $item.d {
			return PruneInclusive;
		}
		return True;
	}
}
method skip-subdir(Mu $pattern) is constraint(Skip) {
	self.and: sub ($item, :$depth, *%) {
		if $depth > 0 && $item.basename ~~ $pattern && $item.d {
			return PruneInclusive;
		}
		return True;
	}
}
method skip-hidden(Bool $hide = True) is constraint(Skip) {
	if $hide {
		self.and: sub ($item, :$depth, *%) {
			if $depth > 0 && $item.basename ~~ rx/ ^ '.' / {
				return PruneInclusive;
			}
			return True;
		}
	}
}
my $vcs-dirs = any(<.git .bzr .hg _darcs CVS RCS .svn>, |($*DISTRO.name eq 'mswin32' ?? '_svn' !! ()));
my $vcs-files = none(rx/ '.#' $ /, rx/ ',v' $ /);
method skip-vcs(Bool $hide = True) is constraint(Skip) {
	self.skip-dir($vcs-dirs).name($vcs-files) if $hide;
}

proto method shebang(Mu $pattern, *%opts) is constraint(Content) { * }
multi method shebang(Mu $pattern, *%opts) {
	self.and: sub ($item, *%) {
		return False unless $item.f;
		return $item.lines(|%opts)[0] ~~ $pattern;
	};
}
multi method shebang(Bool $value = True, *%opts) {
	self.and: sub ($item, *%) {
		return !$value unless $item.f;
		return ?($item.lines(|%opts)[0] ~~ rx/ ^ '#!' /) === $value;
	};
}

method contents(Mu $pattern, *%opts) is constraint(Content) {
	self.and: sub ($item, *%) {
		return False unless $item.f;
		return $item.slurp(|%opts) ~~ $pattern;
	};
}

method lines(Mu $pattern, *%opts) is constraint(Content) {
	self.and: sub ($item, *%) {
		return False unless $item.f;
		for $item.lines(|%opts) -> $line {
			return True if $line ~~ $pattern;
		}
		return False;
	}
}

method no-lines(Mu $pattern, *%opts) is constraint(Content) {
	self.and: sub ($item, *%) {
		return True unless $item.f;
		for $item.lines(|%opts) -> $line {
			return False if $line ~~ $pattern;
		}
		return True;
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
		CATCH { default { return True } }
	}
	!! sub (Bool %seen, IO::Path $item) { return True };

enum Order is export(:DEFAULT :order) < BreadthFirst PreOrder PostOrder >;

my %as{Any:U} = ((Str) => { ~$_ }, (IO::Path) => Block);
multi method in(Path::Finder:D:
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

		without $result {
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

multi method in(Path::Finder:U: |args --> Seq:D){
	return self.new.in(|args);
}

our sub finder(Path::Finder :$base = Path::Finder, *%options --> Path::Finder) is export(:find) {
	class Entry {
		has $.name;
		has $.method handles <precedence>;
		has $.capture;
		method call-with($object) {
			return $object.$!method(|$!capture);
		}
	};
	my Entry @entries;
	for %options.kv -> $name, $value {
		my $method = $base.^lookup($name);
		die "Finder key $name invalid" if not $method.defined or $method !~~ Constraint;
		my $capture = $value ~~ Capture ?? $value !! do given $method.signature.count - 1 {
			when 1 {
				\($value);
			}
			when Inf {
				\(|@($value).map: -> $entry { $entry ~~ Hash|Pair ?? finder(|%($entry)) !! $entry });
			}
		}
		@entries.push: Entry.new(:$name, :$method, :$capture);
	}
	my @keys = @entries.sort(*.precedence);
	return ($base, |@keys).reduce: -> $object, $entry {
		$entry.call-with($object);
	}
}

our sub find(*@dirs, *%options --> Seq:D) is export(:DEFAULT :find) {
	my %in-options = %options<follow-symlinks order sorted loop-safe relative as map>:delete:p;
	return finder(|%options).in(|@dirs, |%in-options);
}

=begin pod

=head1 SYNOPSIS

 use Path::Finder;

 my $finder = Path::Finder; # match anything
 $finder = $rule.file.size(* > 10_000);    # add/chain rules

 # iterator interface
 for $finder.in(@dirs) -> $file {
   ...
 }

 # functional interface
 for find(@dirs, :file, :size(* > 10_000)) -> $file {
   ...
 }

=head1 DESCRIPTION

This module iterates over files and directories to identify ones matching a
user-defined set of rules. The object-oriented API is based heavily on
perl5's C<Path::Iterator::Rule>. A C<Path::Finder> object is a
collection of rules (match criteria) with methods to add additional criteria.
Options that control directory traversal are given as arguments to the method
that generates an iterator. There is also a functional interface that is often
simpler in use, even if it allows for slightly less control.

Here is a summary of features for comparison to other file finding modules:

=item provides many "helper" methods for specifying rules

=item offers (lazy) list interface

=item custom rules implemented with roles

=item breadth-first (default) or pre- or post-order depth-first searching

=item follows symlinks (by default, but can be disabled)

=item directories visited only once (no infinite loop; can be disabled)

=item doesn't chdir during operation

=item provides an API for extensions

=head1 USAGE

Path::Finder objects are immutable. All methods except C<in> return a new object combining the existing rules with the additional rules provided.

=head2 Matching and iteration

=head3 C<in>

 for $finder.in(@dirs, |%options) -> $file {
   ...
 }

Creates a sequence of results. This sequence is "lazy" -- results are not
pre-computed.

It takes as arguments a list of directories to search and named arguments as
control options. If no search directories are provided, the
current directory is used (C<".">). Valid options include:

=item C<order> -- Controls order of results. Valid values are C<BreadthFirst> (breadth-first search), C<PreOrder> (pre-order, depth-first search), C<PostOrder> (post-order, depth-first search). The default is C<BreadthFirst>.

=item C<follow-symlinks> - Follow directory symlinks when true. Default is C<True>.

=item C<report-symlinks> - Includes symlinks in results when true. Default is equal to C<follow-symlinks>.

=item C<loop-safe> - Prevents visiting the same directory more than once when true. Default is C<True>.

=item C<relative> - Return matching items relative to the search directory. Default is C<False>.

=item C<sorted> - Whether entries in a directory are sorted before processing. Default is C<True>.

=item C<as> - The type of values that will be returned. Valid values are C<IO::Path> (the default) and C<Str>.

Filesystem loops might exist from either hard or soft links. The C<loop-safe>
option prevents infinite loops, but adds some overhead by making C<stat> calls.
Because directories are visited only once when C<loop-safe> is true, matches
could come from a symlinked directory before the real directory depending on
the search order.

To get only the real files, turn off C<follow-symlinks>. You can have
symlinks included in results, but not descend into symlink directories if
you turn off C<follow-symlinks>, but turn on C<report-symlinks>.

Turning C<loop-safe> off and leaving C<follow-symlinks> on avoids C<stat> calls
and will be fastest, but with the risk of an infinite loop and repeated files.
The default is slow, but safe.

If the search directories are absolute and the C<relative> option is true,
files returned will be relative to the search directory. Note that if the
search directories are not mutually exclusive (whether containing
subdirectories like C<@*INC> or symbolic links), files found could be returned
relative to different initial search directories based on C<order>,
C<follow-symlinks> or C<loop-safe>.

=head2 Logic operations

C<Path::Finder> provides three logic operations for adding rules to the
object. Rules may be either a subroutine reference with specific semantics
or another C<Path::Finder> object.

=head3 C<and>

 $finder.and($finder2) ;
 $finder.and(-> $item, *%) { $item ~~ :rwx });
 $finder.and(@more-rules);
 
 find(:and(@more-rules));

This creates a new rule combining the curent one and the arguments. E.g.
"old rule AND new1 AND new2 AND ...".

=head3 C<or>

 $finder.or(
   Path::Finder.name("foo*"),
   Path::Finder.name("bar*"),
   -> $item, *% { $item ~~ :rwx },
 );

This creates a new rule combining the curent one and the arguments. E.g.
"old rule OR new1 OR new2 OR ...".

=head3 C<none>

 $finder.none( -> $item, *% { $item ~~ :rwx } );

This creates a new rule combining the current one and one or more alternatives
and adds them as a negative constraint to the current rule. E.g. "old rule AND
NOT ( new1 AND new2 AND ...)". Returns the object to allow method chaining.

=head3 C<not>

 $finder.not();

This creates a new rule negating the whole original rule. Returns the object to
allow method chaining.

=head3 C<skip>

 $finder.skip(
   $finder.new.dir.not-writeable,
   $finder.new.dir.name("foo"),
 );

Takes one or more alternatives and will prune a directory if any of the
criteria match or if any of the rules already indicate the directory should be
pruned. Pruning means the directory will not be returned by the iterator and
will not be searched.

For files, it is equivalent to C<< $finder.none(@rules) >>. Returns
the object to allow method chaining.

This method should be called as early as possible in the rule chain.
See C<skip-dir> below for further explanation and an example.

=head1 RULE METHODS

Rule methods are helpers that add constraints. Internally, they generate a
closure to accomplish the desired logic and add it to the rule object with the
C<and> method. Rule methods return the object to allow for method chaining.

Generally speaking there are two kinds of rule methods: the ones that take a
value to smartmatch some property against (e.g. C<name>), and ones that take
a boolean (defaulting to C<True>) to check a boolean value against (e.g.
C<readable>).

=head2 File name rules

=head3 C<name>

 $finder.name("foo.txt");
 find(:name<foo.txt>);

The C<name> method takes a pattern and creates a rule that is true
if it matches the B<basename> of the file or directory path.
Patterns may be anything that can smartmatch a string. If it's a string
it will be interpreted as a L<glob|IO::Glob> pattern.

=head3 C<path>

 $finder.path( "foo/*.txt" );
 find(:path<foo/*.txt>);

The C<path> method takes a pattern and creates a rule that is true
if it matches the path of the file or directory.
Patterns may be anything that can smartmatch a string. If it's a string
it will be interpreted as a L<glob|IO::Glob> pattern.

=head3 C<relpath>

$finder.relpath( "foo/bar.txt" );
find(:relpath<foo/bar.txt>);

$finder.relpath( any(rx/foo/, "bar.*"));
find(:relpath(any(rx/foo/, "bar.*"))

The C<relpath> method takes a pattern and creates a rule that is true
if it matches the path of the file or directory relative to its basedir.
Patterns may be anything that can smartmatch a string. If it's a string
it will be interpreted as a L<glob|IO::Glob> pattern.

=head3 C<io>

 $finder.path(:f|:d);
 find(:path(:f|:d);

The C<io> method takes a pattern and creates a rule that is true
if it matches the C<IO> of the file or directory. This is mainly
useful for combining filetype tests.

=head3 C<ext>

The C<name> method takes a pattern and creates a rule that is true
if it matches the extension of path. Patterns may be anything that can
smartmatch a string.

=head3 C<skip-dir>

 $finder.skip-dir( $pattern );

The C<skip-dir> method skips directories that match a pattern. Directories
that match will not be returned from the iterator and will be excluded from
further search. B<This includes the starting directories.>  If that isn't
what you want, see C<skip-subdir> instead.

B<Note:> this rule should be specified early so that it has a chance to
operate before a logical shortcut. E.g.

 $finder.skip-dir(".git").file; # OK
 $finder.file.skip-dir(".git"); # Won't work

In the latter case, when a ".git" directory is seen, the C<file> rule
shortcuts the rule before the C<skip-dir> rule has a chance to act.

=head3 C<skip-subdir>

 $finder.skip-subdir( @patterns );

This works just like C<skip-dir>, except that the starting directories
(depth 0) are not skipped and may be returned from the iterator
unless excluded by other rules.

=head2 File test rules

Most of the C<:X> style filetest are available as boolean rules:

=item readable
=item writable
=item executable
=item file
=item directory
=item symlink
=item exists
=item empty

For example:

 $finder.file.empty;

Two composites are also available:

=item read-writable
=item read-write-executable

The timestamps methods take a single argument in a form that
can smartmatch against an C<Instant>.

=item accessed
=item modified
=item changed

For example:

 # hour old
 $finder.modified(* < now - 60 * 60);

It also supports the following integer based matching rules:

=item size
=item mode
=item device
=item inode
=item nlinks
=item uid
=item gid

For example:

 $finder.size(* > 10240)

=head3 C<dangling>

 $finder.dangling;

The C<dangling> rule method matches dangling symlinks.

=head2 Depth rules

 $finder.depth(3..5);

The C<depth> rule method take a single range argument and limits
the paths returned to a minimum or maximum depth (respectively) from the
starting search directory, or an integer representing a specific depth. A depth
of 0 means the starting directory itself.  A depth of 1 means its children.
(This is similar to the Unix C<find> utility.)

=head2 Version control file rules

 # Skip all known VCS files
 $finder.skip-vcs;

Skips files and/or prunes directories related to a version control system.
Just like C<skip-dir>, these rules should be specified early to get the
correct behavior.

=head2 File content rules

=head3 C<contents>

 $finder.contents(rx/BEGIN .* END/);

The C<contents> rule takes a list of regular expressions and returns
files that match one of the expressions.

The expressions are applied to the file's contents as a single string. For
large files, this is likely to take significant time and memory.

Files are assumed to be encoded in UTF-8, but alternative encodings can
be passed as a named argument:

$finder.contents(rx/BEGIN .* END/xs, :enc<latin1>);

=head3 C<lines>

 $finder.lines(rx:i/^new/);

The C<line> rule takes a list of regular expressions and returns
files with at least one line that matches one of the expressions.

Files are assumed to be encoded in UTF-8, but alternative Perl IO layers can
be passed like in C<contents>

=head3 C<no-lines>

 $finder.no-lines(rx:i/^new/);

The C<line> rule takes a list of regular expressions and returns
files with no lines that matches one of the expressions.

Files are assumed to be encoded in UTF-8, but alternative Perl IO layers can
be passed like in C<contents>

=head3 C<shebang>

 $finder.shebang(rx/#!.*\bperl\b/);

The C<shebang> rule takes a value and checks it against the first line of a
file. The default checks for C<rx/^#!/>.

=head2 Other rules

=head1 EXTENDING

=head2 Custom rule subroutines

Rules are implemented as (usually anonymous) subroutine callbacks that return
a value indicating whether or not the rule matches. These callbacks are called
with three arguments. The only positional argument is a path.

 $finder.and( sub ($item, *%args) { $item ~~ :r & :w & :x } );

The named arguments contain more information for such a check
For example, the C<depth> key is used to support minimum and maximum
depth checks.

The custom rule subroutine must return one of four values:

=over 4

=item *

C<True> -- indicates the constraint is satisfied

=item *

C<False> -- indicates the constraint is not satisfied

=item *

C<PruneExclusive> -- indicate the constraint is satisfied, and prune if it's a directory

=item *

C<PruneInclusive> -- indicate the constraint is not satisfied, and prune if it's a directory

=back

Here is an example. This is equivalent to the "depth" rule method with
a depth of C<0..3>:

 $finder.and(
   sub ($path, :$depth, *%) {
     return $depth < 3 ?? True !! PruneExclusive;
   }
 );

Files and directories and directories up to depth 3 will be returned and
directories will be searched. Files of depth 3 will be returned. Directories
of depth 3 will be returned, but their contents will not be added to the
search.

Once a directory is flagged to be pruned, it will be pruned regardless of
subsequent rules.

 $finder.depth(0..3).name(rx/foo/);

This will return files or directories with "foo" in the name, but all
directories at depth 3 will be pruned, regardless of whether they match the
name rule.

Generally, if you want to do directory pruning, you are encouraged to use the
C<skip> method instead of writing your own logic using C<PruneExclusive> and
C<PruneInclusive>.

=head1 PERFORMANCE

By default, C<Path::Finder> iterator options are "slow but safe". They
ensure uniqueness, return files in sorted order, and throw nice error messages
if something goes wrong.

If you want speed over safety, set these options:

 :!loop-safe, :!sorted, :order(PreOrder)

Depending on the file structure being searched, C<< :order(PreOrder) >> may or
may not be a good choice. If you have lots of nested directories and all the
files at the bottom, a depth first search might do less work or use less
memory, particularly if the search will be halted early (e.g. finding the first
N matches.)

Rules will shortcut on failure, so be sure to put rules likely to fail
early in a rule chain.

Consider:

 $f1 = Path::Finder.new.name(rx/foo/).file;
 $f2 = Path::Finder.new.file.name(rx/foo/);

If there are lots of files, but only a few containing "foo", then
C<$f1> above will be faster.

Rules are implemented as code references, so long chains have
some overhead. Consider testing with a custom coderef that
combines several tests into one.

Consider:

 $f3 = Path::Finder.new.read-write-executable;
 $f4 = Path::Finder.new.readable.writeable.executable;

Rule C<$f3> above will be much faster, not only because it stacks
the file tests, but because it requires to only check a single rule.

=end pod
