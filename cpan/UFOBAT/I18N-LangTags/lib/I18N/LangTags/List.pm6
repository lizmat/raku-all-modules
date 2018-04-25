use v6.c;

unit module I18N::LangTags::List;
use I18N::LangTags::Grammar;
use I18N::LangTags::Actions;

my $Debug = 0;
# Parsing
my $stop-skip = 0;
my $actions = I18N::LangTags::Actions.new;

# Storing
my Str $last-lang-name;
our %Name;
our %Is_Disrec;

my sub save-language(Str:D $tag, Str:D $name = $last-lang-name, Bool $is_disrec = True) {
    $last-lang-name = $name;
    %Name{      $tag } = $name;
    %Is_Disrec{ $tag } = $name if $is_disrec;
}

for $=pod[0].contents() -> $node {
    if $node ~~ Pod::Heading
        and $node.contents.[0] ~~ Pod::Block::Para
        and $node.contents.[0].contents.[0] eq 'LIST OF LANGUAGES'
    {
        $stop-skip = 1,
    }
    if $stop-skip {
        if $node ~~ Pod::Item {
            for $node.contents -> $subnode {
                if $subnode ~~ (Pod::Block::Para|Pod::Block::Comment) {
                    for $subnode.contents -> $content {
                        if $content ~~ Str {

                            say $content if $Debug;

                            for I18N::LangTags::Grammar.parse(
                                $content,
                                :rule('scan_languages'),
                                :$actions).made -> $language {
                                say $language if $Debug;
                                with $language {
                                    save-language($language<tag>, $language<name>, $language<is_disrec>);
                                }
                            }
                            if I18N::LangTags::Grammar.parse(
                                $content,
                                :rule('formerly'),
                                :$actions).made() -> $langtag {
                                save-language($langtag);
                            };
                        }
                    }
                }
            }
        }
    }
}

our sub name(Str:D $tag is copy --> Str:D) {
    $tag .= trim();

    return Nil unless I18N::LangTags::Grammar.parse($tag, :rule('langtag'));
    say "Input: {$tag}" if $Debug;

    my $subform = '';
    my $name = '';
    my $alt = '';
    $alt = 'x-' ~ $/[0] if $tag ~~ / 'i-' (.*) /;
    $alt = 'i-' ~ $/[0] if $tag ~~ / 'x-' (.*) /;

    my regex shave { '-' <alnum>+ $ };
    while $tag.chars {
        last if $name = %Name{$tag};
        last if $name = %Name{$alt};

        if $tag ~~ s/ ( <shave> ) // {
            say "Shaving off: $/[0] leaving $tag" if $Debug;
            $subform = $/[0] ~ $subform;

            $alt ~~ s/ ( <shave> )//;
            say " alt -> $alt" if $Debug;
        } else {
            # we're trying to pull a subform off a primary tag. TILT!
            say "Aborting on: {$name}{$subform}" if $Debug;
            last;
        }
    }
    return Nil unless $name;
    return $name unless $subform;

    $subform ~~ s/ ^ '-'   //;
    $subform ~~ s/   '-' $ //;
    return "$name (Subform \"$subform\")";
}

our sub is_decent(Str:D $tag --> Bool) {
    return False unless I18N::LangTags::Grammar.parse($tag, :rule('langtag'));
    my @supers = ();
    for $tag.split('-') -> $bit {
        @supers.push( @supers.elems > 0 ?? @supers[*-1] ~ '-' ~ $bit !! $bit);
    };
    @supers.shift() if @supers[0].fc eq fc('i' | 'x' | 'sgn');
    return False unless @supers;
    for ($tag, |@supers) -> $f {
        return False if %Is_Disrec{ $f }:exists;
        return True if %Name{ $f }:exists;
    }
    return True;
}

=begin pod

=head1 NAME

I18N::LangTags::List -- tags and names for human languages

=head1 SYNOPSIS

  use I18N::LangTags::List;
  print "Parlez-vous... ", join(', ',
      I18N::LangTags::List::name('elx') || 'unknown_language',
      I18N::LangTags::List::name('ar-Kw') || 'unknown_language',
      I18N::LangTags::List::name('en') || 'unknown_language',
      I18N::LangTags::List::name('en-CA') || 'unknown_language',
    ), "?\n";

prints:

  Parlez-vous... Elamite, Kuwait Arabic, English, Canadian English?

=head1 DESCRIPTION

This module provides a function
C<I18N::LangTags::List::name( I<langtag> ) > that takes
a language tag (see L<I18N::LangTags|I18N::LangTags>)
and returns the best attempt at an English name for it, or
undef if it can't make sense of the tag.

The function I18N::LangTags::List::name(...) is not exported.

