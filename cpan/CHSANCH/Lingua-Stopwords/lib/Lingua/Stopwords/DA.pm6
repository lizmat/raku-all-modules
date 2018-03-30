use v6.c;
unit module Lingua::Stopwords::DA;

sub get-list ( Str $list = 'snowball' --> SetHash ) is export {
    
    my SetHash $stop-words .= new;

    given $list {
        when 'all' {
            $stop-words = <  ad af alle alt anden andet andre at begge blev blive bliver da de dem den denne der deres det dette dig din disse dog du efter ej 
                            eller en end ene eneste enhver er et fem fire flere fleste for fordi forrige fra få før god ham han hans har havde have hende 
                            hendes her hos hun hvad hvem hver hvilken hvis hvor hvordan hvorfor hvornår i ikke ind ingen intet jeg jer jeres jo kan kom kommer 
                            kunne lav lidt lille man mand mange med meget men mens mere mig min mine mit mod ned ni nogen noget nogle nu ny nyt når nær næste 
                            næsten og også om op os otte over på se seks selv ses sig sin sine sit skal skulle som stor store syv sådan thi ti til to tre ud 
                            under var vi vil ville vor være været >.SetHash;
        }
        when 'ranks-nl' {
            $stop-words = <  af alle andet andre at begge da de den denne der deres det dette dig din dog du ej eller en end ene eneste enhver et fem fire 
                            flere fleste for fordi forrige fra få før god han hans har hendes her hun hvad hvem hver hvilken hvis hvor hvordan hvorfor hvornår 
                            i ikke ind ingen intet jeg jeres kan kom kommer lav lidt lille man mand mange med meget men mens mere mig ned ni nogen noget ny 
                            nyt nær næste næsten og op otte over på se seks ses som stor store syv ti til to tre ud var >.SetHash;
        }
        when 'snowball' {
            $stop-words = <  ad af alle alt anden at blev blive bliver da de dem den denne der deres det dette dig din disse dog du efter eller en end er et 
                            for fra ham han hans har havde have hende hendes her hos hun hvad hvis hvor i ikke ind jeg jer jo kunne man mange med meget men 
                            mig min mine mit mod ned noget nogle nu når og også om op os over på selv sig sin sine sit skal skulle som sådan thi til ud under 
                            var vi vil ville vor være været >.SetHash;
        }
        default {
            fail "Invalid type of list: $list.";
        }
    }

    return $stop-words;
}