use v6;

=begin pod

=head1 Model

Model contains choosen attributes inisde classes and and low level methods to contact game servers like get mentioned attributes or do something. No decisions or logic should be found here.

=head1 Logic

L<doc:LacunaCookbuk::Logic::Ambassador>

P<doc:LacunaCookbuk::Logic::Ambassador>

L<doc:LacunaCookbuk::Logic::BodyBuilder>

P<doc:LacunaCookbuk::Logic::BodyBuilder>

L<doc:LacunaCookbuk::Logic::Chairman>

P<doc:LacunaCookbuk::Logic::Chairman>

L<doc:LacunaCookbuk::Logic::Chairman>

P<doc:LacunaCookbuk::Logic::Commander>

L<doc:LacunaCookbuk::Logic::IntelCritic>

P<doc:LacunaCookbuk::Logic::IntelCritic>

L<doc:LacunaCookbuk::Logic::OreCritic>

P<doc:LacunaCookbuk::Logic::OreCritic>

L<doc:LacunaCookbuk::Logic::PlanMaker>

P<doc:LacunaCookbuk::Logic::PlanMaker>

L<doc:LacunaCookbuk::Logic::Secretary>

P<doc:LacunaCookbuk::Logic::Secretary>

L<doc:LacunaCookbuk::Logic::ShipCritic>

P<doc:LacunaCookbuk::Logic::ShipCritic>

L<doc:LacunaCookbuk::Logic::Transporter>

P<doc:LacunaCookbuk::Logic::Transporter>
	
=end pod

use LacunaCookbuk::Logic::Chairman;
use LacunaCookbuk::Logic::ShipCritic;
use LacunaCookbuk::Logic::OreCritic;
use LacunaCookbuk::Logic::IntelCritic;
use LacunaCookbuk::Logic::PlanMaker;
use LacunaCookbuk::Logic::Transporter;
use LacunaCookbuk::Logic::Ambassador;
use LacunaCookbuk::Logic::Commander;
use LacunaCookbuk::Logic::Secretary;

use LacunaCookbuk::Model::Empire;



#| LacunaCookbuk main client
unit class LacunaCookbuk::Client;

#| Login
sub create_session is export {
    Empire.start_rpc_keeper;    
    Empire.create_session;     
}

#| Logout
sub close_session is export {
    Empire.close_session;
}

#| Will show summary for docks and scuttle ships that have efficency lower 45% if ship is docked
method ships {    
   LacunaCookbuk::Logic::ShipCritic.elaborate_ships;
}

#| Will show all ores on planet stub 
method ore {    
   LacunaCookbuk::Logic::OreCritic.elaborate_ore;
}

#| Will vote YES to ALL propostions. Be careful if you care about politics
method votes {
   LacunaCookbuk::Logic::Ambassador.vote_all(True);
}

#| Inbox cleaning: Parliament that is voted by alliance anyway
#|                 Wasting resources is to common to allow everyone
method cleanbox {
   LacunaCookbuk::Logic::Secretary.clean(["Parliament"]);
   LacunaCookbuk::Logic::Secretary.clean_wastin_res;
}


#| Create Halls of Vrbansk and transport all glyphs and plans to home planet
method ordinary {
    say "Creating all possible halls";
   LacunaCookbuk::Logic::PlanMaker.make_possible_halls;
    
    say "Transporting all glyphs to home planet if possible";
   LacunaCookbuk::Logic::Transporter.transport_all_cargo;
}