This module also provides a function
C<I18N::LangTags::List::is_decent( I<langtag> )> that returns true iff
the language tag is syntactically valid and is for general use (like
"fr" or "fr-ca", below).  That is, it returns false for tags that are
syntactically invalid and for tags, like "aus", that are listed in
brackets below.  This function is not exported.

The map of tags-to-names that it uses is accessible as
%I18N::LangTags::List::Name, and it's the same as the list
that follows in this documentation, which should be useful
to you even if you don't use this module.

=head1 ABOUT LANGUAGE TAGS

Internet language tags, as defined in RFC 3066, are a formalism
for denoting human languages.  The two-letter ISO 639-1 language
codes are well known (as "en" for English), as are their forms
when qualified by a country code ("en-US").  Less well-known are the
arbitrary-length non-ISO codes (like "i-mingo"), and the
recently (in 2001) introduced three-letter ISO-639-2 codes.

Remember these important facts:

=begin item
Language tags are not locale IDs.  A locale ID is written with a "_"
instead of a "-", (almost?) always matches C<m/^\w\w_\w\w\b/>, and
I<means> something different than a language tag.  A language tag
denotes a language.  A locale ID denotes a language I<as used in>
a particular place, in combination with non-linguistic
location-specific information such as what currency is used
there.  Locales I<also> often denote character set information,
as in "en_US.ISO8859-1".
=end item

=begin item
Language tags are not for computer languages.
=end item

=begin item
"Dialect" is not a useful term, since there is no objective
criterion for establishing when two language-forms are
dialects of eachother, or are separate languages.
=end item

=begin item
Language tags are not case-sensitive.  en-US, en-us, En-Us, etc.,
are all the same tag, and denote the same language.
=end item

=begin item
Not every language tag really refers to a single language.  Some
language tags refer to conditions: i-default (system-message text
in English plus maybe other languages), und (undetermined
language).  Others (notably lots of the three-letter codes) are
bibliographic tags that classify whole groups of languages, as
with cus "Cushitic (Other)" (i.e., a
language that has been classed as Cushtic, but which has no more
specific code) or the even less linguistically coherent
sai for "South American Indian (Other)".  Though useful in
bibliography, B<SUCH TAGS ARE NOT
FOR GENERAL USE>.  For further guidance, email me.
=end item

=begin item
Language tags are not country codes.  In fact, they are often
distinct codes, as with language tag ja for Japanese, and
ISO 3166 country code C<.jp> for Japan.
=end item

=head1 LIST OF LANGUAGES

The first part of each item is the language tag, between
{...}. It is followed by an English name for the language or language-group.
Language tags that I judge to be not for general use, are bracketed.

This list is in alphabetical order by English name of the language.

=begin item
{ab} : Abkhazian

eq Abkhaz
=end item

=item {ace} : Achinese

=item {ach} : Acoli

=item {ada} : Adangme

=begin item
{ady} : Adyghe

eq Adygei
=end item

=item {aa} : Afar

=begin item
{afh} : Afrihili

(Artificial)
=end item

=item {af} : Afrikaans

=item [{afa} : Afro-Asiatic (Other)]

=begin item
{ak} : Akan

(Formerly "aka".)
=end item

=begin item
{akk} : Akkadian

(Historical)
=end item

=item {sq} : Albanian

=item {ale} : Aleut

=begin item
[{alg} : Algonquian languages]

NOT Algonquin!
=end item

=item [{tut} : Altaic (Other)]

=begin item
{am} : Amharic

NOT Aramaic!
=end item

=begin item
{i-ami} : Ami

eq Amis.  eq 'Amis.  eq Pangca.
=end item

=item [{apa} : Apache languages]

=begin item
{ar} : Arabic

Many forms are mutually un-intelligible in spoken media.
Notable forms:

{ar-ae} UAE Arabic;
{ar-bh} Bahrain Arabic;
{ar-dz} Algerian Arabic;
{ar-eg} Egyptian Arabic;
{ar-iq} Iraqi Arabic;
{ar-jo} Jordanian Arabic;
{ar-kw} Kuwait Arabic;
{ar-lb} Lebanese Arabic;
{ar-ly} Libyan Arabic;
{ar-ma} Moroccan Arabic;
{ar-om} Omani Arabic;
{ar-qa} Qatari Arabic;
{ar-sa} Sauda Arabic;
{ar-sy} Syrian Arabic;
{ar-tn} Tunisian Arabic;
{ar-ye} Yemen Arabic.
=end item

=begin item
{arc} : Aramaic

NOT Amharic!  NOT Samaritan Aramaic!
=end item

=item {arp} : Arapaho

=item {arn} : Araucanian

=item {arw} : Arawak

=item {hy} : Armenian

=item {an} : Aragonese

=item [{art} : Artificial (Other)]

=begin item
{ast} : Asturian

eq Bable.
=end item

=item {as} : Assamese

=begin item
[{ath} : Athapascan languages]

