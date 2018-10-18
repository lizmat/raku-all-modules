#! /usr/bin/env false

use v6.c;

unit module Git::Log;

=begin pod

=NAME    Git::Log
=AUTHOR  Samantha McVey (samcv) <samantham@posteo.net>

=head1 SYNOPSIS

Gets the git log as a Perl 6 object
=head1 DESCRIPTION
=para
The first argument is the command line args wanted to be passed into C<git log>.
Optionally you can also get the files changes as well as the number of lines
added or deleted.
=para
Returns an array of hashes in the following format:
C<<ID => "df0c229ad6ba293c67724379bcd3d55af6ea47a0",
AuthorName => "Author's Name", AuthorEmail => "sample.email@not-a.url" ...>>
If the option :get-changes is used (off by default) it will also add a 'changes' key in the
following format: C<<changes => { $[ { filename => 'myfile.txt', added => 10, deleted => 5 }, ... ] }>>

=para
If there is a field that you need that is not offered, then you can supply an
array, :@fields. Format is an array of pairs: C<<ID => '%H', AuthorName => '%an' ...>>
you can look for more L<here|https://git-scm.com/docs/pretty-formats>.

=para
These are the default fields:
=begin code :lang<perl6>
my @fields-default =
    'ID'           => '%H',
    'AuthorName'   => '%an',
    'AuthorEmail'  => '%ae',
    'AuthorDate'   => '%aI',
    'Subject'      => '%s',
    'Body'         => '%b'
;
=end code
=head1 EXAMPLES
=begin code :lang<perl6>
# Gets the git log for the specified repository, from versions 2018.06 to master
git-log(:path($path.IO), '2018.06..master')
# Gets the git log for the current directory, and does I<not> get the files
# changed in that commit
git-log(:!get-changes)
=end code

=LICENSE
This is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

my @fields-default =
    'ID'           => '%H',
    'AuthorName'   => '%an',
    'AuthorEmail'  => '%ae',
    'AuthorDate'   => '%aI',
    'Subject'      => '%s',
    'Body'         => '%b'
;
# Private use characters which let us separate fields.
my $column-sep = 0x102B7C.chr;
my $commit-sep = 0x102B7D.chr;
#| git-log's first argument is an array that is passed to C<git log> and
#| optionally you can provide a path so a directory other than the current
#| are used.
sub git-log (*@args, :@fields = @fields-default, IO::Path :$path,
             Bool:D :$get-changes = False, Bool:D :$date-time = False) is export {
    my @log-arg = 'log';
    @log-arg.prepend('--git-dir', $path.child(".git").absolute) if $path;
    my $format = '--pretty=format:' ~ @fields».value.join($column-sep) ~ $commit-sep;
    my $cmd = run 'git', @log-arg, @args, $format, :out, :err;
    if $cmd.exitcode != 0 {
        die "git log returned code $cmd.exitcode(). Message: $cmd.err.slurp()";
    }
    my $text = $cmd.out.slurp;
    # Remove extra from end: we only want the separator
    # to be *between* entries, not at the end of each one.
    $text ~~ s/$commit-sep$//;
    # Remove the trailing newlines git adds
    $text ~~ s:g/$commit-sep\n/$commit-sep/;
    my @commits;
    for $text.split($commit-sep) -> $entry {
        my %thing = %( @fields».key Z=> $entry.split($column-sep) );
        if $date-time {
            for %thing.keys.grep(*.ends-with("Date")) -> $key {
                %thing{$key} = DateTime.new(%thing{$key});
            }
        }
        @commits.push: %thing;
    }
    if $get-changes {
        my $stat-proc = run 'git', @log-arg, '--numstat', "--format=$commit-sep%H", @args, :out;
        my $stat-text = $stat-proc.out.slurp;
        if $stat-proc.exitcode != 0 {
            die "git log returned code $stat-proc.exitcode(). Message: $stat-proc.err.slurp()";
        }
        # Remove leading separator
        $stat-text ~~ s/^$commit-sep//;
        my %commit-data;
        $stat-text.split($commit-sep).map({ get-data($_, %commit-data) });
        for @commits -> $commit {
            $commit<changes> = %commit-data{$commit<ID>};
        }
    }
    @commits;
}

sub get-data (Str:D $str, %commit-data) {
    my @lines = $str.lines.grep({ $_ ne ""});
    my $commit = @lines.shift;
    for @lines -> $line {
        # Make sure it's only three fields, in case there are tabs in the filename
        my ($added, $removed, $filename) = $line.split("\t", 3);
        $added = $added.Int unless $added eq '-';
        $removed = $removed.Int unless $removed eq '-';
        push %commit-data{$commit}, %(added => $added, removed => $removed, filename => $filename);
    }
}

# vim: ft=perl6 noet
