use v6.c;
use Test;      # a Standard module included with Rakudo 
use lib 'lib';

use AI::Agent::Agent;
use AI::Agent::HashedAgent;

my $num-tests = 2;

plan $num-tests;
 
# .... tests 
#  

my $msg = "ask about";
my %optargs;
my $ag = AI::Agent::Agent.new( x => 0 );
ok $ag.dispatch($msg, %optargs),
"You can ask me the following :
RET
agent, dispatch args=agent, agent instance
RET
";

my $hag = AI::Agent::HashedAgent.new( x => 0 );
ok $hag.dispatch($msg, %optargs),
		"You can ask me the following:
RET
			agent, dispatch args = \{ agent, agent instance \}
RET
";

done-testing;  # optional with 'plan' 