eq Athabaskan.  eq Athapaskan.  eq Athabascan.
=end item

=item [{aus} : Australian languages]

=item [{map} : Austronesian (Other)]

=begin item
{av} : Avaric

(Formerly "ava".)
=end item

=begin item
{ae} : Avestan

eq Zend
=end item

=item {awa} : Awadhi

=item {ay} : Aymara

=begin item
{az} : Azerbaijani

eq Azeri

Notable forms:
{az-Arab} Azerbaijani in Arabic script;
{az-Cyrl} Azerbaijani in Cyrillic script;
{az-Latn} Azerbaijani in Latin script.
=end item

=item {ban} : Balinese

=item [{bat} : Baltic (Other)]

=item {bal} : Baluchi

=begin item
{bm} : Bambara

(Formerly "bam".)
=end item

=item [{bai} : Bamileke languages]

=item {bad} : Banda

=item [{bnt} : Bantu (Other)]

=item {bas} : Basa

=item {ba} : Bashkir

=item {eu} : Basque

=item {btk} : Batak (Indonesia)

=item {bej} : Beja

=begin item
{be} : Belarusian

eq Belarussian.  eq Byelarussian.
eq Belorussian.  eq Byelorussian.
eq White Russian.  eq White Ruthenian.
NOT Ruthenian!
=end item

=item {bem} : Bemba

=begin item
item {bn} : Bengali

eq Bangla.
=end item

=item [{ber} : Berber (Other)]

=item {bho} : Bhojpuri

=item {bh} : Bihari

=item {bik} : Bikol

=item {bin} : Bini

=begin item
{bi} : Bislama

eq Bichelamar.
=end item

=item {bs} : Bosnian

=item {bra} : Braj

=item {br} : Breton

=item {bug} : Buginese

=item {bg} : Bulgarian

=item {i-bnn} : Bunun

=item {bua} : Buriat

=item {my} : Burmese

=item {cad} : Caddo

=item {car} : Carib

=begin item
{ca} : Catalan

eq Catalán.  eq Catalonian.
=end item

=item [{cau} : Caucasian (Other)]

=item {ceb} : Cebuano

=begin item
[{cel} : Celtic (Other)]

Notable forms:

{cel-gaulish} Gaulish (Historical)
=end item

=item [{cai} : Central American Indian (Other)]

=begin item
{chg} : Chagatai

(Historical?)
=end item

=item [{cmc} : Chamic languages]

=item {ch} : Chamorro

=item {ce} : Chechen

=begin item
{chr} : Cherokee

eq Tsalagi
=end item

=item {chy} : Cheyenne

=begin item
{chb} : Chibcha

(Historical)  NOT Chibchan (which is a language family).
=end item

=begin item
{ny} : Chichewa

eq Nyanja.  eq Chinyanja.
=end item

=begin item
{zh} : Chinese

Many forms are mutually un-intelligible in spoken media.
Notable forms:

{zh-Hans} Chinese, in simplified script;
{zh-Hant} Chinese, in traditional script;
{zh-tw} Taiwan Chinese;
{zh-cn} PRC Chinese;
{zh-sg} Singapore Chinese;
{zh-mo} Macau Chinese;
{zh-hk} Hong Kong Chinese;
{zh-guoyu} Mandarin [Putonghua/Guoyu];
{zh-hakka} Hakka [formerly "i-hakka"];
{zh-min} Hokkien;
{zh-min-nan} Southern Hokkien;
{zh-wuu} Shanghaiese;
{zh-xiang} Hunanese;
{zh-gan} Gan;
{zh-yue} Cantonese.

=comment {i-hakka} Hakka (old tag)
=end item

=begin item
{chn} : Chinook Jargon

eq Chinook Wawa.
=end item

=item {chp} : Chipewyan

=item {cho} : Choctaw

=begin item
{cu} : Church Slavic

eq Old Church Slavonic.
=end item

=begin item
{chk} : Chuukese

eq Trukese.  eq Chuuk.  eq Truk.  eq Ruk.
=end item

=item {cv} : Chuvash

=item {cop} : Coptic

=item {kw} : Cornish

=begin item
{co} : Corsican

eq Corse.
=end item

=begin item
{cr} : Cree

NOT Creek!  (Formerly "cre".)
=end item

=begin item
{mus} : Creek

NOT Cree!
=end item

=item [{cpe} : English-based Creoles and pidgins (Other)]

=item [{cpf} : French-based Creoles and pidgins (Other)]

=item [{cpp} : Portuguese-based Creoles and pidgins (Other)]

=item [{crp} : Creoles and pidgins (Other)]

=begin item
{hr} : Croatian

eq Croat.
=end item

=item [{cus} : Cushitic (Other)]

=item {cs} : Czech

=begin item
{dak} : Dakota

