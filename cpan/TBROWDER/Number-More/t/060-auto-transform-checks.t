use Test;

use Number::More :ALL;

plan 456;

my $debug = 0;

my $suffix = True;

is rebase(642, 10, 3), "212210", "base 3; test 1";
is rebase("1010000010", 2, 3), "212210", "base 3; test 2";
is rebase("1202", 8, 3), "212210", "base 3; test 3";
is rebase("282", 16, 3), "212210", "base 3; test 4";

# add the suffix
is rebase(642, 10, 3, :$suffix), "212210_base-3", "base 3; test 5";
is rebase("1010000010", 2, 3, :$suffix), "212210_base-3", "base 3; test 6";
is rebase("1202", 8, 3, :$suffix), "212210_base-3", "base 3; test 7";
is rebase("282", 16, 3, :$suffix), "212210_base-3", "base 3; test 8";

is rebase(3612, 10, 4), "320130", "base 4; test 9";
is rebase("111000011100", 2, 4), "320130", "base 4; test 10";
is rebase("7034", 8, 4), "320130", "base 4; test 11";
is rebase("E1C", 16, 4), "320130", "base 4; test 12";

# add the suffix
is rebase(3612, 10, 4, :$suffix), "320130_base-4", "base 4; test 13";
is rebase("111000011100", 2, 4, :$suffix), "320130_base-4", "base 4; test 14";
is rebase("7034", 8, 4, :$suffix), "320130_base-4", "base 4; test 15";
is rebase("E1C", 16, 4, :$suffix), "320130_base-4", "base 4; test 16";

is rebase(2832, 10, 5), "42312", "base 5; test 17";
is rebase("101100010000", 2, 5), "42312", "base 5; test 18";
is rebase("5420", 8, 5), "42312", "base 5; test 19";
is rebase("B10", 16, 5), "42312", "base 5; test 20";

# add the suffix
is rebase(2832, 10, 5, :$suffix), "42312_base-5", "base 5; test 21";
is rebase("101100010000", 2, 5, :$suffix), "42312_base-5", "base 5; test 22";
is rebase("5420", 8, 5, :$suffix), "42312_base-5", "base 5; test 23";
is rebase("B10", 16, 5, :$suffix), "42312_base-5", "base 5; test 24";

is rebase(5735, 10, 6), "42315", "base 6; test 25";
is rebase("1011001100111", 2, 6), "42315", "base 6; test 26";
is rebase("13147", 8, 6), "42315", "base 6; test 27";
is rebase("1667", 16, 6), "42315", "base 6; test 28";

# add the suffix
is rebase(5735, 10, 6, :$suffix), "42315_base-6", "base 6; test 29";
is rebase("1011001100111", 2, 6, :$suffix), "42315_base-6", "base 6; test 30";
is rebase("13147", 8, 6, :$suffix), "42315_base-6", "base 6; test 31";
is rebase("1667", 16, 6, :$suffix), "42315_base-6", "base 6; test 32";

is rebase(15251, 10, 7), "62315", "base 7; test 33";
is rebase("11101110010011", 2, 7), "62315", "base 7; test 34";
is rebase("35623", 8, 7), "62315", "base 7; test 35";
is rebase("3B93", 16, 7), "62315", "base 7; test 36";

# add the suffix
is rebase(15251, 10, 7, :$suffix), "62315_base-7", "base 7; test 37";
is rebase("11101110010011", 2, 7, :$suffix), "62315_base-7", "base 7; test 38";
is rebase("35623", 8, 7, :$suffix), "62315_base-7", "base 7; test 39";
is rebase("3B93", 16, 7, :$suffix), "62315_base-7", "base 7; test 40";

is rebase(4615, 10, 9), "6287", "base 9; test 41";
is rebase("1001000000111", 2, 9), "6287", "base 9; test 42";
is rebase("11007", 8, 9), "6287", "base 9; test 43";
is rebase("1207", 16, 9), "6287", "base 9; test 44";

# add the suffix
is rebase(4615, 10, 9, :$suffix), "6287_base-9", "base 9; test 45";
is rebase("1001000000111", 2, 9, :$suffix), "6287_base-9", "base 9; test 46";
is rebase("11007", 8, 9, :$suffix), "6287_base-9", "base 9; test 47";
is rebase("1207", 16, 9, :$suffix), "6287_base-9", "base 9; test 48";

is rebase(13396, 10, 11), "A079", "base 11; test 49";
is rebase("11010001010100", 2, 11), "A079", "base 11; test 50";
is rebase("32124", 8, 11), "A079", "base 11; test 51";
is rebase("3454", 16, 11), "A079", "base 11; test 52";

# add the suffix
is rebase(13396, 10, 11, :$suffix), "A079_base-11", "base 11; test 53";
is rebase("11010001010100", 2, 11, :$suffix), "A079_base-11", "base 11; test 54";
is rebase("32124", 8, 11, :$suffix), "A079_base-11", "base 11; test 55";
is rebase("3454", 16, 11, :$suffix), "A079_base-11", "base 11; test 56";

