use v6.c;

use AI::Agent::Agent;
use AI::Agent::Music::MusicDB;

class AI::Agent::Music::MusicAgent is AI::Agent::Agent
{	
	
	method BUILD($stat) {

		.db = AI::Agent::Music::MusicDB.new;
	}

	### add a key value pair such as "Industrial", "Apoptygma Berserk, ..."
	method add_to_music_db($key, $value) {
		.db.add($key,$value);
	}

	method add_music(%args) {
		for %args.kv -> $key, $value {
			self.add_to_music_db($key, $value);
		}
	}

	method ask(%args) {
		my $string = AI::Agent::Agent.ask(%args) ~ "ask about music" ~ 
						"get music\n" ~
						"add music\n" ~
						"list music\n" ~
						"agent\n";
		
		return $string;
	}

	method ask_music(%args) {
		my $string = "";

		for %args.kv -> $key,$value {
			if (.db.search($key)) {
				$string .= $key;
			}	
		}
		return $string;
	}

	method list_musicdb_keys(%args) {
		return .db.list_keys();	
	}

	method get_music(%args) {
		my @music = "";

		for %args.kv -> $key,$value {
			push(@music, .db.search($key));
		}
		return @music;
	}

	### agent dispatched
	method dispatch_agent($agent) {

		### process music or anything from $agent here

		return &$agent.dispatch;
	} 

	### main call to the actor-agent

	method dispatch($msg, %optargs) {
		given $msg {
		when "ask about" { self.ask(%optargs) } ### give instructions
		when "ask about music" { self.ask_music(%optargs) } 
		when "list music" { self.list_musicdb_keys(%optargs) } 
		when "get music" { self.get_music(%optargs) }
		when "add music" { self.add_music(%optargs) }
		when "agent" { self.agent(%optargs); } ### pass an agent,see Agent
		default { $.status = 0; return; }
		$.status = 1;
		}
	}
}