eq Nakota.  eq Latoka.
=end item

=item {da} : Danish

=item {dar} : Dargwa

=item {day} : Dayak

=begin item
{i-default} : Default (Fallthru) Language

Defined in RFC 2277, this is for tagging text
(which must include English text, and might/should include text
in other appropriate languages) that is emitted in a context
where language-negotiation wasn't possible -- in SMTP mail failure
messages, for example.
=end item

=item {del} : Delaware

=item {din} : Dinka

=begin item
{dv} : Divehi

eq Maldivian.  (Formerly "div".)
=end item

=begin item
{doi} : Dogri

NOT Dogrib!
=end item

=begin item
{dgr} : Dogrib

NOT Dogri!
=end item

=item [{dra} : Dravidian (Other)]

=item {dua} : Duala

=begin item
{nl} : Dutch

eq Netherlander.  Notable forms:

{nl-nl} Netherlands Dutch;
{nl-be} Belgian Dutch.
=end item

=begin item
{dum} : Middle Dutch (ca.1050-1350)

(Historical)
=end item

=item {dyu} : Dyula

=item {dz} : Dzongkha

=item {efi} : Efik

=begin item
{egy} : Ancient Egyptian

(Historical)
=end item

=item {eka} : Ekajuk

=begin item
{elx} : Elamite

(Historical)
=end item

=begin item
{en} : English

Notable forms:

{en-au} Australian English;
{en-bz} Belize English;
{en-ca} Canadian English;
{en-gb} UK English;
{en-ie} Irish English;
{en-jm} Jamaican English;
{en-nz} New Zealand English;
{en-ph} Philippine English;
{en-tt} Trinidad English;
{en-us} US English;
{en-za} South African English;
{en-zw} Zimbabwe English.
=end item

=begin item
{enm} : Old English (1100-1500)

(Historical)
=end item

=begin item
{ang} : Old English (ca.450-1100)

eq Anglo-Saxon.  (Historical)
=end item

=item {i-enochian} : Enochian (Artificial)

=item {myv} : Erzya

=begin item
{eo} : Esperanto

(Artificial)
=end item

=item {et} : Estonian

=begin item
{ee} : Ewe

(Formerly "ewe".)
=end item

=item {ewo} : Ewondo

=item {fan} : Fang

=item {fat} : Fanti

=item {fo} : Faroese

=item {fj} : Fijian

=item {fi} : Finnish

=begin item
[{fiu} : Finno-Ugrian (Other)]

eq Finno-Ugric.  NOT Ugaritic!
=end item

=item {fon} : Fon

=begin item
{fr} : French

Notable forms:

{fr-fr} France French;
{fr-be} Belgian French;
{fr-ca} Canadian French;
{fr-ch} Swiss French;
{fr-lu} Luxembourg French;
{fr-mc} Monaco French.
=end item

=begin item
{frm} : Middle French (ca.1400-1600)

(Historical)
=end item

=begin item
{fro} : Old French (842-ca.1400)

(Historical)
=end item

=item {fy} : Frisian

=item {fur} : Friulian

=begin item
{ff} : Fulah

(Formerly "ful".)
=end item

=item {gaa} : Ga

=begin item
{gd} : Scots Gaelic

NOT Scots!
=end item

=begin item
{gl} : Gallegan

eq Galician
=end item

=begin item
{lg} : Ganda

(Formerly "lug".)
=end item

=item {gay} : Gayo

=item {gba} : Gbaya

=begin item
{gez} : Geez

eq Ge'ez
=end item

=item {ka} : Georgian

=begin item
{de} : German

Notable forms:

{de-at} Austrian German;
{de-be} Belgian German;
{de-ch} Swiss German;
{de-de} Germany German;
{de-li} Liechtenstein German;
{de-lu} Luxembourg German.
=end item

=begin item
{gmh} : Middle High German (ca.1050-1500)

(Historical)
=end item

=begin item
{goh} : Old High German (ca.750-1050)

(Historical)
=end item

=item [{gem} : Germanic (Other)]

=item {gil} : Gilbertese

=item {gon} : Gondi

=item {gor} : Gorontalo

=begin item
{got} : Gothic

(Historical)
=end item

=item {grb} : Grebo

=begin item
{grc} : Ancient Greek

(Historical)  (Until 15th century or so.)
=end item

=begin item
{el} : Modern Greek

(Since 15th century or so.)
=end item

=begin item
{gn} : Guarani

Guaraní
=end item

=item {gu} : Gujarati

=begin item
{gwi} : Gwich'in

eq Gwichin
=end item

=item {hai} : Haida

=begin item
{ht} : Haitian

eq Haitian Creole
=end item

=item {ha} : Hausa

=begin item
{haw} : Hawaiian

Hawai'ian
=end item

=begin item
{he} : Hebrew