is rebase(17375, 10, 12), "A07B", "base 12; test 57";
is rebase("100001111011111", 2, 12), "A07B", "base 12; test 58";
is rebase("41737", 8, 12), "A07B", "base 12; test 59";
is rebase("43DF", 16, 12), "A07B", "base 12; test 60";

# add the suffix
is rebase(17375, 10, 12, :$suffix), "A07B_base-12", "base 12; test 61";
is rebase("100001111011111", 2, 12, :$suffix), "A07B_base-12", "base 12; test 62";
is rebase("41737", 8, 12, :$suffix), "A07B_base-12", "base 12; test 63";
is rebase("43DF", 16, 12, :$suffix), "A07B_base-12", "base 12; test 64";

is rebase(1975, 10, 13), "B8C", "base 13; test 65";
is rebase("11110110111", 2, 13), "B8C", "base 13; test 66";
is rebase("3667", 8, 13), "B8C", "base 13; test 67";
is rebase("7B7", 16, 13), "B8C", "base 13; test 68";

# add the suffix
is rebase(1975, 10, 13, :$suffix), "B8C_base-13", "base 13; test 69";
is rebase("11110110111", 2, 13, :$suffix), "B8C_base-13", "base 13; test 70";
is rebase("3667", 8, 13, :$suffix), "B8C_base-13", "base 13; test 71";
is rebase("7B7", 16, 13, :$suffix), "B8C_base-13", "base 13; test 72";

is rebase(34290, 10, 14), "C6D4", "base 14; test 73";
is rebase("1000010111110010", 2, 14), "C6D4", "base 14; test 74";
is rebase("102762", 8, 14), "C6D4", "base 14; test 75";
is rebase("85F2", 16, 14), "C6D4", "base 14; test 76";

# add the suffix
is rebase(34290, 10, 14, :$suffix), "C6D4_base-14", "base 14; test 77";
is rebase("1000010111110010", 2, 14, :$suffix), "C6D4_base-14", "base 14; test 78";
is rebase("102762", 8, 14, :$suffix), "C6D4_base-14", "base 14; test 79";
is rebase("85F2", 16, 14, :$suffix), "C6D4_base-14", "base 14; test 80";

is rebase(49562, 10, 15), "EA42", "base 15; test 81";
is rebase("1100000110011010", 2, 15), "EA42", "base 15; test 82";
is rebase("140632", 8, 15), "EA42", "base 15; test 83";
is rebase("C19A", 16, 15), "EA42", "base 15; test 84";

# add the suffix
is rebase(49562, 10, 15, :$suffix), "EA42_base-15", "base 15; test 85";
is rebase("1100000110011010", 2, 15, :$suffix), "EA42_base-15", "base 15; test 86";
is rebase("140632", 8, 15, :$suffix), "EA42_base-15", "base 15; test 87";
is rebase("C19A", 16, 15, :$suffix), "EA42_base-15", "base 15; test 88";

is rebase(71464, 10, 17), "E94D", "base 17; test 89";
is rebase("10001011100101000", 2, 17), "E94D", "base 17; test 90";
is rebase("213450", 8, 17), "E94D", "base 17; test 91";
is rebase("11728", 16, 17), "E94D", "base 17; test 92";

# add the suffix
is rebase(71464, 10, 17, :$suffix), "E94D_base-17", "base 17; test 93";
is rebase("10001011100101000", 2, 17, :$suffix), "E94D_base-17", "base 17; test 94";
is rebase("213450", 8, 17, :$suffix), "E94D_base-17", "base 17; test 95";
is rebase("11728", 16, 17, :$suffix), "E94D_base-17", "base 17; test 96";

is rebase(96573, 10, 18), "GA13", "base 18; test 97";
is rebase("10111100100111101", 2, 18), "GA13", "base 18; test 98";
is rebase("274475", 8, 18), "GA13", "base 18; test 99";
is rebase("1793D", 16, 18), "GA13", "base 18; test 100";

# add the suffix
is rebase(96573, 10, 18, :$suffix), "GA13_base-18", "base 18; test 101";
is rebase("10111100100111101", 2, 18, :$suffix), "GA13_base-18", "base 18; test 102";
is rebase("274475", 8, 18, :$suffix), "GA13_base-18", "base 18; test 103";
is rebase("1793D", 16, 18, :$suffix), "GA13_base-18", "base 18; test 104";

is rebase(6355, 10, 19), "HB9", "base 19; test 105";
is rebase("1100011010011", 2, 19), "HB9", "base 19; test 106";
is rebase("14323", 8, 19), "HB9", "base 19; test 107";
is rebase("18D3", 16, 19), "HB9", "base 19; test 108";

# add the suffix
is rebase(6355, 10, 19, :$suffix), "HB9_base-19", "base 19; test 109";
is rebase("1100011010011", 2, 19, :$suffix), "HB9_base-19", "base 19; test 110";
is rebase("14323", 8, 19, :$suffix), "HB9_base-19", "base 19; test 111";
is rebase("18D3", 16, 19, :$suffix), "HB9_base-19", "base 19; test 112";

is rebase(148847, 10, 20), "IC27", "base 20; test 113";
is rebase("100100010101101111", 2, 20), "IC27", "base 20; test 114";
is rebase("442557", 8, 20), "IC27", "base 20; test 115";
is rebase("2456F", 16, 20), "IC27", "base 20; test 116";

