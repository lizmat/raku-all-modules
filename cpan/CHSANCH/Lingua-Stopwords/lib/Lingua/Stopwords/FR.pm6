use v6.c;
unit module Lingua::Stopwords::FR;

sub get-list ( Str $list = 'snowball' --> SetHash ) is export {
    
    my SetHash $stop-words .= new;

    given $list {
        when 'all' {
            $stop-words = < ai aie aient aies ait alors as au aucuns aura aurai auraient aurais aurait auras aurez auriez aurions aurons auront aussi autre 
                            aux avaient avais avait avant avec avez aviez avions avoir avons ayant ayez ayons bon c car ce ceci cela celà ces cet cette ceux 
                            chaque ci comme comment d dans de dedans dehors depuis des devrait doit donc dos du début elle elles en encore es essai est et eu 
                            eue eues eurent eus eusse eussent eusses eussiez eussions eut eux eûmes eût eûtes fait faites fois font furent fus fusse fussent 
                            fusses fussiez fussions fut fûmes fût fûtes hors ici il ils j je juste l la le les leur leurs lui là m ma maintenant mais me mes 
                            mine moi moins mon mot même n ne ni nommés nos notre nous on ont ou où par parce pas peu peut plupart pour pourquoi qu quand que 
                            quel quelle quelles quels qui s sa sans se sera serai seraient serais serait seras serez seriez serions serons seront ses 
                            seulement si sien soi soient sois soit sommes son sont sous soyez soyons suis sujet sur t ta tandis te tellement tels tes toi ton 
                            tous tout trop très tu un une voient vont vos votre vous vu y à ça étaient étais était étant état étiez étions été étée étées étés 
                            êtes être  >.SetHash;
        }
        when 'ranks-nl' {
            $stop-words = < alors au aucuns aussi autre avant avec avoir bon car ce cela ces ceux chaque ci comme comment dans dedans dehors depuis des 
                            devrait doit donc dos du début elle elles en encore essai est et eu fait faites fois font hors ici il ils je juste la le les leur 
                            là ma maintenant mais mes mine moins mon mot même ni nommés notre nous ou où par parce pas peu peut plupart pour pourquoi quand 
                            que quel quelle quelles quels qui sa sans ses seulement si sien son sont sous soyez sujet sur ta tandis tellement tels tes ton 
                            tous tout trop très tu voient vont votre vous vu ça étaient état étions été être >.SetHash;
        }
        when 'snowball' {
            $stop-words = < ai aie aient aies ait as au aura aurai auraient aurais aurait auras aurez auriez aurions aurons auront aux avaient avais avait 
                            avec avez aviez avions avons ayant ayez ayons c ce ceci cela celà ces cet cette d dans de des du elle en es est et eu eue eues 
                            eurent eus eusse eussent eusses eussiez eussions eut eux eûmes eût eûtes furent fus fusse fussent fusses fussiez fussions fut 
                            fûmes fût fûtes ici il ils j je l la le les leur leurs lui m ma mais me mes moi mon même n ne nos notre nous on ont ou par pas 
                            pour qu que quel quelle quelles quels qui s sa sans se sera serai seraient serais serait seras serez seriez serions serons seront 
                            ses soi soient sois soit sommes son sont soyez soyons suis sur t ta te tes toi ton tu un une vos votre vous y à étaient étais 
                            était étant étiez étions été étée étées étés êtes >.SetHash;
        }
        default {
            fail "Invalid type of list: $list.";
        }
    }

    return $stop-words;
}