(Formerly "iw".)
=comment {iw} Hebrew (old tag)
=end item

=item {hz} : Herero

=item {hil} : Hiligaynon

=item {him} : Himachali

=item {hi} : Hindi

=item {ho} : Hiri Motu

=begin item
{hit} : Hittite

(Historical)
=end item

=item {hmn} : Hmong

=item {hu} : Hungarian

=item {hup} : Hupa

=item {iba} : Iban

=item {is} : Icelandic

=begin item
{io} : Ido

(Artificial)
=end item

=begin item
{ig} : Igbo

(Formerly "ibo".)
=end item

=item {ijo} : Ijo

=item {ilo} : Iloko

=item [{inc} : Indic (Other)]

=item [{ine} : Indo-European (Other)]

=begin item
{id} : Indonesian

(Formerly "in".)
=comment {in} Indonesian (old tag)
=end item

=item {inh} : Ingush

=begin item
{ia} : Interlingua (International Auxiliary Language Association)

(Artificial)  NOT Interlingue!
=end item

=begin item
{ie} : Interlingue

(Artificial)  NOT Interlingua!
=end item

=begin item
{iu} : Inuktitut

A subform of "Eskimo".
=end item

=begin item
{ik} : Inupiaq

A subform of "Eskimo".
=end item

=item [{ira} : Iranian (Other)]

=item {ga} : Irish

=begin item
{mga} : Middle Irish (900-1200)

(Historical)
=end item

=begin item
{sga} : Old Irish (to 900)

(Historical)
=end item

=item [{iro} : Iroquoian languages]

=begin item
{it} : Italian

Notable forms:

{it-it} Italy Italian;
{it-ch} Swiss Italian.
=end item

=begin item
{ja} : Japanese

(NOT "jp"!)
=end item

=begin item
{jv} : Javanese

(Formerly "jw" because of a typo.)
=end item

=item {jrb} : Judeo-Arabic

=item {jpr} : Judeo-Persian

=item {kbd} : Kabardian

=item {kab} : Kabyle

=item {kac} : Kachin

=begin item
{kl} : Kalaallisut

eq Greenlandic "Eskimo"
=end item

=item {xal} : Kalmyk

=item {kam} : Kamba

=begin item
{kn} : Kannada

eq Kanarese.  NOT Canadian!
=end item

=begin item
{kr} : Kanuri

(Formerly "kau".)
=end item

=item {krc} : Karachay-Balkar

=item {kaa} : Kara-Kalpak

=item {kar} : Karen

=item {ks} : Kashmiri

=begin item
{csb} : Kashubian

eq Kashub
=end item

=item {kaw} : Kawi

=item {kk} : Kazakh

=item {kha} : Khasi

=begin item
{km} : Khmer

eq Cambodian.  eq Kampuchean.
=end item

=item [{khi} : Khoisan (Other)]

=item {kho} : Khotanese

=begin item
{ki} : Kikuyu

eq Gikuyu.
=end item

=item {kmb} : Kimbundu

=item {rw} : Kinyarwanda

=item {ky} : Kirghiz

=item {i-klingon} : Klingon

=item {kv} : Komi

=begin item
{kg} : Kongo

(Formerly "kon".)
=end item

=item {kok} : Konkani

=item {ko} : Korean

=item {kos} : Kosraean

=item {kpe} : Kpelle

=item {kro} : Kru

=item {kj} : Kuanyama

=item {kum} : Kumyk

=item {ku} : Kurdish

=item {kru} : Kurukh

=item {kut} : Kutenai

=begin item
{lad} : Ladino

eq Judeo-Spanish.  NOT Ladin (a minority language in Italy).
=end item

=begin item
{lah} : Lahnda

NOT Lamba!
=end item

=begin item
{lam} : Lamba

NOT Lahnda!
=end item

=begin item
{lo} : Lao

eq Laotian.
=end item

=begin item
{la} : Latin

(Historical)  NOT Ladin!  NOT Ladino!
=end item

=begin item
{lv} : Latvian

eq Lettish.
=end item

=begin item
{lb} : Letzeburgesch

eq Luxemburgian, eq Luxemburger.  (Formerly "i-lux".)

=comment {i-lux} Letzeburgesch (old tag)
=end item

=item {lez} : Lezghian

=begin item
{li} : Limburgish

eq Limburger, eq Limburgan.  NOT Letzeburgesch!
=end item

=item {ln} : Lingala

=item {lt} : Lithuanian

=begin item
{nds} : Low German

eq Low Saxon.  eq Low German.  eq Low Saxon.
=end item

=item {art-lojban} : Lojban (Artificial)

=item {loz} : Lozi

=begin item
{lu} : Luba-Katanga

(Formerly "lub".)
=end item

=item {lua} : Luba-Lulua

=begin item
{lui} : Luiseno

eq Luiseño.
=end item

