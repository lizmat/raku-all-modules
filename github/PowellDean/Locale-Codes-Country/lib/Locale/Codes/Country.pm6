use v6;
unit module Locale::Codes::Country;

constant LOCALE_CODE_ALPHA_2 is export = 'alpha-2';
constant LOCALE_CODE_ALPHA_3 is export = 'alpha-3';
constant LOCALE_CODE_NUMERIC is export = 'numeric';
constant LOCALE_CODE_DOM is export = 'dom';

# Local hashes. No need to export as values are sent via functions.
my %code2ToCountry;
my %code3ToCountry;
my %codeNumToCountry;
my %countryToCode2;
my %countryToCode3;
my %countryToCodeNum;
my %countryXRef;

# Read the data supplied at the bottom of this module and populate our
# hashes.
for $=finish.lines {
    my ($code2, $code3, $codeNum, $country) = .split(":");
    my $isoNum = sprintf("%03d", $codeNum);

    $country = processComplexName($country.uc) if $country.index(",");

    %code2ToCountry{$code2.uc} = $country.uc;
    %code3ToCountry{$code3.uc} = $country.uc;
    %codeNumToCountry{$isoNum} = $country.uc;
}

%countryToCode2 = %code2ToCountry.invert;
%countryToCode3 = %code3ToCountry.invert;
%countryToCodeNum = %codeNumToCountry.invert;

sub VERSION() is export { v1.0.0; }

sub allCountryCodes($codeset?=LOCALE_CODE_ALPHA_2) is export {
    given $codeset {
        return %code2ToCountry.keys when LOCALE_CODE_ALPHA_2;
        return %code3ToCountry.keys when LOCALE_CODE_ALPHA_3;
        return %codeNumToCountry.keys when LOCALE_CODE_NUMERIC;
        return map({"\.$_".lc}, %code2ToCountry.keys) when LOCALE_CODE_DOM;
    }
}

sub allCountryNames() is export { return %countryToCode2.keys; }

# Given the country code, return one of the other formats according
# to the locale requested
sub codeToCode($code!, $codesetOut?=LOCALE_CODE_ALPHA_2) is export {
    my $country = codeToCountry($code);
    return Any if (!$country);
    return countryToCode($country, $codesetOut);
}

multi codeToCountry(Str $aCode) is export {
    given chars($aCode) {
        when 2 { return %code2ToCountry{$aCode.uc}; }
        when 3 {
            if $aCode ~~ /^\./ {
                my $trimCode = $aCode;
                $trimCode ~~ s/\.//;
                return %code2ToCountry{$trimCode.uc};
            }
            return %code3ToCountry{$aCode.uc}; }
        default { die "Code must be either 2 or 3 ASCII characters"; }
    }
    return Any;
}

multi codeToCountry(Int $aCode) is export {
    my $key = sprintf("%03d", $aCode);
    return %codeNumToCountry{$key};
}

# Sure, there's some hard coding in this, and hard-coding is usually a Bad
# Thing. But it fits for a small number of countries, and when you think
# about the alternative, is it really so awful?
sub countryToCode($country!, $codesetOut?=LOCALE_CODE_ALPHA_2) is export {
    my $commonName = $country.uc;
    my $lookup;

    given $commonName {
        when "ALAND ISLANDS" {
            $commonName = "Åland Islands";
        }
        when "HOLY SEE" {
            $commonName = "Vatican City";
        }
        when "NORTH KOREA" {
            $commonName = "Democratic People's Republic of Korea";
        }
        when "REPUBLIC OF CHINA" {
            $commonName = "Taiwan";
        }
        when "SAINT-BARTHELEMY" {
            $commonName = "Saint-Barthélemy";
        }
        when "SOUTH KOREA" {
            $commonName = "Republic of Korea";
        }
        when "UNITED KINGDOM" {
            $commonName = "Great Britain";
        }
        when "UNITED STATES" {
            $commonName = "AMERICA";
        }
    }
    
    my $code = searchCountryName($commonName, $codesetOut);
    
    if (!$code) {
        my $lookup = %countryXRef{$commonName.uc};
        return Any if (!$lookup);
        $code = searchCountryName($lookup, $codesetOut);
    }
    
    return $code;
}

# Some countries have longer, more convoluted names. Example:<br /> The
# Plurinational State of Bolivia. Nobody will remember a proper name like
# that. Everyone will just want to look up *Bolivia*. So to get around these
# long names the table below has the common name first, followed by a comma,
# then the rest of the name. We use this format to allow just a common name
# to be searched.
sub processComplexName($country!) {
    my @elements = $country.split(",");
    my $popularName = @elements[0].trim();
    my $rest = @elements[1].trim();
    
    %countryXRef{"$rest $popularName"} = $popularName;
    %countryXRef{$country} = $popularName;
    
    # We've upper-cased the input string remember!
    if $rest ~~ /^THE / {
        $rest ~~ s/^THE //;
        $rest = $rest.trim();
        %countryXRef{"$rest $popularName"} = $popularName;
    }

    return $popularName;
}

