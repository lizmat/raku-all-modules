use v6.d.PREVIEW;
use DRMAA;

DRMAA::Session.init;

#| submitting a shell script
{
    my $*EXECUTABLE = "/bin/sh";
    my @*ARGS = <one two three>;
    my %*ENV = name => 'value';
    my $submission = DRMAA::Job-template.new(:script(q:to/⬅ 完/));
        echo "ciao $1 $2 $3";
        echo $name;
        ⬅ 完

    say 'Shell script submitted with id: ', $submission.job-id;
}

#| submitting a Perl6 script
{
    my @*ARGS = <one two three>;
    my %*ENV = name => 'value';
    my $submission = DRMAA::Job-template.new(:script(q:to/⬅ 完/));
        say "hello", @*ARGS;
      	say %*ENV<$name>;
        ⬅ 完

    say 'Perl 6 script submitted with id: ', $submission.job-id;
}

DRMAA::Session.exit;
