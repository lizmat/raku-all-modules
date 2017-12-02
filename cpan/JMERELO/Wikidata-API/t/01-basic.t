use v6;
use Test;
use lib ('../lib','lib');
use Wikidata::API;

  my $query = q:to/END/;
SELECT ?person ?personLabel WHERE {
  
    ?person wdt:P69 wd:Q1232180 . 
    ?person wdt:P21 wd:Q6581072 . 
  
    SERVICE wikibase:label { 
      bd:serviceParam wikibase:language "en" .
    }
} ORDER BY ?personLabel
END
  
my $UGR-women = query( $query );
is $UGR-women.WHAT, (Hash), "Type OK";
is $UGR-women<head><vars>.WHAT, (Array), "Headers OK";
cmp-ok $UGR-women<results><bindings>.elems, ">", 1, "Results OK";

done-testing;
