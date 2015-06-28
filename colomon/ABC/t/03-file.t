use v6;
use Test;
use ABC::Grammar;

{
    my $match = ABC::Grammar.parse(slurp("samples.abc"), :rule<tune_file>);
    ok $match, 'samples.abc is a valid tune file';
    is @( $match<tune> ).elems, 3, "Three tunes were found";

    my @titles = @( $match<tune> ).flatmap({ @( .<header><header_field> ).grep({ .<header_field_name> eq "T" })[0] }).flatmap({ .<header_field_data> });
    
    is +@titles, 3, "Three titles were found";
    is @titles[0], "Cuckold Come Out o' the Amrey", "First is Cuckold";
    is @titles[1], "Elsie Marley", "Second is Elsie Marley";
    is @titles[2], "Peacock Followed the Hen. JWDM.07", "Third is Peacock";
}

done;
