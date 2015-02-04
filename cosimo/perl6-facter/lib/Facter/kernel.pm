Facter.add("kernel", sub ($f) {
    $f.setcode(block => sub {
        given $*OS {
            when m:i/mswin|win32|dos|cygwin|mingw/ {
                "windows"
            }
            default {
                Facter::Util::Resolution.exec("uname -s")
            }
        }
    });
});