# add the suffix
is rebase(148847, 10, 20, :$suffix), "IC27_base-20", "base 20; test 117";
is rebase("100100010101101111", 2, 20, :$suffix), "IC27_base-20", "base 20; test 118";
is rebase("442557", 8, 20, :$suffix), "IC27_base-20", "base 20; test 119";
is rebase("2456F", 16, 20, :$suffix), "IC27_base-20", "base 20; test 120";

is rebase(7878, 10, 21), "HI3", "base 21; test 121";
is rebase("1111011000110", 2, 21), "HI3", "base 21; test 122";
is rebase("17306", 8, 21), "HI3", "base 21; test 123";
is rebase("1EC6", 16, 21), "HI3", "base 21; test 124";

# add the suffix
is rebase(7878, 10, 21, :$suffix), "HI3_base-21", "base 21; test 125";
is rebase("1111011000110", 2, 21, :$suffix), "HI3_base-21", "base 21; test 126";
is rebase("17306", 8, 21, :$suffix), "HI3_base-21", "base 21; test 127";
is rebase("1EC6", 16, 21, :$suffix), "HI3_base-21", "base 21; test 128";

is rebase(9531, 10, 22), "JF5", "base 22; test 129";
is rebase("10010100111011", 2, 22), "JF5", "base 22; test 130";
is rebase("22473", 8, 22), "JF5", "base 22; test 131";
is rebase("253B", 16, 22), "JF5", "base 22; test 132";

# add the suffix
is rebase(9531, 10, 22, :$suffix), "JF5_base-22", "base 22; test 133";
is rebase("10010100111011", 2, 22, :$suffix), "JF5_base-22", "base 22; test 134";
is rebase("22473", 8, 22, :$suffix), "JF5_base-22", "base 22; test 135";
is rebase("253B", 16, 22, :$suffix), "JF5_base-22", "base 22; test 136";

is rebase(11004, 10, 23), "KIA", "base 23; test 137";
is rebase("10101011111100", 2, 23), "KIA", "base 23; test 138";
is rebase("25374", 8, 23), "KIA", "base 23; test 139";
is rebase("2AFC", 16, 23), "KIA", "base 23; test 140";

# add the suffix
is rebase(11004, 10, 23, :$suffix), "KIA_base-23", "base 23; test 141";
is rebase("10101011111100", 2, 23, :$suffix), "KIA_base-23", "base 23; test 142";
is rebase("25374", 8, 23, :$suffix), "KIA_base-23", "base 23; test 143";
is rebase("2AFC", 16, 23, :$suffix), "KIA_base-23", "base 23; test 144";

is rebase(150633, 10, 24), "ALC9", "base 24; test 145";
is rebase("100100110001101001", 2, 24), "ALC9", "base 24; test 146";
is rebase("446151", 8, 24), "ALC9", "base 24; test 147";
is rebase("24C69", 16, 24), "ALC9", "base 24; test 148";

# add the suffix
is rebase(150633, 10, 24, :$suffix), "ALC9_base-24", "base 24; test 149";
is rebase("100100110001101001", 2, 24, :$suffix), "ALC9_base-24", "base 24; test 150";
is rebase("446151", 8, 24, :$suffix), "ALC9_base-24", "base 24; test 151";
is rebase("24C69", 16, 24, :$suffix), "ALC9_base-24", "base 24; test 152";

is rebase(355546, 10, 25), "MILL", "base 25; test 153";
is rebase("1010110110011011010", 2, 25), "MILL", "base 25; test 154";
is rebase("1266332", 8, 25), "MILL", "base 25; test 155";
is rebase("56CDA", 16, 25), "MILL", "base 25; test 156";

# add the suffix
is rebase(355546, 10, 25, :$suffix), "MILL_base-25", "base 25; test 157";
is rebase("1010110110011011010", 2, 25, :$suffix), "MILL_base-25", "base 25; test 158";
is rebase("1266332", 8, 25, :$suffix), "MILL_base-25", "base 25; test 159";
is rebase("56CDA", 16, 25, :$suffix), "MILL_base-25", "base 25; test 160";

is rebase(15259, 10, 26), "MEN", "base 26; test 161";
is rebase("11101110011011", 2, 26), "MEN", "base 26; test 162";
is rebase("35633", 8, 26), "MEN", "base 26; test 163";
is rebase("3B9B", 16, 26), "MEN", "base 26; test 164";

# add the suffix
is rebase(15259, 10, 26, :$suffix), "MEN_base-26", "base 26; test 165";
is rebase("11101110011011", 2, 26, :$suffix), "MEN_base-26", "base 26; test 166";
is rebase("35633", 8, 26, :$suffix), "MEN_base-26", "base 26; test 167";
is rebase("3B9B", 16, 26, :$suffix), "MEN_base-26", "base 26; test 168";

is rebase(16332, 10, 27), "MAO", "base 27; test 169";
is rebase("11111111001100", 2, 27), "MAO", "base 27; test 170";
is rebase("37714", 8, 27), "MAO", "base 27; test 171";
is rebase("3FCC", 16, 27), "MAO", "base 27; test 172";

