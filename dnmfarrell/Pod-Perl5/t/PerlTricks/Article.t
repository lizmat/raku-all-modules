use Test;
use lib 'lib';
use Pod::Perl5::PerlTricks::Grammar;

plan 3;

ok my $match
  = Pod::Perl5::PerlTricks::Grammar.parsefile('test-corpus/PerlTricks/SampleArticle.pod'),
  'parse sample article';

ok my $include = $match<pod-section>[0]<command-block>[4]<file>.made, 'Extract the =include pod';
is $include<pod-section>[0]<command-block>[0]<singleline_text>, 'brian d foy', 'author-name matches expected';
