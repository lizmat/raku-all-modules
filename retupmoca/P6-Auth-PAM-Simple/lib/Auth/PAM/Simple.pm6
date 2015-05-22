unit module Auth::PAM::Simple;

our sub authenticate($service, Str $user, Str $pass --> Bool) is export {
    return !auth($service, $user, $pass);
}

use NativeCall;
use LibraryMake;

sub library {
    my $so = get-vars('')<SO>;
    my @dirs = @*INC;
    for @dirs {
        if ($_~'/Auth/PAM/libauthpamsimple'~$so).IO.r {
            return $_~'/Auth/PAM/libauthpamsimple'~$so;
        }
    }
    die "Unable to find libauthpamsimple";
}

sub auth(Str is encoded('ascii'), Str is encoded('ascii'), Str is encoded('ascii')) is native(&library) returns int32 { * };