# add the suffix
is rebase(16332, 10, 27, :$suffix), "MAO_base-27", "base 27; test 173";
is rebase("11111111001100", 2, 27, :$suffix), "MAO_base-27", "base 27; test 174";
is rebase("37714", 8, 27, :$suffix), "MAO_base-27", "base 27; test 175";
is rebase("3FCC", 16, 27, :$suffix), "MAO_base-27", "base 27; test 176";

is rebase(19901, 10, 28), "PAL", "base 28; test 177";
is rebase("100110110111101", 2, 28), "PAL", "base 28; test 178";
is rebase("46675", 8, 28), "PAL", "base 28; test 179";
is rebase("4DBD", 16, 28), "PAL", "base 28; test 180";

# add the suffix
is rebase(19901, 10, 28, :$suffix), "PAL_base-28", "base 28; test 181";
is rebase("100110110111101", 2, 28, :$suffix), "PAL_base-28", "base 28; test 182";
is rebase("46675", 8, 28, :$suffix), "PAL_base-28", "base 28; test 183";
is rebase("4DBD", 16, 28, :$suffix), "PAL_base-28", "base 28; test 184";

is rebase(21997, 10, 29), "Q4F", "base 29; test 185";
is rebase("101010111101101", 2, 29), "Q4F", "base 29; test 186";
is rebase("52755", 8, 29), "Q4F", "base 29; test 187";
is rebase("55ED", 16, 29), "Q4F", "base 29; test 188";

# add the suffix
is rebase(21997, 10, 29, :$suffix), "Q4F_base-29", "base 29; test 189";
is rebase("101010111101101", 2, 29, :$suffix), "Q4F_base-29", "base 29; test 190";
is rebase("52755", 8, 29, :$suffix), "Q4F_base-29", "base 29; test 191";
is rebase("55ED", 16, 29, :$suffix), "Q4F_base-29", "base 29; test 192";

is rebase(24613, 10, 30), "RAD", "base 30; test 193";
is rebase("110000000100101", 2, 30), "RAD", "base 30; test 194";
is rebase("60045", 8, 30), "RAD", "base 30; test 195";
is rebase("6025", 16, 30), "RAD", "base 30; test 196";

# add the suffix
is rebase(24613, 10, 30, :$suffix), "RAD_base-30", "base 30; test 197";
is rebase("110000000100101", 2, 30, :$suffix), "RAD_base-30", "base 30; test 198";
is rebase("60045", 8, 30, :$suffix), "RAD_base-30", "base 30; test 199";
is rebase("6025", 16, 30, :$suffix), "RAD_base-30", "base 30; test 200";

is rebase(27355, 10, 31), "SED", "base 31; test 201";
is rebase("110101011011011", 2, 31), "SED", "base 31; test 202";
is rebase("65333", 8, 31), "SED", "base 31; test 203";
is rebase("6ADB", 16, 31), "SED", "base 31; test 204";

# add the suffix
is rebase(27355, 10, 31, :$suffix), "SED_base-31", "base 31; test 205";
is rebase("110101011011011", 2, 31, :$suffix), "SED_base-31", "base 31; test 206";
is rebase("65333", 8, 31, :$suffix), "SED_base-31", "base 31; test 207";
is rebase("6ADB", 16, 31, :$suffix), "SED_base-31", "base 31; test 208";

is rebase(30027, 10, 32), "TAB", "base 32; test 209";
is rebase("111010101001011", 2, 32), "TAB", "base 32; test 210";
is rebase("72513", 8, 32), "TAB", "base 32; test 211";
is rebase("754B", 16, 32), "TAB", "base 32; test 212";

# add the suffix
is rebase(30027, 10, 32, :$suffix), "TAB_base-32", "base 32; test 213";
is rebase("111010101001011", 2, 32, :$suffix), "TAB_base-32", "base 32; test 214";
is rebase("72513", 8, 32, :$suffix), "TAB_base-32", "base 32; test 215";
is rebase("754B", 16, 32, :$suffix), "TAB_base-32", "base 32; test 216";

is rebase(33011, 10, 33), "UAB", "base 33; test 217";
is rebase("1000000011110011", 2, 33), "UAB", "base 33; test 218";
is rebase("100363", 8, 33), "UAB", "base 33; test 219";
is rebase("80F3", 16, 33), "UAB", "base 33; test 220";

# add the suffix
is rebase(33011, 10, 33, :$suffix), "UAB_base-33", "base 33; test 221";
is rebase("1000000011110011", 2, 33, :$suffix), "UAB_base-33", "base 33; test 222";
is rebase("100363", 8, 33, :$suffix), "UAB_base-33", "base 33; test 223";
is rebase("80F3", 16, 33, :$suffix), "UAB_base-33", "base 33; test 224";

is rebase(37837, 10, 34), "WOT", "base 34; test 225";
is rebase("1001001111001101", 2, 34), "WOT", "base 34; test 226";
is rebase("111715", 8, 34), "WOT", "base 34; test 227";
is rebase("93CD", 16, 34), "WOT", "base 34; test 228";

