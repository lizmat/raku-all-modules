use v6.c;
unit module Lingua::Stopwords::IT;

sub get-list ( Str $list = 'snowball' --> SetHash ) is export {
    
    my SetHash $stop-words .= new;

    given $list {
        when 'all' {
            $stop-words = < a abbia abbiamo abbiano abbiate ad adesso agl agli ai al all alla alle allo allora altre altri altro 
                            anche ancora avemmo avendo avere avesse avessero avessi avessimo aveste avesti avete aveva avevamo 
                            avevano avevate avevi avevo avrai avranno avrebbe avrebbero avrei avremmo avremo avreste avresti 
                            avrete avrà avrò avuta avute avuti avuto ben buono c che chi ci cinque coi col come comprare con 
                            consecutivi consecutivo contro cosa cui da dagl dagli dai dal dall dalla dalle dallo degl degli dei 
                            del dell della delle dello dentro deve devo di doppio dov dove due e ebbe ebbero ebbi ecco ed era 
                            erano eravamo eravate eri ero essendo faccia facciamo facciano facciate faccio facemmo facendo 
                            facesse facessero facessi facessimo faceste facesti faceva facevamo facevano facevate facevi facevo 
                            fai fanno farai faranno fare farebbe farebbero farei faremmo faremo fareste faresti farete farà farò 
                            fece fecero feci fine fino fosse fossero fossi fossimo foste fosti fra fu fui fummo furono gente giu 
                            gli ha hai hanno ho i il in indietro invece io l la lavoro le lei li lo loro lui lungo ma me meglio 
                            mi mia mie miei mio molta molti molto ne negl negli nei nel nell nella nelle nello no noi nome non 
                            nostra nostre nostri nostro nove nuovi nuovo o oltre ora otto peggio per perché pero persone piu più 
                            poco primo promesso qua quale quanta quante quanti quanto quarto quasi quattro quella quelle quelli 
                            quello questa queste questi questo qui quindi quinto rispetto sara sarai saranno sarebbe sarebbero 
                            sarei saremmo saremo sareste saresti sarete sarà sarò se secondo sei sembra sembrava senza sette si 
                            sia siamo siano siate siete solo sono sopra soprattutto sotto sta stai stando stanno starai staranno 
                            starebbe starebbero starei staremmo staremo stareste staresti starete starà starò stati stato stava 
                            stavamo stavano stavate stavi stavo stemmo stesse stessero stessi stessimo stesso steste stesti 
                            stette stettero stetti stia stiamo stiano stiate sto su sua subito sue sugl sugli sui sul sull sulla 
                            sulle sullo suo suoi tanto te tempo terzo ti tra tre triplo tu tua tue tuo tuoi tutti tutto ultimo 
                            un una uno va vai vi voi volte vostra vostre vostri vostro è >.SetHash;
        }
        when 'ranks-nl' {
            $stop-words = < a adesso ai al alla allo allora altre altri altro anche ancora avere aveva avevano ben buono che chi 
                            cinque comprare con consecutivi consecutivo cosa cui da del della dello dentro deve devo di doppio 
                            due e ecco fare fine fino fra gente giu ha hai hanno ho il indietro invece io la lavoro le lei lo 
                            loro lui lungo ma me meglio molta molti molto nei nella no noi nome nostro nove nuovi nuovo o oltre 
                            ora otto peggio pero persone piu poco primo promesso qua quarto quasi quattro quello questo qui 
                            quindi quinto rispetto sara secondo sei sembra sembrava senza sette sia siamo siete solo sono sopra 
                            soprattutto sotto stati stato stesso su subito sul sulla tanto te tempo terzo tra tre triplo ultimo 
                            un una uno va vai voi volte vostro >.SetHash;
        }
        when 'snowball' {
            $stop-words = < ad al allo ai agli all agl alla alle con col coi da dal dallo dai dagli dall dagl dalla dalle di del 
                            dello dei degli dell degl della delle in nel nello nei negli nell negl nella nelle su sul sullo sui 
                            sugli sull sugl sulla sulle per tra contro io tu lui lei noi voi loro mio mia miei mie tuo tua tuoi 
                            tue suo sua suoi sue nostro nostra nostri nostre vostro vostra vostri vostre mi ti ci vi lo la li le 
                            gli ne il un uno una ma ed se perché anche come dov dove che chi cui non più quale quanto quanti 
                            quanta quante quello quelli quella quelle questo questi questa queste si tutto tutti a c e i l o ho 
                            hai ha abbiamo avete hanno abbia abbiate abbiano avrò avrai avrà avremo avrete avranno avrei avresti 
                            avrebbe avremmo avreste avrebbero avevo avevi aveva avevamo avevate avevano ebbi avesti ebbe avemmo 
                            aveste ebbero avessi avesse avessimo avessero avendo avuto avuta avuti avute sono sei è siamo siete 
                            sia siate siano sarò sarai sarà saremo sarete saranno sarei saresti sarebbe saremmo sareste 
                            sarebbero ero eri era eravamo eravate erano fui fosti fu fummo foste furono fossi fosse fossimo 
                            fossero essendo faccio fai facciamo fanno faccia facciate facciano farò farai farà faremo farete 
                            faranno farei faresti farebbe faremmo fareste farebbero facevo facevi faceva facevamo facevate 
                            facevano feci facesti fece facemmo faceste fecero facessi facesse facessimo facessero facendo sto 
                            stai sta stiamo stanno stia stiate stiano starò starai starà staremo starete staranno starei 
                            staresti starebbe staremmo stareste starebbero stavo stavi stava stavamo stavate stavano stetti 
                            stesti stette stemmo steste stettero stessi stesse stessimo stessero stando >.SetHash;
        }
        default {
            fail "Invalid type of list: $list.";
        }
    }

    return $stop-words;
}