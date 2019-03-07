use v6.c;
unit class App::Prove6:ver<0.0.10>:auth<cpan:LEONT>;

use TAP;

my multi listall(IO::Path $path where .d, @exts) {
	for $path.dir(:test(!*.starts-with('.'))).self -> $entry {
		listall($entry, @exts);
	}
}
my multi listall(IO::Path $path where .f, @exts) {
	take ~$path if $path.extension eq any(@exts);
}
my multi listall(IO::Path $path, @) {
	die "Invalid input '$path'";
}

my sub load(Str $classname) {
	my $loaded = try ::($classname);
	return $loaded if $loaded !eqv Any;
	require ::($classname);
	return ::($classname);
}

use Getopt::Long;

proto sub MAIN(|) is export(:MAIN) { * }

multi sub MAIN(
	Bool :l(:$lib), Bool :$timer is getopt<!>, Int :j(:$jobs),
	Bool :$ignore-exit is getopt<!>, Bool :$trap,
	Bool :v(:$verbose) is getopt<!>, Bool :q(:$quiet), Bool :Q(:$QUIET),
	Bool :$shuffle, Str :$err, Bool :$reverse,
	Str :e(:$exec), Str :$harness, Str :$reporter, :I(:incdir(@incdirs)),
	Bool :$loose, Bool :$color is getopt<!>, :@ext = <t t6>, *@files) {
	@files = 't' if not @files;
	die "Invalid value '$err' for --err\n" if defined $err && $err eq none('stderr','merge','ignore');

	@incdirs.push($*CWD.add('lib')) if $lib;
	my %more;
	with $exec {
		%more<handlers> = ( TAP::Harness::SourceHandler::Exec.new($exec.words) );
	}
	elsif @incdirs {
		%more<handlers> = ( TAP::Harness::SourceHandler::Perl6.new(:@incdirs) );
	}

	my $harness-class = $harness ?? load($harness) !! TAP::Harness;
	%more<reporter-class> = load($reporter) with $reporter;

	with $verbose {
		%more<volume> = $verbose ?? TAP::Verbose !! TAP::Normal;
	}
	elsif $QUIET {
		%more<volume> = TAP::Silent;
	}
	elsif $quiet {
		%more<volume> = TAP::Quiet;
	}

	my @sources = gather { listall($_.IO, @ext) for @files }
	@sources = $shuffle ?? @sources.pick(*) !! @sources.sort;
	@sources = @sources.reverse if $reverse;
	my %args = grep *.value.defined, (:$jobs, :$timer, :$trap, :$ignore-exit, :$err, :$loose, :$color);
	my $run = $harness-class.new(|%args, |%more).run(@sources);
	exit min($run.result.has-errors, 254);
}

multi sub MAIN(Bool :$help!) {
	require Pod::To::Text;
	my @contents = $=pod[0].contents.grep: { $_ ~~ Pod::Heading && .contents[0].contents eq 'USAGE' ^fff^ $_ ~~ Pod::Heading };
	my $usage-pod = Pod::Block::Named.new(:name<prove6>, :@contents);
	my $text = ::('Pod::To::Text').render($usage-pod);
	say $text;
}
multi sub MAIN(Bool :$version!) {
	say "prove6 {App::Prove6.^ver} with TAP::Harness {TAP.^ver} on {$*PERL.compiler.gist}";
}

=begin pod

=head1 NAME

prove6 - Run tests through a TAP harness.

=head1 USAGE

 prove6 [options] [files or directories]

Boolean options:

 -v,  --verbose         Print all test lines.
 -l,  --lib             Add 'lib' to the path for your tests (-Ilib).
      --shuffle         Run the tests in random order.
      --ignore-exit     Ignore exit status from test scripts.
      --reverse         Run the tests in reverse order.
 -q,  --quiet           Suppress some test output while running tests.
 -Q,  --QUIET           Only print summary results.
      --timer           Print elapsed time after each test.
      --trap            Trap Ctrl-C and print summary on interrupt.
      --help            Display this help
      --version         Display the version

Options that take arguments:

 -I,  --incdir          Library paths to include.
 -e,  --exec            Interpreter to run the tests ('' for compiled
                        tests.)
      --ext             Set the extensions for tests (default <t t6>)
      --harness         Define test harness to use.  See TAP::Harness.
      --reporter        Result reporter to use. See REPORTERS.
 -j,  --jobs            Run N test jobs in parallel (try 9.)
      --err=stderr      Direct the test's $*ERR to the harness' $*ERR.
      --err=merge       Merge test scripts' $*ERR with their $*OUT.
      --err=ignore      Ignore test script' $*ERR.

=head1 NOTES

=head2 Default Test Directory

If no files or directories are supplied, C<prove6> looks for all files
matching the pattern C<t/*.t>.

=head2 Colored Test Output

Colored test output is the default, but if output is not to a terminal, color
is disabled.

Color support requires C<Terminal::ANSIColor> on Unix-like platforms. If the
necessary module is not installed colored output will not be available.

=head2 Exit Code

If the tests fail C<prove6> will exit with non-zero status.

=head2 C<-e>

Normally you can just pass a list of Perl 6 tests and the harness will know how
to execute them.  However, if your tests are not written in Perl 6 or if you
want all tests invoked exactly the same way, use the C<-e> switch:

 prove6 -e='/usr/bin/ruby -w' t/
 prove6 -e='/usr/bin/perl -Tw -mstrict -Ilib' t/
 prove6 -e='/path/to/my/customer/exec'

=head2 C<--err>

=begin item
C<--err=stderr>

Direct the test's $*ERR to the harness' $*ERR.

This is the default behavior.
=end item

=begin item
C<--err=merge>

If you need to make sure your diagnostics are displayed in the correct
order relative to test results you can use the C<--err=merge> option to
merge the test scripts' $*ERR into their $*OUT.

This guarantees that $*OUT (where the test results appear) and $*ERR
(where the diagnostics appear) will stay in sync. The harness will
display any diagnostics your tests emit on $*ERR.

Caveat: this is a bit of a kludge. In particular note that if anything
that appears on $*ERR looks like a test result the test harness will
get confused. Use this option only if you understand the consequences
and can live with the risk.

PS: Currently not supported.
=end item

=begin item
C<--err=ignore>

Ignore the test script' $*ERR
=end item

=head2 C<--trap>

The C<--trap> option will attempt to trap SIGINT (Ctrl-C) during a test
run and display the test summary even if the run is interrupted

=head2 $*REPO

C<prove6> introduces a separation between "options passed to the perl which
runs prove" and "options passed to the perl which runs tests"; this
distinction is by design. Thus the perl which is running a test starts
with the default C<$*REPO>. Additional library directories can be added
via the C<PERL6LIB> environment variable, via -Ifoo in C<PERL6OPT> or
via the C<-Ilib> option to C<prove6>.

=end pod

# vim:ts=4:sw=4:noet:sta