# add the suffix
is rebase(37837, 10, 34, :$suffix), "WOT_base-34", "base 34; test 229";
is rebase("1001001111001101", 2, 34, :$suffix), "WOT_base-34", "base 34; test 230";
is rebase("111715", 8, 34, :$suffix), "WOT_base-34", "base 34; test 231";
is rebase("93CD", 16, 34, :$suffix), "WOT_base-34", "base 34; test 232";

is rebase(42520, 10, 35), "YOU", "base 35; test 233";
is rebase("1010011000011000", 2, 35), "YOU", "base 35; test 234";
is rebase("123030", 8, 35), "YOU", "base 35; test 235";
is rebase("A618", 16, 35), "YOU", "base 35; test 236";

# add the suffix
is rebase(42520, 10, 35, :$suffix), "YOU_base-35", "base 35; test 237";
is rebase("1010011000011000", 2, 35, :$suffix), "YOU_base-35", "base 35; test 238";
is rebase("123030", 8, 35, :$suffix), "YOU_base-35", "base 35; test 239";
is rebase("A618", 16, 35, :$suffix), "YOU_base-35", "base 35; test 240";

is rebase(44027, 10, 36), "XYZ", "base 36; test 241";
is rebase("1010101111111011", 2, 36), "XYZ", "base 36; test 242";
is rebase("125773", 8, 36), "XYZ", "base 36; test 243";
is rebase("ABFB", 16, 36), "XYZ", "base 36; test 244";

# add the suffix
is rebase(44027, 10, 36, :$suffix), "XYZ_base-36", "base 36; test 245";
is rebase("1010101111111011", 2, 36, :$suffix), "XYZ_base-36", "base 36; test 246";
is rebase("125773", 8, 36, :$suffix), "XYZ_base-36", "base 36; test 247";
is rebase("ABFB", 16, 36, :$suffix), "XYZ_base-36", "base 36; test 248";

is rebase(49258, 10, 37), "ZaB", "base 37; test 249";
is rebase("1100000001101010", 2, 37), "ZaB", "base 37; test 250";
is rebase("140152", 8, 37), "ZaB", "base 37; test 251";
is rebase("C06A", 16, 37), "ZaB", "base 37; test 252";

# add the suffix
is rebase(49258, 10, 37, :$suffix), "ZaB_base-37", "base 37; test 253";
is rebase("1100000001101010", 2, 37, :$suffix), "ZaB_base-37", "base 37; test 254";
is rebase("140152", 8, 37, :$suffix), "ZaB_base-37", "base 37; test 255";
is rebase("C06A", 16, 37, :$suffix), "ZaB_base-37", "base 37; test 256";

is rebase(23065, 10, 38), "Fab", "base 38; test 257";
is rebase("101101000011001", 2, 38), "Fab", "base 38; test 258";
is rebase("55031", 8, 38), "Fab", "base 38; test 259";
is rebase("5A19", 16, 38), "Fab", "base 38; test 260";

# add the suffix
is rebase(23065, 10, 38, :$suffix), "Fab_base-38", "base 38; test 261";
is rebase("101101000011001", 2, 38, :$suffix), "Fab_base-38", "base 38; test 262";
is rebase("55031", 8, 38, :$suffix), "Fab_base-38", "base 38; test 263";
is rebase("5A19", 16, 38, :$suffix), "Fab_base-38", "base 38; test 264";

is rebase(58217, 10, 39), "cAT", "base 39; test 265";
is rebase("1110001101101001", 2, 39), "cAT", "base 39; test 266";
is rebase("161551", 8, 39), "cAT", "base 39; test 267";
is rebase("E369", 16, 39), "cAT", "base 39; test 268";

# add the suffix
is rebase(58217, 10, 39, :$suffix), "cAT_base-39", "base 39; test 269";
is rebase("1110001101101001", 2, 39, :$suffix), "cAT_base-39", "base 39; test 270";
is rebase("161551", 8, 39, :$suffix), "cAT_base-39", "base 39; test 271";
is rebase("E369", 16, 39, :$suffix), "cAT_base-39", "base 39; test 272";

is rebase(63377, 10, 40), "dOH", "base 40; test 273";
is rebase("1111011110010001", 2, 40), "dOH", "base 40; test 274";
is rebase("173621", 8, 40), "dOH", "base 40; test 275";
is rebase("F791", 16, 40), "dOH", "base 40; test 276";

# add the suffix
is rebase(63377, 10, 40, :$suffix), "dOH_base-40", "base 40; test 277";
is rebase("1111011110010001", 2, 40, :$suffix), "dOH_base-40", "base 40; test 278";
is rebase("173621", 8, 40, :$suffix), "dOH_base-40", "base 40; test 279";
is rebase("F791", 16, 40, :$suffix), "dOH_base-40", "base 40; test 280";

is rebase(58823, 10, 41), "YeT", "base 41; test 281";
is rebase("1110010111000111", 2, 41), "YeT", "base 41; test 282";
is rebase("162707", 8, 41), "YeT", "base 41; test 283";
is rebase("E5C7", 16, 41), "YeT", "base 41; test 284";

