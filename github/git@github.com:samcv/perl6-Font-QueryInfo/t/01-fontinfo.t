use v6.c;
use Test;
plan 71;
use lib 'lib';
use Font::QueryInfo;
my $io-path = "3rdparty/NotoSans-Bold.ttf".IO;
my %hash =
${:antialias(Bool), :aspect(0.0), :autohint(Bool),
:capability("otlayout:cyrl otlayout:grek otlayout:latn"),
:charset($(32..126, 160..879, 884..885, 890..894, 900..906, 908..908,
910..929, 931..974, 976..1319, 7424..7626, 7678..7835, 7838..7838, 7840..7929,
7936..7957, 7960..7965, 7968..8005, 8008..8013, 8016..8023, 8025..8025,
8027..8027, 8029..8029, 8031..8061, 8064..8116, 8118..8132, 8134..8147,
8150..8155, 8157..8175, 8178..8180, 8182..8190, 8192..8207, 8210..8226,
8230..8230, 8234..8240, 8242..8244, 8249..8250, 8252..8252, 8254..8254,
8260..8260, 8286..8286, 8298..8304, 8308..8313, 8319..8319, 8336..8340,
8352..8361, 8363..8373, 8377..8378, 8432..8432, 8453..8453, 8467..8467,
8470..8471, 8482..8482, 8486..8486, 8494..8494, 8525..8526, 8531..8532,
8539..8542, 8580..8580, 8592..8597, 8616..8616, 8706..8706, 8710..8710,
8719..8719, 8721..8722, 8725..8725, 8729..8730, 8734..8735, 8745..8745,
8747..8747, 8776..8776, 8800..8801, 8804..8805, 8962..8962, 8976..8976,
8992..8993, 9472..9472, 9474..9474, 9484..9484, 9488..9488, 9492..9492,
9496..9496, 9500..9500, 9508..9508, 9516..9516, 9524..9524, 9532..9532,
9552..9580, 9600..9600, 9604..9604, 9608..9608, 9612..9612, 9616..9619,
9632..9633, 9642..9644, 9650..9650, 9658..9658, 9660..9660, 9668..9668,
9674..9676, 9679..9679, 9688..9689, 9702..9702, 9786..9788, 9792..9792,
9794..9794, 9824..9824, 9827..9827, 9829..9830, 9834..9835, 9839..9839,
10741..10741, 11360..11373, 11377..11383, 11799..11799, 42775..42785,
42888..42892, 64257..64260, 65056..65059, 65279..65279, 65532..65533)),
:dpi(0.0), :embolden(Bool), :family(${"en" => "Noto Sans"}),
:file("t/NotoSans-Bold.ttf"), :fontfeatures(Str),
:fontversion(69468), :foundry("GOOG"), :ftface(Str),
:fullname(${"en" => "Noto Sans Bold"}), globaladvance => Bool, hinting => Bool,
:hintstyle(0), :index(0),:lang(set("ty","jv","ve","io","ik","hu","gl","cu",
"nr","csb","tw","cv","mn-mn","ak","wa","ia","nl","om","pt","na","hz","uk",
"haw","fo","en","ce","os","smj","kaa","gn","ff","ln","mi","zu","ga","ca",
"ay","li","to","st","da","kwm","sq","fy","fr","eu","eo","af","yo","sms",
"sco","fi","br","ch","uz","ru","ba","lb","no","kab","rm","su","ms","ku-tr",
"an","sr","fur","es","kum","nn","sc","qu","tr","is","av","tk","ss","ie","de",
"bi","lt","pl","ht","vo","so","ro","lez","nds","nv","tt","tl","gv","za","quz",
"xh","ts","tg","sv","bm","ast","kl","kw","rn","it","ho","el","lv","mt","ny",
"kr","crh","bin","mk","vi","bua","be","la","nso","tn","sw","et","az-az","mh",
"kk","aa","rw","wen","cy","cs","mo","wo","ng","fat","id","bg","fil","sel","co",
"sg","kj","ber-dz","tyv","shs","se","sah","gd","nb","sn","yap","vot","ig",
"ku-am","mg","pap-an","sl","sk","ki","fj","kv","ky","oc","pap-aw","lg","hsb",
"smn","sma","hr","ha","bs","ab","ee","sm","sh","chm")), :lcdfilter(0),
:minspace(Bool), :outline(Any), :pixelsize(0.0), :prgname(Str),
:rasterizer(Str), :rgba(0), :scalable(Any), :scale(0.0), :size(0.0),
:slant(0), :spacing(0), :style(${:en("Bold")}),
verticallayout => Bool, :weight(200), :width(100)}
;
my $CI = %*ENV<CI>.Bool;
my %response = font-query-all($io-path);
for %hash.keys {
    is %response{$_}.^name, %hash{$_}.^name, "$_ returns the same type";
    if $_ eq 'file' {
        ok %response{$_}.contains($io-path),
            "file => contains $io-path";
    }
    else {
        todo "FontConfig v2.11.91 at least needed for charset"  if $_ eq 'charset' and font-query-fc-query-version() < v2.11.91;
        todo "Travis CI is broken for some reason on this test" if $_ eq 'foundry' and $CI;
        is-deeply %response{$_}, %hash{$_}, "$_ => eqv";
    }
}
is-deeply font-query($io-path, 'name', 'fakeproperty', :no-fatal, :suppress-errors),
    ${ :fakeproperty(Str), :name(Str) },
    ":no-fatal and :suppress-errors suppress errors and doesn't die";

done-testing;