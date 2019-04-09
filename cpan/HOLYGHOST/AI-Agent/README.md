This software is an AI agent which you can ask multiple things depending on
the agent type e.g. there is a MusicAgent class which let's you fill it with
music links, send it somewhere then ask (the system should eventually be 
networked.)

"ask about" is the main syntax for getting information out of your agents.
It is used in the dispatch routines which is included with every agent.

Of course you can make your own agents with the Agent class prototype.
There is a default of accepting other agents (which parse others), the 
call is dispatch("agent", {"agent" => Agent instance}).

