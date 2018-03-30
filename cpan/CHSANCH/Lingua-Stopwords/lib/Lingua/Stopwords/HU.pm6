use v6.c;
unit module Lingua::Stopwords::HU;

sub get-list ( Str $list = 'snowball' --> SetHash ) is export {
    
    my SetHash $stop-words .= new;
    
    given $list {
        when 'all' {
            $stop-words = < a abban ahhoz ahogy ahol aki akik akkor alatt amely amelyek amelyekben amelyeket amelyet amelynek ami amikor amit amolyan amíg 
                            annak arra arról az azok azon azonban azt aztán azután azzal azért be belül benne bár cikk cikkek cikkeket csak de e ebben eddig 
                            egy egyes egyetlen egyik egyre egyéb egész ehhez ekkor el ellen elsõ elég elõ elõször elõtt emilyen ennek erre ez ezek ezen ezt 
                            ezzel ezért fel felé hanem hiszen hogy hogyan hát ide igen ill ill. illetve ilyen ilyenkor ismét ison itt jobban jó jól kell 
                            kellett keressünk keresztül ki kívül között közül le legalább legyen lehet lehetett lenne lenni lesz lett maga magát majd meg 
                            mellett mely melyek mert mi mikor milyen minden mindenki mindent mindig mint mintha mit mivel miért most már más másik még míg 
                            nagy nagyobb nagyon ne nekem neki nem nincs néha néhány nélkül oda olyan ott pedig persze rá s saját sem semmi sok sokat sokkal 
                            szemben szerint szinte számára szét talán te tehát teljes ti tovább továbbá több ugyanis utolsó után utána vagy vagyis vagyok 
                            valaki valami valamint való van vannak vele vissza viszont volna volt voltak voltam voltunk által általában át én éppen és így õ 
                            õk õket ön össze úgy új újabb újra >.SetHash;
        }
        when 'ranks-nl' {
            $stop-words = <  a az egy be ki le fel meg el át rá ide oda szét össze vissza de hát és vagy hogy van lesz volt csak nem igen mint én te õ mi ti õk 
                            ön >.SetHash;
        }
        when 'snowball' {
            $stop-words = <  a ahogy ahol aki akik akkor alatt által általában amely amelyek amelyekben amelyeket amelyet amelynek ami amit amolyan amíg amikor 
                            át abban ahhoz annak arra arról az azok azon azt azzal azért aztán azután azonban bár be belül benne cikk cikkek cikkeket csak de 
                            e eddig egész egy egyes egyetlen egyéb egyik egyre ekkor el elég ellen elõ elõször elõtt elsõ én éppen ebben ehhez emilyen ennek 
                            erre ez ezt ezek ezen ezzel ezért és fel felé hanem hiszen hogy hogyan igen így illetve ill. ill ilyen ilyenkor ison ismét itt jó 
                            jól jobban kell kellett keresztül keressünk ki kívül között közül legalább lehet lehetett legyen lenne lenni lesz lett maga magát 
                            majd már más másik meg még mellett mert mely melyek mi mit míg miért milyen mikor minden mindent mindenki mindig mint mintha 
                            mivel most nagy nagyobb nagyon ne néha nekem neki nem néhány nélkül nincs olyan ott össze õ õk õket pedig persze rá s saját sem 
                            semmi sok sokat sokkal számára szemben szerint szinte talán tehát teljes tovább továbbá több úgy ugyanis új újabb újra után utána 
                            utolsó vagy vagyis valaki valami valamint való vagyok van vannak volt voltam voltak voltunk vissza vele viszont volna >.SetHash;
        }
        default {
            fail "Invalid type of list: $list.";
        }
    }

    return $stop-words;
}