=item {lun} : Lunda

=item {luo} : Luo (Kenya and Tanzania)

=item {lus} : Lushai

=begin item
{mk} : Macedonian

eq the modern Slavic language spoken in what was Yugoslavia.
NOT the form of Greek spoken in Greek Macedonia!
=end item

=item {mad} : Madurese

=item {mag} : Magahi

=item {mai} : Maithili

=item {mak} : Makasar

=item {mg} : Malagasy

=begin item
{ms} : Malay

NOT Malayalam!
=end item

=begin item
{ml} : Malayalam

NOT Malay!
=end item

=item {mt} : Maltese

=item {mnc} : Manchu

=begin item
{mdr} : Mandar

NOT Mandarin!
=end item

=item {man} : Mandingo

=begin item
{mni} : Manipuri

eq Meithei.
=end item

=item [{mno} : Manobo languages]

=item {gv} : Manx

=begin item
{mi} : Maori

NOT Mari!
=end item

=item {mr} : Marathi

=begin item
{chm} : Mari

NOT Maori!
=end item

=begin item
{mh} : Marshall

eq Marshallese.
=end item

=item {mwr} : Marwari

=item {mas} : Masai

=item [{myn} : Mayan languages]

=item {men} : Mende

=item {mic} : Micmac

=item {min} : Minangkabau

=begin item
{i-mingo} : Mingo

eq the Irquoian language West Virginia Seneca.  NOT New York Seneca!
=end item

=begin item
[{mis} : Miscellaneous languages]

Don't use this.
=end item

=item {moh} : Mohawk

=item {mdf} : Moksha

=begin item
{mo} : Moldavian

eq Moldovan.
=end item

=item [{mkh} : Mon-Khmer (Other)]

=item {lol} : Mongo

=begin item
{mn} : Mongolian

eq Mongol.
=end item

=item {mos} : Mossi

=begin item
[{mul} : Multiple languages]

Not for normal use.
=end item

=item [{mun} : Munda languages]

=item {nah} : Nahuatl

=item {nap} : Neapolitan

=item {na} : Nauru

=begin item
{nv} : Navajo

eq Navaho.  (Formerly "i-navajo".)

=comment {i-navajo} Navajo (old tag)
=end item

=item {nd} : North Ndebele

=item {nr} : South Ndebele

=item {ng} : Ndonga

=begin item
{ne} : Nepali

eq Nepalese.  Notable forms:

{ne-np} Nepal Nepali;
{ne-in} India Nepali.
=end item

=item {new} : Newari

=item {nia} : Nias

=item [{nic} : Niger-Kordofanian (Other)]

=item [{ssa} : Nilo-Saharan (Other)]

=item {niu} : Niuean

=item {nog} : Nogai

=begin item
{non} : Old Norse

(Historical)
=end item

=begin item
[{nai} : North American Indian]

Do not use this.
=end item

=begin item
{no} : Norwegian

Note the two following forms:
=end item

=begin item
{nb} : Norwegian Bokmal

eq Bokmål, (A form of Norwegian.)  (Formerly "no-bok".)

=comment {no-bok} Norwegian Bokmal (old tag)
=end item

=begin item
{nn} : Norwegian Nynorsk

(A form of Norwegian.)  (Formerly "no-nyn".)

=comment {no-nyn} Norwegian Nynorsk (old tag)
=end item

=item [{nub} : Nubian languages]

=item {nym} : Nyamwezi

=item {nyn} : Nyankole

=item {nyo} : Nyoro

=item {nzi} : Nzima

=begin item
{oc} : Occitan (post 1500)

eq Provençal, eq Provencal
=end item

=begin item
{oj} : Ojibwa

eq Ojibwe.  (Formerly "oji".)
=end item

=item {or} : Oriya

=item {om} : Oromo

=item {osa} : Osage

=item {os} : Ossetian; Ossetic

=begin item
[{oto} : Otomian languages]

Group of languages collectively called "Otomí".
=end item

=begin item
{pal} : Pahlavi

eq Pahlevi
=end item

=begin item
{i-pwn} : Paiwan

eq Pariwan
=end item

=item {pau} : Palauan

=begin item
{pi} : Pali

(Historical?)
=end item

=item {pam} : Pampanga

=item {pag} : Pangasinan

=begin item
{pa} : Panjabi

eq Punjabi
=end item

=begin item
{pap} : Papiamento

eq Papiamentu.
=end item

=item [{paa} : Papuan (Other)]

=begin item
{fa} : Persian

eq Farsi.  eq Iranian.
=end item

=item {peo} : Old Persian (ca.600-400 B.C.)

=item [{phi} : Philippine (Other)]

=begin item
{phn} : Phoenician

(Historical)
=end item

=begin item
{pon} : Pohnpeian

NOT Pompeiian!
=end item

