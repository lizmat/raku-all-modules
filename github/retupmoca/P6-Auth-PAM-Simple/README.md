module Auth::PAM::Simple
------------------------

A simple way to authenticate against your local unix PAM service.

Note that the only service this has been tested against is the 'login' service. Patches and fixes are welcome.

Example Usage
-------------

    my Bool $login-valid = authenticate('login', 'retupmoca', 'xxxxxx');

### sub authenticate

```
sub authenticate(
    $service, 
    Str $user, 
    Str $pass
) returns Bool
```

Calls the PAM service $service, and attempts to authenticate using the given $user and $pass. Returns True for success and False for failure.
