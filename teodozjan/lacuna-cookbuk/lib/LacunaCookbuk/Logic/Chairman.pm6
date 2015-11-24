use v6;

use LacunaCookbuk::Model::Body;
use LacunaCookbuk::Model::Structure::Development;

use LacunaCookbuk::Logic::BodyBuilder;


use Terminal::ANSIColor;

#| Chairman is the class that does all the magic.
unit class LacunaCookbuk::Logic::Chairman;

#| Basic resources that regulate any planet int the empire
enum LacunaCookbuk::Logic::Chairman::Resource <food ore water energy waste happiness>;

#|all buildings ever
enum LacunaCookbuk::Logic::Chairman::BuildingEnum <algae algaepond amalgusmeadow apple archaeology atmosphericevaporator beach bean beeldeban beeldebannest blackholegenerator bread burger capitol cheese chip cider citadelofknope cloakinglab corn cornmeal crashedshipsite crater dairy denton dentonbrambles deployedbleeder development distributioncenter embassy energyreserve entertainment espionage essentiavein fission fissure foodreserve fusion gasgiantlab gasgiantplatform geneticslab geo geothermalvent gratchsgauntlet greatballofjunk grove hallsofvrbansk hydrocarbon intelligence inteltraining interdimensionalrift junkhengesculpture kalavianruins kasternskeep lake lagoon lapis lapisforest libraryofjith lostcityoftyleon luxuryhousing malcud malcudfield massadshenge mayhemtraining mercenariesguild metaljunkarches mine miningministry missioncommand munitionslab naturalspring network19 observatory oracleofanid orerefinery orestorage oversight pancake pantheonofhagness park pie pilottraining planetarycommand politicstraining potato propulsion pyramidjunksculpture ravine rockyoutcrop sand saw security shake shipyard singularity soup spacejunkpark spaceport spacestationlab stockpile subspacesupplydepot supplypod syrup templeofthedrajilites terraforminglab terraformingplatform thedillonforge thefttraining themepark trade transporter university volcano wastedigester wasteenergy wasteexchanger wasterecycling wastesequestration wastetreatment waterproduction waterpurification waterreclamation waterstorage wheat>; 



class BuildGoal {
    has LacunaCookbuk::Logic::Chairman::BuildingEnum $.building;
    has Int $.level;
    has Bool $.priority=False;

    multi method gist returns Str {
        "{$!building.key} {$!level} {$!priority}"
    }
}

has LacunaCookbuk::Logic::Chairman::BuildGoal @.build_goals;

#| this is not true! whe need to check right buildings by level of capitol
has $!max_resource_building_level = 15; #=  capital ? 15 : stockpile.level

constant $UNSUSTAINABLE = 1012;
constant $NO_ROOM_IN_QUEUE = 1009;
constant $INCOMPLETE_PENDING_BUILD = 1010;
constant $NOT_ENOUGH_STORAGE = 1011;
constant $ACCEPTABLE_RECURSION = 5;
sub print_queue_summary(LacunaCookbuk::Model::Body $body = home_planet) {
    my LacunaCookbuk::Model::Structure::Development $dev = $body.find_development_ministry;
    for $dev.build_queue -> %item {
	say colored(%item<name> ~ " ⌛" ~ DateTime.new(now + %item<seconds_remaining>), 'blue'); 	
    }
}


method build(LacunaCookbuk::Model::Body $body = home_planet) {
    if $body.get_happiness < 0 {
	say colored("Planet is negative happiness. Leaving...", 'red');
	return;
    }
   
    for @!build_goals -> $goal {
        last unless self.upgrade($body, $goal, $ACCEPTABLE_RECURSION);
    } 
	
  
    print_queue_summary($body);
}