# add the suffix
is rebase(58823, 10, 41, :$suffix), "YeT_base-41", "base 41; test 285";
is rebase("1110010111000111", 2, 41, :$suffix), "YeT_base-41", "base 41; test 286";
is rebase("162707", 8, 41, :$suffix), "YeT_base-41", "base 41; test 287";
is rebase("E5C7", 16, 41, :$suffix), "YeT_base-41", "base 41; test 288";

is rebase(48257, 10, 42), "REf", "base 42; test 289";
is rebase("1011110010000001", 2, 42), "REf", "base 42; test 290";
is rebase("136201", 8, 42), "REf", "base 42; test 291";
is rebase("BC81", 16, 42), "REf", "base 42; test 292";

# add the suffix
is rebase(48257, 10, 42, :$suffix), "REf_base-42", "base 42; test 293";
is rebase("1011110010000001", 2, 42, :$suffix), "REf_base-42", "base 42; test 294";
is rebase("136201", 8, 42, :$suffix), "REf_base-42", "base 42; test 295";
is rebase("BC81", 16, 42, :$suffix), "REf_base-42", "base 42; test 296";

is rebase(27708, 10, 43), "EgG", "base 43; test 297";
is rebase("110110000111100", 2, 43), "EgG", "base 43; test 298";
is rebase("66074", 8, 43), "EgG", "base 43; test 299";
is rebase("6C3C", 16, 43), "EgG", "base 43; test 300";

# add the suffix
is rebase(27708, 10, 43, :$suffix), "EgG_base-43", "base 43; test 301";
is rebase("110110000111100", 2, 43, :$suffix), "EgG_base-43", "base 43; test 302";
is rebase("66074", 8, 43, :$suffix), "EgG_base-43", "base 43; test 303";
is rebase("6C3C", 16, 43, :$suffix), "EgG_base-43", "base 43; test 304";

is rebase(71616, 10, 44), "ahS", "base 44; test 305";
is rebase("10001011111000000", 2, 44), "ahS", "base 44; test 306";
is rebase("213700", 8, 44), "ahS", "base 44; test 307";
is rebase("117C0", 16, 44), "ahS", "base 44; test 308";

# add the suffix
is rebase(71616, 10, 44, :$suffix), "ahS_base-44", "base 44; test 309";
is rebase("10001011111000000", 2, 44, :$suffix), "ahS_base-44", "base 44; test 310";
is rebase("213700", 8, 44, :$suffix), "ahS_base-44", "base 44; test 311";
is rebase("117C0", 16, 44, :$suffix), "ahS_base-44", "base 44; test 312";

is rebase(89654, 10, 45), "iCE", "base 45; test 313";
is rebase("10101111000110110", 2, 45), "iCE", "base 45; test 314";
is rebase("257066", 8, 45), "iCE", "base 45; test 315";
is rebase("15E36", 16, 45), "iCE", "base 45; test 316";

# add the suffix
is rebase(89654, 10, 45, :$suffix), "iCE_base-45", "base 45; test 317";
is rebase("10101111000110110", 2, 45, :$suffix), "iCE_base-45", "base 45; test 318";
is rebase("257066", 8, 45, :$suffix), "iCE_base-45", "base 45; test 319";
is rebase("15E36", 16, 45, :$suffix), "iCE_base-45", "base 45; test 320";

is rebase(57637, 10, 46), "RAj", "base 46; test 321";
is rebase("1110000100100101", 2, 46), "RAj", "base 46; test 322";
is rebase("160445", 8, 46), "RAj", "base 46; test 323";
is rebase("E125", 16, 46), "RAj", "base 46; test 324";

# add the suffix
is rebase(57637, 10, 46, :$suffix), "RAj_base-46", "base 46; test 325";
is rebase("1110000100100101", 2, 46, :$suffix), "RAj_base-46", "base 46; test 326";
is rebase("160445", 8, 46, :$suffix), "RAj_base-46", "base 46; test 327";
is rebase("E125", 16, 46, :$suffix), "RAj_base-46", "base 46; test 328";

is rebase(40231, 10, 47), "I9k", "base 47; test 329";
is rebase("1001110100100111", 2, 47), "I9k", "base 47; test 330";
is rebase("116447", 8, 47), "I9k", "base 47; test 331";
is rebase("9D27", 16, 47), "I9k", "base 47; test 332";

# add the suffix
is rebase(40231, 10, 47, :$suffix), "I9k_base-47", "base 47; test 333";
is rebase("1001110100100111", 2, 47, :$suffix), "I9k_base-47", "base 47; test 334";
is rebase("116447", 8, 47, :$suffix), "I9k_base-47", "base 47; test 335";
is rebase("9D27", 16, 47, :$suffix), "I9k_base-47", "base 47; test 336";

is rebase(25314, 10, 48), "AlI", "base 48; test 337";
is rebase("110001011100010", 2, 48), "AlI", "base 48; test 338";
is rebase("61342", 8, 48), "AlI", "base 48; test 339";
is rebase("62E2", 16, 48), "AlI", "base 48; test 340";

