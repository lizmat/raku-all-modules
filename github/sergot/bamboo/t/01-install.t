use v6;
use Test;

use Bamboo;

# TODO: write independent test?
{
    my $path = 't';
    spurt "$path/META.info", q:to/./;
        {
            "name"      : "Bamboo-test",
            "version"   : "*",
            "author"   : "github:sergot",
            "description"   : "Perl 6 dependency manager - testing",
            "depends"   : [
                "URI"
            ],
            "provides" : {
            },
            "source-url"    : "git://github.com/sergot/bamboo.git"
        }
        .

    my $bamboo = Bamboo.new(:prefix($path), :$path);
    $bamboo.install;

    ok "$path/lib/URI".IO.d, "installs modules";

    shell("rm -rf $path/lib");
    shell("rm $path/META.info");
}

done-testing;