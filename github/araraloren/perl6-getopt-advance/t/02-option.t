
use Test;
use Getopt::Advance;
use Getopt::Advance::Option;

my OptionSet $optset .= new;

$optset.push("h|help=b");
$optset.push("v|version=b", "print program version.");
$optset.push(" |end=s", value => '@@CODEEND');
$optset.push("M|main=s", value => 'int main(void)', callback => &checkMain);
$optset.push("f|flag=a", "compile flag", value => [ "std=c++11", ]);
$optset.push("c|compile=s", "compile", value => 'g++', callback => &checkCompile);
$optset.push("os=h", "operator system executable extension", value => %(win32 => 'exe'));
$optset.push("quite=b/");
$optset.push("d2|debug2=b", "open debug mode 2");
$optset.append("p|print=b;d|debug=b");
$optset.append("i|include=a" => "include c/cpp header", "I=a" => "include search path");
$optset.append("S=b" => "pass -S", "E=b" => "pass -E", :radio);
$optset.append("f|flag=a;l|link=a;D|DEFINE=a;", :multi);
$optset.append("O0|=b;O1|=b;O2|=b;O3|=b;Os|=b;Ow=b;", :radio);
$optset.append("e=a;r=b", :radio, :!optional);
$optset.set-value("f", "Wall");
$optset.set-annotation("help", "print this help message");

getopt(
    [
        "--help",
        "-v",
        "--end", '@@END',
        "--compile", "clang",
        "-M", "int main(int argc, char* argv[])",
        "--os", ':linux(exe)',
        "-S",
        "--/quite",
        "-O1",
        "-f", "Wextra",
        "-l", "m",
        "-e", 'printf("hello world");',
        "-d2"
    ],
    $optset,
    :!strict
);

ok $optset.has("O1"), "has O1 option";
ok $optset{"O2"}:exists, "has O2 option";
ok $optset{"Ow"}:exists, "has O2 option";
ok $optset.remove("Ow"), "remove Ow option";
nok $optset{"Ow"}:exists, "removed O2 option";
ok $optset{<help v>}:exists, "has help and v";
ok $optset{'help'}, "set help option ok";
ok $optset.get('h').value, "set help option ok";
ok [&&] $optset{<help v>}, "help and version all set";
is $optset.get("h").annotation, "print this help message";
ok "Wall" (elem) $optset<f>, "set value ok";
ok $optset{"d2"}, "set debug mode2 ok";

sub checkMain($self, $a) {
    ok $self === $optset.get("main"), "same option";
    is $a, "int main(int argc, char* argv[])";
}

sub checkCompile($self, $a) {
    ok $self === $optset.get("compile"), "same option";
    is $a, "clang";
}

done-testing();
