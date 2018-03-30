use v6.c;
unit module Lingua::Stopwords::CA;

sub get-list ( Str $list = 'ranks-nl' --> SetHash ) is export {
    
    my SetHash $stop-words .= new;

    given $list {
        when 'ranks-nl' {
            $stop-words = < a abans algun alguna algunes alguns altre amb ambdós anar ans aquell aquelles aquells aquí 
                            bastant bé cada com consegueixo conseguim conseguir consigueix consigueixen consigueixes dalt 
                            de des dins el elles ells els en ens entre era erem eren eres es estan estat estava estem esteu 
                            estic està ets fa faig fan fas fem fer feu fi haver i inclòs jo la les llarg llavors mentre 
                            meu mode molt molts nosaltres o on per perquè però podem poden poder podeu potser primer puc 
                            quan quant que qui sabem saben saber sabeu sap saps sense ser seu seus si soc solament sols 
                            som sota també te tene tenim tenir teniu teu tinc tot un una unes uns va vaig van vosaltres 
                            és éssent últim ús >.SetHash;
        }

        default {
            fail "Invalid type of list: $list.";
        }

    }

    return $stop-words;
}