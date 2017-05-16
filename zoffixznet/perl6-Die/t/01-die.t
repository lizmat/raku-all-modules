use lib <lib>;
use Test;
use Die;

plan 4;

subtest 'old die still works as-is' => {
    plan 4;
    throws-like { die       }, X::AdHoc, message => /Died/,
        'without args';
    throws-like { die "foo" }, X::AdHoc, message => /foo/,
        'Str without new line';
    throws-like { die X::Str::Numeric }, X::AdHoc, message => /'Str::Numeric'/,
        'Exception:U';
    throws-like { die X::IO::Unknown.new: :trying<foo> }, X::IO::Unknown,
        trying => 'foo', 'Exception:D';
}

with run :out, :err, $*EXECUTABLE, '-Ilib', '-MDie',
  '-e', 'say "hi"; die "foo\n"'
{
    is-deeply .out.slurp-rest(:close), "hi\n", 'STDOUT';
    is-deeply .err.slurp-rest(:close), "foo\n", 'STDERR';
    # is-deeply .exitcode, 1, 'exit code';
}

# https://rt.perl.org/Ticket/Display.html?id=130781#ticket-history
with run :err, $*EXECUTABLE, '-Ilib', '-MDie', '-e', 'die "foo\n"'
{
    $ = .err.close;
    is-deeply .exitcode, 1, 'exit code';
}
