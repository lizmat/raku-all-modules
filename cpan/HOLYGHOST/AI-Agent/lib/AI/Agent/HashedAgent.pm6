use v6.c;

use AI::Agent::Actor;
use AI::Agent::Agent;

class AI::Agent::HashedAgent is AI::Agent::Agent
{
	has %.dependencies;
	has $!done;

	method BUILD() {
		self.add-dependency(&self.ask);
		self.add-dependency(&self.agent);
	}

	method add-dependency($dependency) {
    		%.dependencies{$dependency.name => $dependency};
	}

	method ask(%args) {
		return qq:to/RET/:
    You can ask me the following:
			agent, dispatch args = \{ "agent", Agent instance \}
RET

	}

	# agent dispatched, overload for other agent parsing
	method dispatch_agent($agent) {
		return &$agent.dispatch;
	}

	# Look if an agent is dispatched, note the "agent" key for agents
	method agent(%args) {
		%args{"agent"}.dispatch_agent(self);
	}

	### main call to the actor-agent

	method dispatch($message, %optargs) {
    		unless $!done {
        		self.dispatch($message, %optargs) for %!dependencies;
        		$!done = True;
    		}
	}

}