#| Will upgrade buildings in order passed to L<doc:LacunaCookbuk::Logic::Chairman>
#| chairman will work only on existing buildings but this may change in future
method chairman {
    #| FIXME isolate and fill bug report
    unless %*ENV<MVM_SPESH_DISABLE> {
        warn "SPESH not disabled. If running on MOARVM expect throwing exceptions without real cause. Set env variable
              MVM_SPESH_DISABLE=1 to make this message dissapear\n";
    }
    my LacunaCookbuk::Logic::Chairman::BuildGoal $saw .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::saw, level=>12);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $wastet .=  new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::wastedigester, level=>15);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $space .=  new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::spaceport, level=>10, priority => True);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $arch .=  new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::archaeology, level=>30);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $sec .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::security, level => 30); 


    my LacunaCookbuk::Logic::Chairman::BuildGoal $politic .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::politicstraining,level => 15);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $mayhem .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::mayhemtraining, level => 15);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $intel .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::inteltraining, level => 15);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $espionage .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::espionage, level => 15);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $intelli .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::intelligence, level =>15);

    my LacunaCookbuk::Logic::Chairman::BuildGoal $happy .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::entertainment, level => 30);

    my LacunaCookbuk::Logic::Chairman::BuildGoal $mercenaries .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::mercenariesguild, level => 30);

    my LacunaCookbuk::Logic::Chairman::BuildGoal @goals = (
	$space, $arch, $sec,
	$politic, $mayhem, $intel, $espionage, $intelli,
	$happy, $saw, $wastet

	);

    my $c =LacunaCookbuk::Logic::Chairman.new(build_goals=>(@goals));
    $c.build_all;
}

#| Use power of chairman to upgrade home planet
method upgrade_home {
    my LacunaCookbuk::Logic::Chairman::BuildGoal $saw .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::saw, level=> 12);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $wastet .=  new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::wastedigester, level=>15);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $space .=  new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::spaceport, level=>10);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $arch .=  new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::archaeology, level=>30);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $sec .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::security, level => 30); 

    my LacunaCookbuk::Logic::Chairman::BuildGoal $politic .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::politicstraining,level => 15);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $mayhem .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::mayhemtraining, level => 15);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $intel .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::inteltraining, level => 15);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $espionage .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::espionage, level => 15);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $intelli .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::intelligence, level =>15);

    my LacunaCookbuk::Logic::Chairman::BuildGoal $happy .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::entertainment, level => 30);

    my LacunaCookbuk::Logic::Chairman::BuildGoal $mercenaries .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::mercenariesguild, level => 30);

    my LacunaCookbuk::Logic::Chairman::BuildGoal $saw2 .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::saw, level=> 30);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $trade .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::trade, level=> 30);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $university .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::university, level=> 30);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $capitol .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::capitol, level=> 30);
    my LacunaCookbuk::Logic::Chairman::BuildGoal $stockpile .= new(building => LacunaCookbuk::Logic::Chairman::BuildingEnum::stockpile, level=> 30);
    my LacunaCookbuk::Logic::Chairman::BuildGoal @goals = (
	$saw,
	$wastet,$space, $arch, $sec,
	$politic, $mayhem, $intel, $espionage, $intelli,
	$happy,
	$saw2, $trade, $university,
	$capitol, $stockpile
	);

	my $c = LacunaCookbuk::Logic::Chairman.new(build_goals=>(@goals));
	$c.build;
}

#| Print list of incoming ships
method defend {
   LacunaCookbuk::Logic::Commander.find_incoming;
}

#| Print summary of spies
method spies {
   LacunaCookbuk::Logic::IntelCritic.elaborate_spies;
}

#| Print all plans can be made of glyphs in stock
method plans {
   LacunaCookbuk::Logic::PlanMaker.show_possible_plans;
}


#| Where are my planets? It is not best implementation
#| but at least grep capable
method zones {
    LacunaCookbuk::Logic::BodyBuilder.report_zones;
}

#| Repair broken planets
method repair {
    LacunaCookbuk::Logic::Chairman.repair_all;
}

#| Refill Space Station Module plan 
method make_space {
  LacunaCookbuk::Logic::PlanMaker.space_plans;
}

#| Where are my planets? It is not best implementation
#| but at least grep capable
method waste {
    LacunaCookbuk::Logic::BodyBuilder.report_waste;
}