=item {pl} : Polish

=begin item
{pt} : Portuguese

eq Portugese.  Notable forms:

{pt-pt} Portugal Portuguese;
{pt-br} Brazilian Portuguese.
=end item

=item [{pra} : Prakrit languages]

=begin item
{pro} : Old Provencal (to 1500)

eq Old Provençal.  (Historical.)
=end item

=begin item
{ps} : Pushto

eq Pashto.  eq Pushtu.
=end item

=begin item
{qu} : Quechua

eq Quecha.
=end item

=begin item
{rm} : Raeto-Romance

eq Romansh.
=end item

=item {raj} : Rajasthani

=item {rap} : Rapanui

=item {rar} : Rarotongan

=item [{qaa - qtz} : Reserved for local use.]

=begin item
[{roa} : Romance (Other)]

NOT Romanian!  NOT Romany!  NOT Romansh!
=end item

=begin item
{ro} : Romanian

eq Rumanian.  NOT Romany!
=end item

=begin item
{rom} : Romany

eq Rom.  NOT Romanian!
=end item

=item {rn} : Rundi

=begin item
{ru} : Russian

NOT White Russian!  NOT Rusyn!
=end item

=begin item
[{sal} : Salishan languages]

Large language group.
=end item

=begin item
{sam} : Samaritan Aramaic

NOT Aramaic!
=end item

=begin item
{se} : Northern Sami

eq Lappish.  eq Lapp.  eq (Northern) Saami.
=end item

=item {sma} : Southern Sami

=item {smn} : Inari Sami

=item {smj} : Lule Sami

=item {sms} : Skolt Sami

=item [{smi} : Sami languages (Other)]

=item {sm} : Samoan

=item {sad} : Sandawe

=item {sg} : Sango

=begin item
{sa} : Sanskrit

(Historical)
=end item

=item {sat} : Santali

=begin item
{sc} : Sardinian

eq Sard.
=end item

=item {sas} : Sasak

=begin item
{sco} : Scots

NOT Scots Gaelic!
=end item

=item {sel} : Selkup

=item [{sem} : Semitic (Other)]

=begin item
{sr} : Serbian

eq Serb.  NOT Sorbian.

Notable forms:

{sr-Cyrl} : Serbian in Cyrillic script;
{sr-Latn} : Serbian in Latin script.
=end item

=item {srr} : Serer

=item {shn} : Shan

=item {sn} : Shona

=item {sid} : Sidamo

=begin item
{sgn-...} : Sign Languages

Always use with a subtag.  Notable forms:
{sgn-gb} British Sign Language (BSL);
{sgn-ie} Irish Sign Language (ESL);
{sgn-ni} Nicaraguan Sign Language (ISN);
{sgn-us} American Sign Language (ASL).

(And so on with other country codes as the subtag.)
=end item

=begin item
{bla} : Siksika

eq Blackfoot.  eq Pikanii.
=end item

=item {sd} : Sindhi

=begin item
{si} : Sinhalese

eq Sinhala.
=end item

=item [{sit} : Sino-Tibetan (Other)]

=item [{sio} : Siouan languages]

=begin item
{den} : Slave (Athapascan)

("Slavey" is a subform.)
=end item

=item [{sla} : Slavic (Other)]

=begin item
{sk} : Slovak

eq Slovakian.
=end item

=begin item
{sl} : Slovenian

eq Slovene.
=end item

=item {sog} : Sogdian

=item {so} : Somali

=item {son} : Songhai

=item {snk} : Soninke

=begin item
{wen} : Sorbian languages

eq Wendish.  eq Sorb.  eq Lusatian.  eq Wend.  NOT Venda!  NOT Serbian!
=end item

=item {nso} : Northern Sotho

=begin item
{st} : Southern Sotho

eq Sutu.  eq Sesotho.
=end item

=item [{sai} : South American Indian (Other)]

=begin item
{es} : Spanish

Notable forms:

{es-ar} Argentine Spanish;
{es-bo} Bolivian Spanish;
{es-cl} Chilean Spanish;
{es-co} Colombian Spanish;
{es-do} Dominican Spanish;
{es-ec} Ecuadorian Spanish;
{es-es} Spain Spanish;
{es-gt} Guatemalan Spanish;
{es-hn} Honduran Spanish;
{es-mx} Mexican Spanish;
{es-pa} Panamanian Spanish;
{es-pe} Peruvian Spanish;
{es-pr} Puerto Rican Spanish;
{es-py} Paraguay Spanish;
{es-sv} Salvadoran Spanish;
{es-us} US Spanish;
{es-uy} Uruguayan Spanish;
{es-ve} Venezuelan Spanish.
=end item

=item {suk} : Sukuma

=begin item
{sux} : Sumerian

(Historical)
=end item

=item {su} : Sundanese

=item {sus} : Susu

