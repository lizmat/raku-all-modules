use v6;
use Test;

use Bamboo;

# TODO: test `bamboo init`, the one from bin/ ?
{
    my $path = 't';
    my $bamboo = Bamboo.new(:prefix($path), :$path);

    my %meta =
        name => "Bamboo-test",
        version => "*",
        author => "github:sergot",
        description => "Perl 6 dependency manager - testing",
        depends => <URI>,
        provides => (),
        source-url => "git://github.com/sergot/bamboo.git"
    ;

    $bamboo.generate-meta(%meta);

    ok "$path/META.info".IO.f, "inits module";

    shell("rm $path/META.info");
}

done-testing;