# add the suffix
is rebase(25314, 10, 48, :$suffix), "AlI_base-48", "base 48; test 341";
is rebase("110001011100010", 2, 48, :$suffix), "AlI_base-48", "base 48; test 342";
is rebase("61342", 8, 48, :$suffix), "AlI_base-48", "base 48; test 343";
is rebase("62E2", 16, 48, :$suffix), "AlI_base-48", "base 48; test 344";

is rebase(115248, 10, 49), "m00", "base 49; test 345";
is rebase("11100001000110000", 2, 49), "m00", "base 49; test 346";
is rebase("341060", 8, 49), "m00", "base 49; test 347";
is rebase("1C230", 16, 49), "m00", "base 49; test 348";

# add the suffix
is rebase(115248, 10, 49, :$suffix), "m00_base-49", "base 49; test 349";
is rebase("11100001000110000", 2, 49, :$suffix), "m00_base-49", "base 49; test 350";
is rebase("341060", 8, 49, :$suffix), "m00_base-49", "base 49; test 351";
is rebase("1C230", 16, 49, :$suffix), "m00_base-49", "base 49; test 352";

is rebase(2649, 10, 50), "12n", "base 50; test 353";
is rebase("101001011001", 2, 50), "12n", "base 50; test 354";
is rebase("5131", 8, 50), "12n", "base 50; test 355";
is rebase("A59", 16, 50), "12n", "base 50; test 356";

# add the suffix
is rebase(2649, 10, 50, :$suffix), "12n_base-50", "base 50; test 357";
is rebase("101001011001", 2, 50, :$suffix), "12n_base-50", "base 50; test 358";
is rebase("5131", 8, 50, :$suffix), "12n_base-50", "base 50; test 359";
is rebase("A59", 16, 50, :$suffix), "12n_base-50", "base 50; test 360";

is rebase(130589, 10, 51), "oAT", "base 51; test 361";
is rebase("11111111000011101", 2, 51), "oAT", "base 51; test 362";
is rebase("377035", 8, 51), "oAT", "base 51; test 363";
is rebase("1FE1D", 16, 51), "oAT", "base 51; test 364";

# add the suffix
is rebase(130589, 10, 51, :$suffix), "oAT_base-51", "base 51; test 365";
is rebase("11111111000011101", 2, 51, :$suffix), "oAT_base-51", "base 51; test 366";
is rebase("377035", 8, 51, :$suffix), "oAT_base-51", "base 51; test 367";
is rebase("1FE1D", 16, 51, :$suffix), "oAT_base-51", "base 51; test 368";

is rebase(29706, 10, 52), "ApE", "base 52; test 369";
is rebase("111010000001010", 2, 52), "ApE", "base 52; test 370";
is rebase("72012", 8, 52), "ApE", "base 52; test 371";
is rebase("740A", 16, 52), "ApE", "base 52; test 372";

# add the suffix
is rebase(29706, 10, 52, :$suffix), "ApE_base-52", "base 52; test 373";
is rebase("111010000001010", 2, 52, :$suffix), "ApE_base-52", "base 52; test 374";
is rebase("72012", 8, 52, :$suffix), "ApE_base-52", "base 52; test 375";
is rebase("740A", 16, 52, :$suffix), "ApE_base-52", "base 52; test 376";

is rebase(6041, 10, 53), "27q", "base 53; test 377";
is rebase("1011110011001", 2, 53), "27q", "base 53; test 378";
is rebase("13631", 8, 53), "27q", "base 53; test 379";
is rebase("1799", 16, 53), "27q", "base 53; test 380";

# add the suffix
is rebase(6041, 10, 53, :$suffix), "27q_base-53", "base 53; test 381";
is rebase("1011110011001", 2, 53, :$suffix), "27q_base-53", "base 53; test 382";
is rebase("13631", 8, 53, :$suffix), "27q_base-53", "base 53; test 383";
is rebase("1799", 16, 53, :$suffix), "27q_base-53", "base 53; test 384";

is rebase(72880, 10, 54), "OrY", "base 54; test 385";
is rebase("10001110010110000", 2, 54), "OrY", "base 54; test 386";
is rebase("216260", 8, 54), "OrY", "base 54; test 387";
is rebase("11CB0", 16, 54), "OrY", "base 54; test 388";

# add the suffix
is rebase(72880, 10, 54, :$suffix), "OrY_base-54", "base 54; test 389";
is rebase("10001110010110000", 2, 54, :$suffix), "OrY_base-54", "base 54; test 390";
is rebase("216260", 8, 54, :$suffix), "OrY_base-54", "base 54; test 391";
is rebase("11CB0", 16, 54, :$suffix), "OrY_base-54", "base 54; test 392";

is rebase(43944, 10, 55), "ESs", "base 55; test 393";
is rebase("1010101110101000", 2, 55), "ESs", "base 55; test 394";
is rebase("125650", 8, 55), "ESs", "base 55; test 395";
is rebase("ABA8", 16, 55), "ESs", "base 55; test 396";

# add the suffix
is rebase(43944, 10, 55, :$suffix), "ESs_base-55", "base 55; test 397";
is rebase("1010101110101000", 2, 55, :$suffix), "ESs_base-55", "base 55; test 398";
is rebase("125650", 8, 55, :$suffix), "ESs_base-55", "base 55; test 399";
is rebase("ABA8", 16, 55, :$suffix), "ESs_base-55", "base 55; test 400";

