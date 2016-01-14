use OO::Schema;

schema Userland {

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
            node Debian {
                node Ubuntu { }
            }
            node RHEL {
                node Fedora { }
                node CentOS { }
            }
        }
    }
}
