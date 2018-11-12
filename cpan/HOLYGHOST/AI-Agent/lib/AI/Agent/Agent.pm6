use v6.c;

use AI::Agent::Actor;

class AI::Agent::Agent is AI::Agent::Actor
{
	has $.status;

	method BUILD($stat) {
		$!status = $stat;
	}

	method ask(%args) {
		return Str.new("You can ask me the following : agent, dispatch args=agent, agent instance");

	}

	### agent dispatched, overload for other agent parsing
	method dispatch_agent($agent) {
		return &$agent.dispatch;
	}



	### Look if an agent is dispatched, note the "agent" key for agents
	method agent(%args) {
		%args{"agent"}.dispatch_agent(self);
	}

	### main call to the actor-agent

	method dispatch($msg, %optargs = Nil) {
		given $msg {
		when "ask about" { self.ask(%optargs); }
		when "agent" { self.agent(%optargs); } ### dispatch an agent, see self.agent
		default { .status = 0; return; }
		.status = 1;
		}
	}
}