is rebase(9911, 10, 56), "38t", "base 56; test 401";
is rebase("10011010110111", 2, 56), "38t", "base 56; test 402";
is rebase("23267", 8, 56), "38t", "base 56; test 403";
is rebase("26B7", 16, 56), "38t", "base 56; test 404";

# add the suffix
is rebase(9911, 10, 56, :$suffix), "38t_base-56", "base 56; test 405";
is rebase("10011010110111", 2, 56, :$suffix), "38t_base-56", "base 56; test 406";
is rebase("23267", 8, 56, :$suffix), "38t_base-56", "base 56; test 407";
is rebase("26B7", 16, 56, :$suffix), "38t_base-56", "base 56; test 408";

is rebase(13337, 10, 57), "45u", "base 57; test 409";
is rebase("11010000011001", 2, 57), "45u", "base 57; test 410";
is rebase("32031", 8, 57), "45u", "base 57; test 411";
is rebase("3419", 16, 57), "45u", "base 57; test 412";

# add the suffix
is rebase(13337, 10, 57, :$suffix), "45u_base-57", "base 57; test 413";
is rebase("11010000011001", 2, 57, :$suffix), "45u_base-57", "base 57; test 414";
is rebase("32031", 8, 57, :$suffix), "45u_base-57", "base 57; test 415";
is rebase("3419", 16, 57, :$suffix), "45u_base-57", "base 57; test 416";

is rebase(3769, 10, 58), "16v", "base 58; test 417";
is rebase("111010111001", 2, 58), "16v", "base 58; test 418";
is rebase("7271", 8, 58), "16v", "base 58; test 419";
is rebase("EB9", 16, 58), "16v", "base 58; test 420";

# add the suffix
is rebase(3769, 10, 58, :$suffix), "16v_base-58", "base 58; test 421";
is rebase("111010111001", 2, 58, :$suffix), "16v_base-58", "base 58; test 422";
is rebase("7271", 8, 58, :$suffix), "16v_base-58", "base 58; test 423";
is rebase("EB9", 16, 58, :$suffix), "16v_base-58", "base 58; test 424";

is rebase(52170, 10, 59), "EwE", "base 59; test 425";
is rebase("1100101111001010", 2, 59), "EwE", "base 59; test 426";
is rebase("145712", 8, 59), "EwE", "base 59; test 427";
is rebase("CBCA", 16, 59), "EwE", "base 59; test 428";

# add the suffix
is rebase(52170, 10, 59, :$suffix), "EwE_base-59", "base 59; test 429";
is rebase("1100101111001010", 2, 59, :$suffix), "EwE_base-59", "base 59; test 430";
is rebase("145712", 8, 59, :$suffix), "EwE_base-59", "base 59; test 431";
is rebase("CBCA", 16, 59, :$suffix), "EwE_base-59", "base 59; test 432";

is rebase(115442, 10, 60), "W42", "base 60; test 433";
is rebase("11100001011110010", 2, 60), "W42", "base 60; test 434";
is rebase("341362", 8, 60), "W42", "base 60; test 435";
is rebase("1C2F2", 16, 60), "W42", "base 60; test 436";

# add the suffix
is rebase(115442, 10, 60, :$suffix), "W42_base-60", "base 60; test 437";
is rebase("11100001011110010", 2, 60, :$suffix), "W42_base-60", "base 60; test 438";
is rebase("341362", 8, 60, :$suffix), "W42_base-60", "base 60; test 439";
is rebase("1C2F2", 16, 60, :$suffix), "W42_base-60", "base 60; test 440";

is rebase(19812, 10, 61), "5Jm", "base 61; test 441";
is rebase("100110101100100", 2, 61), "5Jm", "base 61; test 442";
is rebase("46544", 8, 61), "5Jm", "base 61; test 443";
is rebase("4D64", 16, 61), "5Jm", "base 61; test 444";

# add the suffix
is rebase(19812, 10, 61, :$suffix), "5Jm_base-61", "base 61; test 445";
is rebase("100110101100100", 2, 61, :$suffix), "5Jm_base-61", "base 61; test 446";
is rebase("46544", 8, 61, :$suffix), "5Jm_base-61", "base 61; test 447";
is rebase("4D64", 16, 61, :$suffix), "5Jm_base-61", "base 61; test 448";

is rebase(8480244, 10, 62), "Za68", "base 62; test 449";
is rebase("100000010110010111110100", 2, 62), "Za68", "base 62; test 450";
is rebase("40262764", 8, 62), "Za68", "base 62; test 451";
is rebase("8165F4", 16, 62), "Za68", "base 62; test 452";

# add the suffix
is rebase(8480244, 10, 62, :$suffix), "Za68_base-62", "base 62; test 453";
is rebase("100000010110010111110100", 2, 62, :$suffix), "Za68_base-62", "base 62; test 454";
is rebase("40262764", 8, 62, :$suffix), "Za68_base-62", "base 62; test 455";
is rebase("8165F4", 16, 62, :$suffix), "Za68_base-62", "base 62; test 456";
