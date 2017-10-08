use v6;

unit module FakeCommand;

my $base-dir = $?FILE.IO.dirname.IO.parent.resolve;

my class CommandResult {
    has $.out;
    has $.err;
    has $.exit-code;

    method success-p() { $.exit-code == 0 }
}

sub miroku(*@args) is export {
    my $proc = Proc::Async.new( $*EXECUTABLE, "-I$base-dir/lib", "$base-dir/bin/miroku", |@args );

    my ($output, $errput);
    $proc.stdout.tap: -> $value { $output ~= $value };
    $proc.stderr.tap: -> $value { $errput ~= $value };

    my $promise = $proc.start;

    try sink await $promise;

    CommandResult.new( :out($output), :err($errput), :exit-code($promise.result.exitcode) )
}