=begin item
{sw} : Swahili

eq Kiswahili
=end item

=item {ss} : Swati

=begin item
{sv} : Swedish

Notable forms:

{sv-se} Sweden Swedish;
{sv-fi} Finland Swedish.
=end item

=item {syr} : Syriac

=item {tl} : Tagalog

=item {ty} : Tahitian

=begin item
[{tai} : Tai (Other)]

NOT Thai!
=end item

=item {tg} : Tajik

=item {tmh} : Tamashek

=item {ta} : Tamil

=begin item
{i-tao} : Tao

eq Yami.
=end item

=item {tt} : Tatar

=begin item
{i-tay} : Tayal

eq Atayal.  eq Atayan.
=end item

=item {te} : Telugu

=item {ter} : Tereno

=item {tet} : Tetum

=begin item
{th} : Thai

NOT Tai!
=end item

=item {bo} : Tibetan

=item {tig} : Tigre

=item {ti} : Tigrinya

=begin item
{tem} : Timne

eq Themne.  eq Timene.
=end item

=item {tiv} : Tiv

=item {tli} : Tlingit

=item {tpi} : Tok Pisin

=item {tkl} : Tokelau

=begin item
{tog} : Tonga (Nyasa)

NOT Tsonga!
=end item

=begin item
{to} : Tonga (Tonga Islands)

(Pronounced "Tong-a", not "Tong-ga")

NOT Tsonga!
=end item

=begin item
{tsi} : Tsimshian

eq Sm'algyax
=end item

=begin item
{ts} : Tsonga

NOT Tonga!
=end item

=item {i-tsu} : Tsou

=begin item
{tn} : Tswana

Same as Setswana.
=end item

=item {tum} : Tumbuka

=item [{tup} : Tupi languages]

=begin item
{tr} : Turkish

(Typically in Roman script)
=end item

=begin item
{ota} : Ottoman Turkish (1500-1928)

(Typically in Arabic script)  (Historical)
=end item

=begin item
{crh} : Crimean Turkish

eq Crimean Tatar
=end item

=begin item
{tk} : Turkmen

eq Turkmeni.
=end item

=item {tvl} : Tuvalu

=begin item
{tyv} : Tuvinian

eq Tuvan.  eq Tuvin.
=end item

=item {tw} : Twi

=item {udm} : Udmurt

=begin item
{uga} : Ugaritic

NOT Ugric!
=end item

=item {ug} : Uighur

=item {uk} : Ukrainian

=item {umb} : Umbundu

=begin item
{und} : Undetermined

Not a tag for normal use.
=end item

=item {ur} : Urdu

=begin item
{uz} : Uzbek

eq Üzbek

Notable forms:

{uz-Cyrl} Uzbek in Cyrillic script;
{uz-Latn} Uzbek in Latin script.
=end item

=item {vai} : Vai

=begin item
{ve} : Venda

NOT Wendish!  NOT Wend!  NOT Avestan!  (Formerly "ven".)
=end item

=begin item
{vi} : Vietnamese

eq Viet.
=end item

=begin item
{vo} : Volapuk

eq Volapük.  (Artificial)
=end item

=begin item
{vot} : Votic

eq Votian.  eq Vod.
=end item

=item [{wak} : Wakashan languages]

=item {wa} : Walloon

=begin item
{wal} : Walamo

eq Wolaytta.
=end item

=begin item
{war} : Waray

Presumably the Philippine language Waray-Waray (Samareño),
not the smaller Philippine language Waray Sorsogon, nor the extinct
Australian language Waray.
=end item

=begin item
{was} : Washo

eq Washoe
=end item

=item {cy} : Welsh

=item {wo} : Wolof

=begin item
{x-...} : Unregistered (Semi-Private Use)

"x-" is a prefix for language tags that are not registered with ISO
or IANA.  Example, x-double-dutch
=end item

=item {xh} : Xhosa

=item {sah} : Yakut

=begin item
{yao} : Yao

(The Yao in Malawi?)
=end item

=begin item
{yap} : Yapese

eq Yap
=end item

=item {ii} : Sichuan Yi

=begin item
{yi} : Yiddish

Formerly "ji".  Usually in Hebrew script.

Notable forms:

{yi-latn} Yiddish in Latin script
=end item

=item {yo} : Yoruba

=begin item
[{ypk} : Yupik languages]

Several "Eskimo" languages.
=end item

=item {znd} : Zande

=begin item
[{zap} : Zapotec]

(A group of languages.)
=end item

=begin item
{zen} : Zenaga

NOT Zend.
=end item

=item {za} : Zhuang

=item {zu} : Zulu

=begin item
{zun} : Zuni

eq Zuñi
=end item

=head1 SEE ALSO

L<I18N::LangTags|I18N::LangTags> and its "See Also" section.

=end pod