method upgrade(LacunaCookbuk::Model::Body $body, $goal, $infinite_recursion_protect is copy --> Bool) {
    unless --$infinite_recursion_protect {
        say colored("Infinite recursion", "red");
        return False;
    }

    my LacunaCookbuk::Model::LacunaBuilding @buildings = $body.find_buildings('/' ~ $goal.building);

    for @buildings -> LacunaCookbuk::Model::LacunaBuilding $building {

	my $view = $building.view;
        unless $goal.level > $view.level {
            say colored($goal.gist, 'green');
            next;
        }
	
	if $view.upgrade<can> {
	    $building.upgrade;
	    say colored("Upgrade started " ~ $goal.building, 'green');
	} else {
	    given $view.upgrade<reason>[0] {
                #= =item When building is UNSUSTAINABLE we surrender if it is specific resorce.
                #= =item In any other situation we try to get resource building.
                #= =item If we cannot upgrade mine because of too low ore production
                #=       we try to do it with another mine (maybe it has lower level)
		when $UNSUSTAINABLE {
		    unless $view.upgrade<reason>[2] {
			say colored(truncate($view.upgrade<reason>[1]), 'yellow');
			next
		    }

		    my $resource = value_of($view.upgrade<reason>[2]);
		    say 'Need to produce more ' ~ $resource  ~ ' for ' ~ $goal.building;
		    my $new_goal =  LacunaCookbuk::Logic::Chairman::BuildGoal.new(
                        building => production($resource), 
                        level => $!max_resource_building_level);

		    if $new_goal.building != $goal.building {
			say "Too low $resource for upgrading {$new_goal.building}";
			self.upgrade($body, $new_goal, $infinite_recursion_protect);
                    } else {
                        say "Cannot upgrade itself";
                        next
		    }
		}
                #= Low storage can have two reasons: too low storage or too small stores
                #= maybe we should improve production but we don't 
		when $NOT_ENOUGH_STORAGE {
		    my $resource = value_of($view.upgrade<reason>[2]);
		    my $quantity = $view.upgrade<cost>{$resource};
		    my $status = $body.get_status<body>;
		    my $capacity = $status{$resource ~ '_capacity'};
#  		    say "Need to have $quantity of $resource for {$goal.building}";
		    
		    if  $quantity > $capacity {
			say "To small stores will try to upgrade";
			my $new_goal = LacunaCookbuk::Logic::Chairman::BuildGoal.new(
                            building=> storage($resource),
                            level => $!max_resource_building_level);

			if $new_goal.building != $goal.building {
                            self.upgrade($body,$new_goal,$infinite_recursion_protect);
                        } else {next}
                    }
#              else {
#                        say "Capacity of $capacity is sufficent, stores will be left as is";
#		    }
		}
                #= Queue full = No options
		when $NO_ROOM_IN_QUEUE {
		    say 'Queue full';
                    return False;
		}
                #= Already upgrading! Almost like success
		when $INCOMPLETE_PENDING_BUILD {
                    next}

                #= Panic!
		default {die $view.upgrade}
	    }		
            return False if $goal.priority;
        }
    }
    #= There is a funny thing about that because we won't stop if prority building is far from
    #= desired level but keeps upgrading. This sacrifices accuracy over speed
    return True;
}

sub storage(LacunaCookbuk::Logic::Chairman::Resource $resource --> LacunaCookbuk::Logic::Chairman::BuildingEnum) {
    
    given $resource {
	when food {return foodreserve}
	when ore {return orestorage}
	when water {return waterstorage}
	when waste {return wastesequestration}
	when energy {return energyreserve}
	default {die $resource}
    }
}

sub production(LacunaCookbuk::Logic::Chairman::Resource $resource --> LacunaCookbuk::Logic::Chairman::BuildingEnum) {
    
    given $resource {
	when food {
	    my @array of LacunaCookbuk::Logic::Chairman::BuildingEnum = (dairy, 
				     lapis,
				     apple,
				     beeldeban,
				     algae,
				     malcud
		);
	    return @array.pick } #FIXME
	when ore {
	    my @array of LacunaCookbuk::Logic::Chairman::BuildingEnum = (mine, orerefinery);
	    return  @array.pick
	}
	when water {return atmosphericevaporator}
#	when waste {return wastesequestration}
	when energy {return singularity}
	default {die $resource}
    }
}


submethod build_all {
    for (planets) -> LacunaCookbuk::Model::Body $planet {
	next if $planet.is_home;
	say BOLD, "Upgrading " ~ $planet.name, RESET;
	self.build($planet);
    }
}

sub value_of(Str $str --> LacunaCookbuk::Logic::Chairman::Resource){
    given $str {
	when 'food' {return food;}
	when 'ore' {return ore;}
	when 'water' {return water;}
	when 'energy' {return energy;}
	when 'waste' {return waste;}
	when 'happiness' {return happiness;}
	default {die $str}
    }
}

submethod repair_all {

    for (planets) -> $planet {
       self.repair_one($planet);       
    }

}

submethod repair_one($planet) {
    my @buildings = $planet.get_buildings;
    say "{$planet.name}:";
    for @buildings -> $b {        
        #TODO check efficency because glyph buildings have repair cost 0
        if $b.view.damaged {
            $b.repair;
        }
    }
    CATCH {
        default {
            warn "Could not handle $planet"
        }
    }

}

sub truncate(Str $s) {
    if $s.chars >127 {
        # this can be done so many ways that it smells like great
        # stackoverflow question
        return $s.chop($s.chars-124) ~ "..."
    } else {
        return $s;
    }

}

submethod view_body($planet){
    my @buildings = $planet.get_buildings;
    dd @buildings;


    for @buildings -> $b {
        dd $b.view;
    }

}
