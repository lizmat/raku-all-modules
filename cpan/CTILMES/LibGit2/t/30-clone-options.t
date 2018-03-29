use Test;
use LibGit2;

plan 4;

ok my $options = Git::Clone::Options.new, 'options';

nok $options.bare, 'not bare';


ok $options = Git::Clone::Options.new(:bare), 'options';

ok $options.bare, 'bare';


