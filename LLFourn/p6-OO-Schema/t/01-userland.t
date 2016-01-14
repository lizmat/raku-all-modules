use Test;
use lib $?FILE.IO.parent.child("lib01").Str;

plan 23;

{
    use OS::Userland;
    say '# isa tests';
    ok Ubuntu ~~ Debian;
    ok Ubuntu ~~ Ubuntu;
    ok Ubuntu ~~ POSIX;
    ok Ubuntu ~~ Userland;
    dies-ok { Ubuntu.new }, "nodes cannot be instantiated";
}

{
     use-ok 'OS::Userland::POSIX';
}

{
    use OS::Userland;
    use OS::Userland::Ubuntu;
    use OS::Userland::Kubuntu;
    my \u = Userland::Ubuntu;
    my \ku = Userland::Kubuntu;
    say '# inst isa tests';

    for u,ku {
        for (Ubuntu,Debian,POSIX,Userland) -> $ul {
            pass "{.^name} isa {$ul.^name}" when $ul
        }
    }

    ok ku !~~ u, "sibiling nodes don't inherit";
    ok u  ~~ APT,"role applied to {u.gist}";
    ok ku ~~ APT,"role applied to {ku.gist}";
}

{
    use OS::Userland::Ubuntu;
    use OS::Userland::Debian;
    use OS::Userland::POSIX;
    my \u = Userland::Ubuntu;
    my \p1 = Userland::Debian;
    my \p2 = Userland::POSIX;
    ok u ~~ p1,'isa Userland::Debian';
    ok u ~~ p2,'isa Userland::POSIX';
}

{
    use OS::Userland;
    my $class = Fedora.load-class;
    ok $class.isa('Userland::RHEL::Fedora');
    ok $class ~~ RHEL;
    ok $class.isa('Userland::RedHat'),'load-from';
    ok $class.new.test eq 'win', "can create instance";
}
