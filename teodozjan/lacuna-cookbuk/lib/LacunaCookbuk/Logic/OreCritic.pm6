 use v6;

use LacunaCookbuk::Model::Body::Planet;
use LacunaCookbuk::Logic::BodyBuilder;
use Form;
use Term::ANSIColor;

class LacunaCookbuk::Logic::OreCritic;

constant $ore_format_str = '{<<<<<<<<<<<<<<<<<<<<} ' ~ '{||} ' x 20;


submethod elaborate_ores(Planet $planet, Str @header, @summarize) {
#keys and values in hash 
    my Str @header_copy = @header.clone;
    @header_copy.shift;

    my Str @values = gather for @header_copy -> $head {
	take ~$planet.ore{$head};
    }
    if @summarize {
	@summarize = @summarize >>+<< @values;
	} else {
	@summarize = @values;
    }
    @values.unshift($planet.name);
    print form($ore_format_str, @values);
}

submethod elaborate_ore {
    my @summarize;
    say "Planets -- Potential ores";
    my Str @header = home_planet.ore.keys;
    @header.unshift('Planet name');
    print BOLD, form($ore_format_str, @header), RESET;
    
    for (planets) -> Planet $planet {
	self.elaborate_ores($planet, @header, @summarize);
    }    

    my $max = @summarize.max;
    @summarize .= map:{Int(.Int *100 / $max)};
    @summarize.unshift("Summary");
    
    
    print BOLD, form($ore_format_str, @summarize.map:{.Str ~ '%'}), RESET;
}


