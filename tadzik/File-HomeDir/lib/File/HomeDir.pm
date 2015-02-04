class File::HomeDir;

method my_home {
    # Try HOME on every platform first, because even on Windows, some
    # unix-style utilities rely on the ability to overload HOME.
    return %*ENV<HOME> if %*ENV<HOME>;

    given $*OS {
        when 'MSWin32' {
            return %*ENV<HOMEDRIVE> ~ %*ENV<HOMEPATH>
        }
        when 'linux' {
            return %*ENV<HOME>
        }
    }
}
