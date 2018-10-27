use v6;

unit module Test::NoTabs;

use Test;
use File::Find;

my sub _all-perl-files(@dirs) {
    my $all-files = _all-files(@dirs);
    grep { _is-perl-module($_) || _is-perl-script($_) }, $all-files;
}

my sub _all-files(@base-dirs = [$*CWD]) {
    my $found;
    for @base-dirs -> $dir {
        $found.append(find(dir => $dir, name => /.p[l||m]6?$/));
    }
    $found.flat;
}

sub notabs-ok($file, $test-text?) is export {
    subtest {
        my $text = "No tabs in $file" if !$test-text.defined;
        my $fp = _module-to-path($file);
        my Int $count = 0;
        for $fp.IO.lines -> $line {
            ++$count;
            next if ($line ~~ /^\s*'#'/);
            next if ($line ~~ /^\s* '=' (head[1234]|over|item|begin|for|encoding)/);
            next if ($line ~~ /^\s* '=' (cut|back|end)/ );
            if ( $line ~~ /\t/ ) {
                ok 0, $text ~ " on line $count";
                return 0;
            }
        }
        if ($!) { diag("Could not open $file; $!"); return; };
    }, "No tabs in file $file";
}

sub all-perl-files-ok($input) is export {
    my @files = _all-perl-files($input);
    for @files.sort -> $f {
        notabs-ok($f, "No tabs in '$f'")
    }
}

my sub _is-perl-module($file) {
    $file ~~ /:i\.pm6?/;# || $file ~~ /::/; # NYI
}

my sub _is-perl-script($file) {
    return 1 if $file ~~ /:i\.pl?6?$/;
    return 1 if $file ~~ /\.t$/;
    0;
}

my sub _module-to-path($file) {
    # :: not yet implemented
    # return $file unless ($file ~~ /':' ':'/);
    # my $parts = split /::/, $file;
    # my $module;
    # my $path = IO::Spec::Unix.catfile(@parts);
    # if ($path ~ '.pm6').IO.e {
    #     $module = $path ~ '.pm6';
    # } else {
    #     $module = $path ~ '.pm';
    # }
    # for $*REPO.repo-chain -> $repo {
    #     my $candidate = catfile(~$repo, $module);
    #     next unless ($candidate.IO.e && $candidate.IO.f);
    #     return $candidate;
    # }
    # NYI block
    $file;
}
