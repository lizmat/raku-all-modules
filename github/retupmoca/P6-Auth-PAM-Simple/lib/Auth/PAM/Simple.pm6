#| A simple way to authenticate against your local unix PAM service.
unit module Auth::PAM::Simple;

=begin pod
Note that the only service this has been tested against  is the 'login' service.
Patches and fixes are welcome.
=end pod

=head2 Example Usage

=begin pod
    my Bool $login-valid = authenticate('login', 'retupmoca', 'xxxxxx');
=end pod

#| Calls the PAM service $service, and attempts to authenticate using the given
#| $user and $pass. Returns True for success and False for failure.
our sub authenticate($service, Str $user, Str $pass --> Bool) is export {
    return !auth($service, $user, $pass);
}

use NativeCall;
use LibraryMake;

sub library {
    my $so = get-vars('')<SO>;
    return ~(%?RESOURCES{"libauthpamsimple$so"});
}

sub auth(Str is encoded('ascii'), Str is encoded('ascii'), Str is encoded('ascii')) is native(&library) returns int32 { * };
