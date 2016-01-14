use OO::Schema;

role APT { }

schema Userland is path('OS::Userland') {

    node Windows {
        node XP { }

        node WindowsServer {

        }
    }

    node POSIX {
        node BSD {
            node FreeBSD { }
            node OpenBSD { }
        }

        node GNU {
            node Debian does APT {
                node Ubuntu { }
            }
            node RHEL is path is load-from('OS::Userland::RedHat') {
                node Fedora { }
                node CentOS { }
            }
        }
    }
}
