use v6;

use LacunaCookbuk::Model::Body::Planet;
use LacunaCookbuk::Logic::BodyBuilder;

unit class LacunaCookbuk::Logic::PlanMaker;

constant $ANTHRACITE = "anthracite";
constant $BAUXITE = "bauxite";
constant $BERYL = "beryl";
constant $CHALCOPYRITE = "chalcopyrite";
constant $CHROMITE = "chromite";
constant $FLUORITE = "fluorite";
constant $GALENA = "galena";
constant $GOETHITE = "goethite";
constant $GOLD = "gold";
constant $GYPSUM = "gypsum";
constant $HALITE = "halite";
constant $KEROGEN = "kerogen";
constant $MAGNETITE = "magnetite";
constant $METHANE = "methane";
constant $MONAZITE = "monazite";
constant $RUTILE = "rutile";
constant $SULFUR ="sulfur";
constant $TRONA = "trona";
constant $URANINITE = "uraninite";
constant $ZIRCON = "zircon";

constant %recipes =
{
 "Algae Pond" => @($METHANE,$URANINITE),
 "Amalgus Meadow" => @($BERYL, $TRONA),
 "Beeldeban Nest" => @($ANTHRACITE, $KEROGEN,$TRONA),
 "Black Hole Generator"=> @($ANTHRACITE, $BERYL, $KEROGEN, $MONAZITE),
 "Citadel of Knope" => @($BERYL, $GALENA, $MONAZITE, $SULFUR),
 "Crashed Ship Site" =>@($BAUXITE, $GOLD, $MONAZITE, $TRONA),
 "Denton Brambles" =>@($GOETHITE, $RUTILE),
 "Gas Giant Settlement Platform" => @($ANTHRACITE, $GALENA, $METHANE, $SULFUR),
 "Geo Thermal Vent" => @($CHALCOPYRITE, $SULFUR),
 "Gratch's Gauntlet" => @($BAUXITE,$FLUORITE,$GOLD, $KEROGEN),
 "Halls of Vrbansk#1" => @($GOETHITE,$HALITE, $GYPSUM, $TRONA),
 "Halls of Vrbansk#2" => @($GOLD, $ANTHRACITE, $URANINITE, $BAUXITE),
 "Halls of Vrbansk#3" => @($KEROGEN, $METHANE, $SULFUR, $ZIRCON),
 "Halls of Vrbansk#4" => @($MONAZITE, $FLUORITE, $BERYL, $MAGNETITE),
 "Halls of Vrbansk#5" => @($RUTILE, $CHROMITE, $CHALCOPYRITE, $GALENA),
 "Interdimensional Rift" => @($GALENA, $METHANE, $ZIRCON),
 "Kalavian Ruins" => @($GALENA, $GOLD),
 "Lapis Forest" => @($HALITE, $ANTHRACITE),
 "Library of Jith" => @($ANTHRACITE, $BAUXITE, $BERYL, $CHALCOPYRITE),
 "Malcud Field" => @($FLUORITE, $KEROGEN),
 "Natural Spring" => @($MAGNETITE, $HALITE),
 "Oracle of Anid" => @($GOLD, $URANINITE, $BAUXITE, $GOETHITE),
 "Pantheon of Hagness" => @($GYPSUM, $TRONA, $BERYL, $ANTHRACITE),
 "Ravine" => @($ZIRCON, $METHANE, $GALENA, $FLUORITE),
 "Temple of the Drajilites" => @($KEROGEN, $RUTILE, $CHROMITE, $CHALCOPYRITE),
 "Terraforming Platform" => @($METHANE, $ZIRCON, $MAGNETITE, $BERYL),
 "Volcano" => @($MAGNETITE, $URANINITE)
};


#TODO use achaeology instead of trade
method show_possible_plans {
  my $hp = home_planet;
  my Trade $t = $hp.find_trade_ministry;
  my %glyphs = $t.get_glyphs_hash();

  for @(keys %recipes) -> $recipename {
    say $recipename;
    print "\t";
    my $count = self!count_plans(%recipes{$recipename}, %glyphs);
    say $count if $count;    
  }
} 


#TODO use achaeology instead of trade
method make_possible_halls {
  my $hp = home_planet;
  my $t = $hp.find_trade_ministry;
  my %glyphs = $t.get_glyphs_hash();

  for @(keys %recipes).grep(/Halls/) -> $recipename {
    say $recipename;
    my $count = self!count_plans(%recipes{$recipename}, %glyphs);
    say $count;
    self.create_recipe(%recipes{$recipename}, $count) if $count > 0 ;
  }
} 


method !count_plans(@planRecipe, %glyphs) {
  my Int $num = 0;

    for @planRecipe -> $glp {

	if !%glyphs{$glp} {
	    say "Missing: " ~ $glp;
	    return 0;
	}
	elsif $num == 0 
	{
	    $num = %glyphs{$glp};
	}
	else
	{
	    $num = min($num, %glyphs{$glp});
	}
    }
    return $num;
}

method create_recipe(@recipe, Int $quantity) {
    return if $quantity == 0;
    home_planet.find_archaeology_ministry().assemble_glyphs(@recipe, $quantity)
}


method space_plans {

  my Trade $t = home_planet.find_trade_ministry;
  my $pns = $t.get_plans_hash();
  dd $pns;
  say "!!!!!";


}

=begin pod

=head2 Space port plans

=item Find current plans

=item find lowest quantity plan

=item make it

=item repeat until get bored

=end pod
