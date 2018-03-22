use v6.c;
unit module Test::SourceFiles:ver<0.0.1>;
use Test;


=begin pod

=head1 NAME

Test::SourceFiles - A basic compilation checker

=head1 SYNOPSIS

  use Test;
  use Test::SourceFiles;

  use-libs-ok;

  done-testing

=head1 DESCRIPTION

Test::SourceFiles is a simple way to check the compilation of all files in your projects C<lib/> directory.
I found myself rewriting this a couple of times so time to make a module.

The simple way is to call the C<use-libs-ok> function which calls C<Test::use-ok> on each module name returned from the collecting function, C<collect-sources>.
Alternately you can call C<collect-sources> and do something fancy with it's C<Seq> of C<Pair>'s where the key is a C<::> formatted name and the value is the C<IO::Path> where it was found.
For example:
=begin code
say collect-sources.perl
# prints ("Test::SourceFiles" => IO::Path.new("lib/Test/SourceFiles.pm6", ...),).Seq
=end code


Both functions have the following options and defaults:
=item C<Str :$root-path = 'lib'> - Where to search for source files
=item C<List :$extensions = list 'pm6'> - Which file extensions to include
=item C<Bool :$verbose = False> - Provide more detailed feedback on the search process

=head2 Use Case

I find this module particularly useful when I'm starting a project, a time where I'm creating a lot of files while stubbing functions and roles.
This module weeds out syntax errors from this sketching stage, allowing for a smoother transition into the implementation stage of the development process.
As a module matures and it's test suite fills in this module begins to become less useful and so can likely removed later in a module's life.

=head1 AUTHOR

 Sam Gillespie

=head1 COPYRIGHT AND LICENSE

Copyright 2018

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

#! Calls use-ok $module on all pm6 source files in the libs directory. Returns a count of how many tests where run.
sub use-libs-ok(Str :$root-path = 'lib', List :$extensions = <pm6>.List, Bool :$verbose --> Int) is export {
  my Int $test-count = 0;
  for collect-sources(:$root-path :$extensions :$verbose) {
    $test-count++;
    use-ok .key
  }
  $test-count
}

#! Returns a Seq of Pairs where the key is the module syntax form and the value the files path
sub collect-sources(Str :$root-path = 'lib', List :$extensions = <pm6>.List, Bool :$verbose --> Seq) is export {
  my @path-stack = $root-path, ;
  gather {
    while @path-stack.shift -> $path {
      for $path.IO.dir {
        when .IO.f {
          if $_.extension ~~ $extensions.any {
            my $start = $root-path.chars + 1;
            my $end = .Str.chars - ($start + .extension.chars + 1);
            # Pair up the module name to the path
            take substr($_.Str, $start, $end)
                  .subst(/ ['/' || '\\'] /, '::', :g)
                => $_
          }
          else {
            say "skipped node: '$_' (Extension is not { $extensions.join: "|" })" if $verbose
          }
        }
        when .IO.d {
          @path-stack.push: $_
        }
        default { say "skipped node: '$_' (Not a file or directory)" if $verbose }
      }
    }
  }
}
