unit module Locale::Codes::Script_Codes;

my $data = q{
Adlm:166:Adlam
Afak:439:Afaka
Aghb:239:Caucasian Albanian
Ahom::Ahom
Arab:160:Arabic
Aran:161:Arabic (Nastaliq variant)
Armi:124:Imperial Aramaic
Armn:230:Armenian
Avst:134:Avestan
Bali:360:Balinese
Bamu:435:Bamum
Bass:259:Bassa Vah
Batk:365:Batak
Beng:325:Bengali
Bhks:334:Bhaiksuki
Blis:550:Blissymbols
Bopo:285:Bopomofo
Brah:300:Brahmi
Brai:570:Braille
Bugi:367:Buginese
Buhd:372:Buhid
Cakm:349:Chakma
Cans:440:Unified Canadian Aboriginal Syllabics
Cari:201:Carian
Cham:358:Cham
Cher:445:Cherokee
Cirt:291:Cirth
Copt:204:Coptic
Cprt:403:Cypriot
Cyrl:220:Cyrillic
Cyrs:221:Cyrillic (Old Church Slavonic variant)
Deva::Devanagari
Dsrt::Deseret
Dupl::Duployan shorthand
Egyd:070:Egyptian demotic
Egyh:060:Egyptian hieratic
Egyp:050:Egyptian hieroglyphs
Elba:226:Elbasan
Ethi::Ethiopic
Geok:241:Khutsuri (Asomtavruli and Nuskhuri)
Geor:240:Georgian (Mkhedruli)
Glag:225:Glagolitic
Goth:206:Gothic
Gran:343:Grantha
Grek:200:Greek
Gujr:320:Gujarati
Guru:310:Gurmukhi
Hang::Hangul
Hani::Han
Hano::Hanunoo
Hans:501:Han (Simplified variant)
Hant:502:Han (Traditional variant)
Hatr:127:Hatran
Hebr:125:Hebrew
Hira:410:Hiragana
Hluw::Anatolian Hieroglyphs
Hmng:450:Pahawh Hmong
Hrkt:412:Japanese syllabaries (alias for Hiragana + Katakana)
Hung::Old Hungarian
Inds::Indus
Ital:210:Old Italic (Etruscan, Oscan, etc.)
Java:361:Javanese
Jpan:413:Japanese (alias for Han + Hiragana + Katakana)
Jurc:510:Jurchen
Kali:357:Kayah Li
Kana:411:Katakana
Khar:305:Kharoshthi
Khmr:355:Khmer
Khoj:322:Khojki
Kitl:505:Khitan large script
Kits:288:Khitan small script
Knda:345:Kannada
Kore:287:Korean (alias for Hangul + Han)
Kpel:436:Kpelle
Kthi:317:Kaithi
Lana::Tai Tham
Laoo:356:Lao
Latf:217:Latin (Fraktur variant)
Latg:216:Latin (Gaelic variant)
Latn:215:Latin
Leke:364:Leke
Lepc::Lepcha
Limb:336:Limbu
Lina:400:Linear A
Linb:401:Linear B
Lisu::Lisu
Loma:437:Loma
Lyci:202:Lycian
Lydi:116:Lydian
Mahj:314:Mahajani
Mand::Mandaic
Mani:139:Manichaean
Marc:332:Marchen
Maya:090:Mayan hieroglyphs
Mend:438:Mende Kikakui
Merc:101:Meroitic Cursive
Mero:100:Meroitic Hieroglyphs
Mlym:347:Malayalam
Modi::Modi
Mong:145:Mongolian
Moon::Moon
Mroo::Mro
Mtei::Meitei Mayek
Mult:323:Multani
Mymr::Myanmar
Narb::Old North Arabian
Nbat:159:Nabataean
Nkgb::Nakhi Geba
Nkoo:165:N'Ko
Nshu:499:Nushu
Ogam:212:Ogham
Olck::Ol Chiki
Orkh::Old Turkic
Orya:327:Oriya
Osge:219:Osage
Osma:260:Osmanya
Palm:126:Palmyrene
Pauc:263:Pau Cin Hau
Perm:227:Old Permic
Phag:331:Phags-pa
Phli:131:Inscriptional Pahlavi
Phlp:132:Psalter Pahlavi
Phlv:133:Book Pahlavi
Phnx:115:Phoenician
Plrd::Miao
Prti:130:Inscriptional Parthian
Qaaa:900:Reserved for private use (start)
Qabx:949:Reserved for private use (end)
Rjng::Rejang
Roro:620:Rongorongo
Runr:211:Runic
Samr:123:Samaritan
Sara:292:Sarati
Sarb:105:Old South Arabian
Saur:344:Saurashtra
Sgnw:095:SignWriting
Shaw::Shavian
Shrd::Sharada
Sidd::Siddham
Sind::Khudawadi
Sinh:348:Sinhala
Sora:398:Sora Sompeng
Sund:362:Sundanese
Sylo:316:Syloti Nagri
Syrc:135:Syriac
Syre:138:Syriac (Estrangelo variant)
Syrj:137:Syriac (Western variant)
Syrn:136:Syriac (Eastern variant)
Tagb:373:Tagbanwa
Takr::Takri
Tale:353:Tai Le
Talu:354:New Tai Lue
Taml:346:Tamil
Tang:520:Tangut
Tavt:359:Tai Viet
Telu:340:Telugu
Teng:290:Tengwar
Tfng::Tifinagh
Tglg::Tagalog
Thaa:170:Thaana
Thai:352:Thai
Tibt:330:Tibetan
Tirh:326:Tirhuta
Ugar:040:Ugaritic
Vaii:470:Vai
Visp:280:Visible Speech
Wara::Warang Citi
Wole:480:Woleai
Xpeo:030:Old Persian
Xsux::Sumero-Akkadian cuneiform
Yiii:460:Yi
Zinh:994:Code for inherited script
Zmth:995:Mathematical notation
Zsym:996:Symbols
};

our %data;
for $data.trim.split("\n") -> $line {
    my @parts = $line.split(':');
    %data<code><alpha>{@parts[0]} = @parts[2];
    %data<code><num>{@parts[1]} = @parts[2] if @parts[1].chars;
    %data<name><alpha>{lc @parts[2]} = @parts[0];
    %data<name><num>{lc @parts[2]} = @parts[1] if @parts[1].chars;
}

