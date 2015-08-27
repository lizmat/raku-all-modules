use Test;
use lib 'lib';
use Pod::Perl5::PerlTricks::Grammar;
use Pod::Perl5::PerlTricks::ToHTML;

plan 2;

ok my $actions = Pod::Perl5::PerlTricks::ToHTML.new;

ok my $match
  = Pod::Perl5::PerlTricks::Grammar.parsefile('test-corpus/PerlTricks/SampleArticle.pod', :$actions),
  'parse sample article with ToHTML action class';

