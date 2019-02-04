use v6;
use Test;

use lib 't/lib';
use PFTest;

use Path::Finder;

#--------------------------------------------------------------------------#

{
    my $td = make_tree(
       <
          atroot.txt
          empty/
          data/file1.txt
          more/file2.txt
    >);

    my $rule = Path::Finder.new.file;

    my @files = $rule.in($td, :as(Str));

    is( +@files, 3, "All files" ) or diag @files.perl;

    $rule  = Path::Finder.new.directory;
    @files = $rule.in($td, :as(Str));

    is( +@files, 4, "All files and dirs" );

	chdir $td;

    @files = $rule.in(:as(Str));
    is( +@files, 4, "All files and dirs w/ cwd" );

    $rule = $rule.skip-dir('data');
    @files = $rule.in($td, :as(Str));
    is( +@files, 3, "All w/ prune dir" ) or diag @files.perl;

    $rule  = Path::Finder.skip-dir(/./).file;
    @files = $rule.in($td, :as(Str));
    is( +@files, 0, "All w/ prune top directory" ) or diag @files.perl;

    $rule  = Path::Finder.skip-subdir(/./).file;
    @files = $rule.in($td, :as(Str));
    is( +@files, 1, "All w/ prune subdirs" ) or diag @files.perl;
}

done-testing;

# This file is derived from Path-Iterator-Rule, Copyright (c) 2013 by David Golden.
