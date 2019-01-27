NAME
====

Native::Exec -- NativeCall bindings for Unix exec*() calls

SYNOPSIS
========

    use Native::Exec;

    # Default searches PATH for executable
    exec 'echo', 'hi';

    # Specify :nopath to avoid PATH searching
    exec :nopath, '/bin/echo', 'hi';

    # Override ENV entirely by passing in named params
    exec 'env', HOME => '/my/home', PATH => '/bin:/usr/bin';

DESCRIPTION
===========

Very basic wrapper around NativeCall bindings for the Unix `execv`(), `execve`(), `execvp`(), and `execvpe`() Unix calls.

`exec` defaults to the 'p' variants that search your PATH for the specified executable. If you include the `:nopath` option, it will use the non 'p' variants and avoid the PATH search. You can also include a '/' in your specified executable and that will also avoid the PATH search within the `exec*` routines.

Including any named parameters OTHER THAN `:nopath` will build a new environment for the `exec`ed program, replacing the existing environment entirely, using the 'e' variants.

EXCEPTIONS
==========

`exec` does NOT return. On success, the `exec`ed program will replace your Perl 6 program entirely. If there are any errors, such as not finding the specified program, it will throw `X::Native::Exec` with the native error code. You can access the native error code with `.errno`, and the native error message with `.message`.

    exec 'non-existant';

    CATCH {
        when X::Native::Exec {
          say "Native Error Code: ", .errno;
          say "Native Error Message: ", .message;
        }
    }

NOTE
====

The `exec`* family are Unix specific, and are unlikely to work on other architectures.

