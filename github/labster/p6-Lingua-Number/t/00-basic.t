use Lingua::Number;
use Test;

plan 16;
say "# cardinal integers";
is cardinal(3123456, 'en'), "three million one hundred twenty-three thousand four hundred fifty-six", "basically works in english";
is cardinal(3123456, 'es'), "tres millones ciento veintitrés mil cuatrocientos cincuenta y seis", "español también";
is cardinal(3123456, 'ja'), "三百十二万三千四百五十六", "also nihongo";
is cardinal(0), "zero", "zero is okay";

say "# tests with decimal points";
is cardinal(567.890, 'en'), "five hundred sixty-seven point eight nine", "english first";
is cardinal(567.890, 'es'), "quinientos sesenta y siete coma ocho nueve", "español.dos";
is cardinal(567.890, 'ja'), "五百六十七・八九", "nihongo・mitsu";

say "#ordinal numbers";
is ordinal(3123456, 'en'), "three million one hundred twenty-three thousand four hundred fifty-sixth", "english first";
is ordinal(123456, 'es'), "ciento veintitrés milésimo cuadringentésimo quincuagésimo sexto", "español segundo";
is ordinal(3123456, 'ja'), "第三百十二万三千四百五十六", "nihongo daisan";

say "#ordinal digits";
is ordinal-digits(76531, 'en'), "76,531st", "english 1st";
is ordinal-digits(76532, 'es', gender =>'f'), "76.532ª", "spanish feminine";
is ordinal-digits(76532, 'es', gender =>'M'), "76.532º", "spanish masculine";

say "# slangs";
is cardinal(1337, 'en', slang =>'verbose'), "one thousand three hundred and thirty-seven", "slangs are 1337 (verbose english)";
is ordinal(8888888888888888888, 'ja', slang =>'romaji'), "dai happyaku hachi-juu hatkei hachi-juu hachihyaku hachi-juu hatchou hachi-sen happyaku hachi-juu hachi oku hachi-sen happyaku hachi-juu hachi man hachi-sen happyaku hachi-juu hachi", 'romaji';

say "# roman numerals";
is roman-numeral(1999), "MCMXCIX", "party like it's MCMXCIX";



