use v6.c;
unit module Lingua::Stopwords::NL;

sub get-list ( Str $list = 'snowball' --> SetHash ) is export {
    
    my SetHash $stop-words .= new;

    given $list {
        when 'all' {
            $stop-words = <  aan af al alles als altijd andere ben bij daar dan dat de der deze die dit doch doen door dus een eens en er ge geen geweest haar 
                            had heb hebben heeft hem het hier hij hoe hun iemand iets ik in is ja je kan kon kunnen maar me meer men met mij mijn moet na naar 
                            niet niets nog nu of om omdat onder ons ook op over reeds te tegen toch toen tot u uit uw van veel voor want waren was wat we wel 
                            werd wezen wie wij wil worden wordt zal ze zei zelf zich zij zijn zo zonder zou >.SetHash;
        }
        when 'ranks-nl' {
            $stop-words = <  aan af al als bij dan dat die dit een en er had heb hem het hij hoe hun ik in is je kan me men met mij nog nu of ons ook te tot 
                            uit van was wat we wel wij zal ze zei zij zo zou >.SetHash;
        }
        when 'snowball' {
            $stop-words = <  de en van ik te dat die in een hij het niet zijn is was op aan met als voor had er maar om hem dan zou of wat mijn men dit zo door 
                            over ze zich bij ook tot je mij uit der daar haar naar heb hoe heeft hebben deze u want nog zal me zij nu ge geen omdat iets 
                            worden toch al waren veel meer doen toen moet ben zonder kan hun dus alles onder ja eens hier wie werd altijd doch wordt wezen 
                            kunnen ons zelf tegen na reeds wil kon niets uw iemand geweest andere >.SetHash;
        }
        default {
            fail "Invalid type of list: $list.";
        }
    }

    return $stop-words;
}