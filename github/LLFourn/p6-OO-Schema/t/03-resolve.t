use Test;
use lib $?FILE.IO.parent.child("lib01").Str;

plan 6;

{
    use OS::Userland;
    is Userland.resolve(Fedora),Fedora,"resolves to itself";
    is Userland.resolve('centos'),CentOS,"lowercase";
    is Userland.resolve('OS::Userland::RHEL::Fedora'),Fedora,"Full name of to-be-loaded";
    is Userland.resolve('Darwin'),OSX,"alias";
    is Userland.resolve('darwin'),OSX,"alias lowercase";
    is Userland.resolve('xnu'),OSX,"second alias";
}
