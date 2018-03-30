use v6.c;
unit module Lingua::Stopwords::PT;

sub get-list ( Str $list = 'snowball' --> SetHash ) is export {
    
    my SetHash $stop-words .= new;

    given $list {
        when 'all' {
            $stop-words = < a acerca agora algmas alguns ali ambos antes ao aos apontar aquela aquelas aquele aqueles aqui 
                            aquilo as atrás até bem bom cada caminho cima com como comprido conhecido corrente da das de debaixo 
                            dela delas dele deles dentro depois desde desligado deve devem deverá direita diz dizer do dois dos 
                            e ela elas ele eles em enquanto entre então era eram essa essas esse esses esta estado estamos estar 
                            estará estas estava estavam este esteja estejam estejamos estes esteve estive estivemos estiver 
                            estivera estiveram estiverem estivermos estivesse estivessem estivéramos estivéssemos estou está 
                            estávamos estão eu fará faz fazer fazia fez fim foi fomos for fora foram forem formos fosse fossem 
                            fui fôramos fôssemos haja hajam hajamos havemos havia hei horas houve houvemos houver houvera 
                            houveram houverei houverem houveremos houveria houveriam houvermos houverá houverão houveríamos 
                            houvesse houvessem houvéramos houvéssemos há hão iniciar inicio ir irá isso ista iste isto já lhe 
                            lhes ligado maioria maiorias mais mas me mesmo meu meus minha minhas muito muitos na nas nem no nome 
                            nos nossa nossas nosso nossos novo num numa não nós o onde os ou outro para parte pegar pela pelas 
                            pelo pelos pessoas pode poderá podia por porque povo promeiro qual qualquer quando que quem quieto 
                            quê saber se seja sejam sejamos sem ser serei seremos seria seriam será serão seríamos seu seus 
                            somente somos sou sua suas são só tal também te tem temos tempo tenha tenham tenhamos tenho tentar 
                            tentaram tente tentei ter terei teremos teria teriam terá terão teríamos teu teus teve tinha tinham 
                            tipo tive tivemos tiver tivera tiveram tiverem tivermos tivesse tivessem tivéramos tivéssemos todos 
                            trabalhar trabalho tu tua tuas tém têm tínhamos um uma umas uns usa usar valor veja ver verdade 
                            verdadeiro você vocês vos à às é éramos último >.SetHash;
        }
        when 'ranks-nl' {
            $stop-words = < acerca agora algmas alguns ali ambos antes apontar aquela aquelas aquele aqueles aqui atrás bem bom 
                            cada caminho cima com como comprido conhecido corrente das debaixo dentro desde desligado deve devem 
                            deverá direita diz dizer dois dos e ela ele eles em enquanto então estado estar estará este estes 
                            esteve estive estivemos estiveram está estão eu fará faz fazer fazia fez fim foi fora horas iniciar 
                            inicio ir irá ista iste isto ligado maioria maiorias mais mas mesmo meu muito muitos nome nosso novo 
                            não nós o onde os ou outro para parte pegar pelo pessoas pode poderá podia por porque povo promeiro 
                            qual qualquer quando quem quieto quê saber sem ser seu somente são tal também tem tempo tenho tentar 
                            tentaram tente tentei teu teve tipo tive todos trabalhar trabalho tu têm um uma umas uns usa usar 
                            valor veja ver verdade verdadeiro você é último >.SetHash;
        }
        when 'snowball' {
            $stop-words = < a ao aos aquela aquelas aquele aqueles aquilo as até com como da das de dela delas dele deles depois 
                            do dos e ela elas ele eles em entre era eram essa essas esse esses esta estamos estas estava estavam 
                            este esteja estejam estejamos estes esteve estive estivemos estiver estivera estiveram estiverem 
                            estivermos estivesse estivessem estivéramos estivéssemos estou está estávamos estão eu foi fomos for 
                            fora foram forem formos fosse fossem fui fôramos fôssemos haja hajam hajamos havemos havia hei houve 
                            houvemos houver houvera houveram houverei houverem houveremos houveria houveriam houvermos houverá 
                            houverão houveríamos houvesse houvessem houvéramos houvéssemos há hão isso isto já lhe lhes mais mas 
                            me mesmo meu meus minha minhas muito na nas nem no nos nossa nossas nosso nossos num numa não nós o 
                            os ou para pela pelas pelo pelos por qual quando que quem se seja sejam sejamos sem ser serei 
                            seremos seria seriam será serão seríamos seu seus somos sou sua suas são só também te tem temos 
                            tenha tenham tenhamos tenho ter terei teremos teria teriam terá terão teríamos teu teus teve tinha 
                            tinham tive tivemos tiver tivera tiveram tiverem tivermos tivesse tivessem tivéramos tivéssemos tu 
                            tua tuas tém têm tínhamos um uma você vocês vos à às é éramos >.SetHash;
        }
        default {
            fail "Invalid type of list: $list.";
        }
    }

    return $stop-words;
}