sub searchCountryName($country!, $codesetOut?=LOCALE_CODE_ALPHA_2) {
    given $codesetOut {
        when LOCALE_CODE_ALPHA_2 { return %countryToCode2{$country.uc}; }
        when LOCALE_CODE_ALPHA_3 { return %countryToCode3{$country.uc}; }
        when LOCALE_CODE_NUMERIC { return  %countryToCodeNum{$country.uc}; }
        when LOCALE_CODE_DOM {
            my $dom = %countryToCode2{$country.uc};
            return Any if (!$dom);
            $dom = $dom.lc;
            return ".$dom";
        }
    }
}

=finish
AD:AND:020:Andorra
AE:ARE:784:United Arab Empirates
AF:AFG:004:Afghanistan
AG:ATG:028:Antigua and Barbuda
AI:AIA:660:Anguilla
AL:ALB:008:Albania
AM:ARM:051:Armenia
AN:ANT:530:Netherlands Antilles
AO:AGO:024:Angola
AQ:ATA:010:Antarctica
AR:ARG:032:Argentina
AS:ASM:016:American Samoa
AT:AUT:040:Austria
AU:AUS:036:Australia
AW:ABW:533:Aruba
AX:ALA:248:Åland Islands
AZ:AZE:031:Azerbaijan
BA:BIH:070:Bosnia and Herzegovina
BB:BRB:052:Barbados
BD:BGD:050:Bangladesh
BE:BEL:056:Belgium
BF:BFA:854:Burkina Faso
BG:BGR:100:Bulgaria
BH:BHR:048:Bahrain
BI:BDI:108:Burundi
BJ:BEN:204:Benin
BL:BLM:652:Saint-Barthélemy
BM:BMU:060:Bermuda
BN:BRN:096:Brunei Darussalam
BO:BOL:068:Bolivia,Plurinational State of
BQ:BES:535:Bonaire
BR:BRA:076:Brazil
BS:BHS:044:Bahamas
BT:BTN:064:Bhutan
BV:BVT:074:Bouvet Island
BW:BWA:072:Botswana
BY:BLR:112:Belarus
BZ:BLZ:084:Belize
CA:CAN:124:Canada
CC:CCK:166:Cocos (Keeling) Islands
CD:COD:180:The Democratic Republic of the Congo
CF:CAF:140:Central African Republic
CG:COG:178:Congo,The Republic of
CH:CHE:756:Switzerland
CI:CIV:384:Côte d'Ivoire
CK:COK:184:Cook Islands
CL:CHL:152:Chile
CM:CMR:120:Cameroon
CN:CHN:156:China,People's Republic of
CO:COL:170:Colombia
CR:CRI:188:Costa Rica
CU:CUB:192:Cuba
CV:CPV:132:Cape Verde
CX:CXR:162:Christmas Island
CY:CYP:196:Cyprus
CZ:CZE:203:Czech Republic
DE:DEU:276:Germany
DJ:DJI:262:Djibouti
DK:DNK:208:Denmark
DM:DMA:212:Dominica
DO:DOM:214:Dominican Republic
DZ:DZA:012:Algeria
EC:ECU:218:Ecuador
EE:EST:233:Estonia
EG:EGY:818:Egypt
EH:ESH:732:Western Sahara
ER:ERI:232:Eritrea
ES:ESP:724:Spain
ET:ETH:231:Ethiopia
FI:FIN:246:Finland
FJ:FJI:242:Fiji
FM:FSM:583:Micronesia, Federated States of
FO:FRO:234:Faroe Islands
FR:FRA:250:France
GA:GAB:266:Gabon
GB:GBR:826:Great Britain
GD:GRD:308:Grenada
GE:GEO:268:Georgia
GF:GUF:254:French Guiana
GG:GGY:831:Guernsey
GH:GHA:288:Ghana
GI:GIB:292:Gibraltar
GL:GRL:304:Greenland
GM:GMB:270:Gambia
GN:GIN:324:Guinea
GP:GLP:312:Guadeloupe
GQ:GNQ:226:Equatorial Guinea
GR:GRC:300:Greece
GS:SGS:239:South Georgia and the South Sandwich Islands
GT:GTM:320:Guatemala
GU:GUM:316:Guam
GW:GNB:624:Guinea-Bissau
GY:GUY:328:Guyana
HK:HGK:344:Hong Kong
HM:HMD:334:Heard Island and Mcdonald Islands
HN:HND:340:Honduras
HR:HRV:191:Croatia
HT:HTI:332:Haiti
HU:HUN:348:Hungary
ID:IDN:360:Indonesia
IE:IRL:372:Ireland
IL:ISR:376:Israel
IM:IMN:833:Isle of Man
IN:IND:356:India
IO:IOT:086:British Ocean Territory
IQ:IRQ:368:Iraq
IR:IRN:364:Iran,Islamic Republic of
IS:ISL:352:Iceland
IT:ITA:380:Italy
JE:JEY:832:Jersey
JM:JAM:388:Jamaica
JO:JOR:400:Jordan
JP:JPN:392:Japan
KE:JEN:404:Kenya
KG:KGZ:417:Kyrgyzstan
KH:KHM:116:Cambodia
KI:KIR:296:Kiribati
KM:COM:174:Comoros
KN:KNA:659:Saint Kitts and Nevis
KP:PRK:408:Democratic People's Republic of Korea
KR:KOR:410:Korea,Republic of
KW:KWT:414:Kuwait
KY:CYM:136:Cayman Islands
KZ:KAZ:398:Kazakhstan
LA:LAO:418:Lao People's Democratic Republic
LB:LBN:422:Lebanon
LC:LCA:662:Saint Lucia
LI:LIE:438:Liechtenstein
LK:LKA:144:Sri Lanka
LR:LBR:430:Liberia
LS:LSO:426:Lesotho
LT:LTU:440:Lithuania
LU:LUX:442:Luxembourg
LV:LVA:428:Latvia
LY:LBY:434:Libya
MA:MAR:504:Morocco
MC:MCO:492:Monaco
MD:MDA:498:Moldova
ME:MNE:499:Montenegro
MG:MDG:450:Madagascar
MH:MHL:584:Marshall Islands
MK:MKD:807:Macedonia,Republic of
ML:MLI:466:Mali
MM:MMR:104:Myanmar
MN:MNG:496:Mongolia
MO:MAC:446:Macao
MP:MNP:580:Northern Mariana Islands
MQ:MTQ:474:Martinique
MR:MRT:478:Mauritania
MS:MSR:500:Montserrat
MT:MLT:470:Malta
MU:MUS:480:Mauritius
MV:MDV:462:Maldives
MW:MWI:454:Malawi
MX:MEX:484:Mexico
MY:MYS:458:Malaysia
MZ:MOZ:508:Mozambique
NA:NAM:516:Namibia
NC:NCL:540:New Caledonia
NE:NER:562:Niger
NF:NFK:574:Norfolk Island
NG:NGA:566:Nigeria
NI:NIC:558:Nicaragua
NL:NLD:528:Netherlands
NO:NOR:578:Norway
NP:NPL:524:Nepal
NR:NRU:520:Nauru
NU:NIU:570:Niue
NZ:NZL:554:New Zealand
OM:OMN:512:Oman
PA:PAN:591:Panama
PE:PER:604:Peru
PF:PYF:258:French Polynesia
PG:PNG:598:Papua New Guinea
PH:PHL:608:Philippines
PK:PAK:586:Pakistan
PL:POL:616:Poland
PM:SPM:666:Saint Pierre and Miquelon
PN:PCN:612:Pitcairn
PR:PRI:630:Puerto Rico
PS:PSE:275:Palestinan Territory
PT:PRT:620:Portugal
PW:PLW:585:Palau
PY:PRY:600:Paraguay
QA:QAT:634:Qatar
RE:REU:638:Réunion
RO:ROU:642:Romania
RS:SRB:688:Serbia
RU:RUS:643:Russian Federation
RW:RWA:646:Rwanda
SA:SAU:682:Saudi Arabia,Kingdom of
SB:SLB:090:Solomon Islands
SC:SYC:690:Seychelles
SD:SDN:736:Sudan
SE:SWE:752:Sweden
SG:SGP:702:Singapore
SH:SHN:654:Saint Helena
SI:SVN:705:Slovenia
SJ:SJM:744:Svalbard and Jan Mayen Islands
SK:SVK:703:Slovakia
SL:SLE:694:Sierra Leona
SM:SMR:674:San Marino
SN:SEN:686:Senegal
SO:SOM:706:Somalia
SR:SUR:740:Suriname
SS:SSD:728:South Sudan
ST:STP:678:Sao Tome and Principe
SV:SLV:222:El Salvador
SY:SYR:760:Syria
SZ:SWZ:748:Swaziland
TC:TCA:796:Turks and Caicos Islands
TD:TCD:148:Chad
TF:ATF:260:French Southern Territories
TG:TGO:768:Togo
TH:THA:764:Thailand
TJ:TJK:762:Tajikistan
TK:TKL:772:Tokelau
TL:TLS:626:Timor-Leste
TM:TKM:795:Turkmenistan
TN:TUN:788:Tunisia
TO:TON:776:Tonga
TR:TUR:792:Turkey
TT:TTO:780:Trinidad and Tobago
TV:TUV:798:Tuvalu
TW:TWN:158:Taiwan
TZ:TZA:834:Tanzania,United Republic of
UA:UKR:804:Ukraine
UG:UGA:800:Uganda
UM:UMI:581:United States Minor Outlying Islands
US:USA:840:America,The United States of
UY:URY:858:Uruguay
UZ:UZB:860:Uzbekistan
VA:VCT:336:Vatican City
VC:VCT:670:Saint Vincent and Grenadines
VE:VEN:862:Venezuela,Bolivarian Republic of
VG:VGB:092:British Virgin Islands
VN:VNM:704:Viet Nam
VU:VUT:548:Vanuatu
WF:WLF:876:Wallis and Futuna Islands
WS:WSM:882:Samoa
YE:YEM:887:Yemen
YT:MYT:175:Mayotte
ZA:ZAF:710:South Africa
ZM:ZMB:894:Zambia
ZW:ZWE:716:Zimbabwe