use Test;
use lib $?FILE.IO.parent.child("lib02").Str;
use Userland;

plan 2;



proto install-package(Userland:D,Str:D $pkg) {*};

multi install-package(Debian $userland,$pkg) {
    ok $userland.isa('Userland::Ubuntu'), 'Ubuntu worked';
}

multi install-package(RHEL $userland,$pkg) {
    ok $userland.isa('Userland::Fedora'), 'Fedora worked';
}


my $ubuntu = (require Userland::Ubuntu).new;
my $fedora = (require Userland::Fedora).new;

install-package($ubuntu,'ntp');
install-package($fedora,'ntp');
