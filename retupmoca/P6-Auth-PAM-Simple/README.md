P6-Auth-PAM-Simple
==================

This is a simple way to authenticate against your local unix PAM service.

Note that the only service this has been tested against (and the only one I use)
is the 'login' service. Patches and fixes are welcome - this module is just a quick
"I need this" build.

## Example Usage ##

    my Bool $login-valid = authenticate('login', 'retupmoca', 'xxxxxx');

## Functions ##

 -  `authenticate(Str $service, Str $login, Str $password --> Bool)`

    Calls the PAM service $service, and attempts to authenticate using the given
    $login and $password. Returns True for success and False for failure.
