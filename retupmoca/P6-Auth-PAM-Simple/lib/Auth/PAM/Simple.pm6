module Auth::PAM::Simple;

our sub authenticate($service, Str $user, Str $pass --> Bool) is export {
    return !auth($service, $user, $pass);
}

use NativeCall;
use LibraryMake;

sub library {
    my $so = get-vars('')<SO>;
    my @dirs = @*INC;
    for @dirs {
        if ($_~'/Auth/PAM/libauthpamsimple'~$so).path.r {
            return $_~'/Auth/PAM/libauthpamsimple'~$so;
        }
    }
    die "Unable to find libauthpamsimple";
}

sub auth(Str is encoded('ascii'), Str is encoded('ascii'), Str is encoded('ascii')) returns int32 { * };
# we set the libname here because we need it to happen at runtime, not compiletime
trait_mod:<is>(&auth, :native(library));

