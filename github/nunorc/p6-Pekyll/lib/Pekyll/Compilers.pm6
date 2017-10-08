
unit module Pekyll::Compilers;

sub plain_copy($src, $dst) is export {
  my $io = IO::Path.new($src);
  $io.copy($dst);
}

