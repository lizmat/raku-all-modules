use v6;
use Test;
use lib <lib>;

plan 30;

use-ok 'Prompt::Gruff', 'Can use Prompt::Gruff';
use Prompt::Gruff;

ok my $gruff = Prompt::Gruff.new, 'Prompt::Gruff instantiate';
can-ok $gruff, 'required';
can-ok $gruff, 'multi-line';
can-ok $gruff, 'verify';
can-ok $gruff, 'default';
can-ok $gruff, 'regex';
can-ok $gruff, 'yn';
can-ok $gruff, 'no-escape';
can-ok $gruff, 'prompt-for';

ok my $gr = Prompt::Gruff.new(:testing, :_test-input(['Gorgonzola'])), 'testing and test-input instantiation';
ok my $r = $gr.prompt-for('Name a cheese: '), 'prompt call';
is $r, 'Gorgonzola', 'Basic cheese';
ok ('Name a cheese: ' eq any $gr._test-output), 'prompted with string';

ok $gr = Prompt::Gruff.new(:testing, :_test-input(['Gorgonzola', 'Havarti'])), 'testing and test-input instantiation';
ok $r = $gr.prompt-for('Name a cheese: ', :regex('^H.*')), 'prompt call';
is $r, 'Havarti', 'Regex';
ok ('Input does not match valid pattern' eq any $gr._test-output), 'Regex verify failed';

ok $gr = Prompt::Gruff.new(:testing, :_test-input(['Gorgonzola', 'Havarti', 'Havarti'])), 'testing and test-input instantiation';
ok $r = $gr.prompt-for('Name a cheese: ', :regex('^H.*'), :verify(2)), 'prompt call with verify';
is $r, 'Havarti', 'Regex with verify';
ok ('Input does not match valid pattern' eq any $gr._test-output), 'Regex verify failed';
ok ('(verify) Name a cheese: ' eq any $gr._test-output), 'Verify prompt portion';

ok $gr = Prompt::Gruff.new(:testing, :_test-input(['n'])), 'testing and test-input instantiation';
nok $r = $gr.prompt-for('Do you like me?', :yn), 'yes and no sadness';
ok $gr = Prompt::Gruff.new(:testing, :_test-input(['Y'])), 'testing and test-input instantiation';
ok $r = $gr.prompt-for('Do you like me?', :yn), 'yes and no happiness';

ok $gr = Prompt::Gruff.new(:testing, :_test-input([''])), 'testing and test-input instantiation';
ok $r = $gr.prompt-for('Where are the dingbats?', :default('UFO')), 'trying default';
is $r, 'UFO', 'UFO default';

