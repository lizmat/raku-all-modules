use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#
# Some of this is "borrowed" from https://docs.perl6.org/language/nativecall .
# I do not have copyright to that, so those portions are not subject to my
# copyright.
#

use StrictClass;
unit class Net::BGP::Socket-Linux:ver<0.0.9>:auth<cpan:JMASLAK>
    does StrictClass;

use NativeCall;
use NativeHelpers::Blob;
use Net::BGP::IP;
use Net::BGP::Socket-Connection-Linux;

my Bool $supports-md5;

enum States (
    SOCKET_CLOSED    => 0;
    SOCKET_CREATED   => 1;
    SOCKET_BOUND     => 2;
);

#
# Public attributes
#
has int32    $.socket-fd;
has Str:D    $.my-host    is rw is required;
has Int:D    $.my-port    is rw is required;
has Int      $.bound-port;
has States:D $.state      is rw = SOCKET_CLOSED;
has Str:D    %!md5;

# Supported Domains (Address Families)
enum AddrInfo-Family (
    AF_UNSPEC                   => 0;
    AF_SOCKET                   => 1;
    AF_INET                     => 2;
    AF_INET6                    => 10;
);

enum IP-Protocols (
    IPPROTO_TCP                => 6;
);

constant \INET_ADDRSTRLEN  = 16;
constant \INET6_ADDRSTRLEN = 46;
 
enum AddrInfo-Socktype (
    SOCK_STREAM                 => 1;
    SOCK_DGRAM                  => 2;
    SOCK_RAW                    => 3;
    SOCK_RDM                    => 4;
    SOCK_SEQPACKET              => 5;
    SOCK_DCCP                   => 6;
    SOCK_PACKET                 => 10;
);
 
enum AddrInfo-Flags (
    AI_PASSIVE                  => 0x0001;
    AI_CANONNAME                => 0x0002;
    AI_NUMERICHOST              => 0x0004;
    AI_V4MAPPED                 => 0x0008;
    AI_ALL                      => 0x0010;
    AI_ADDRCONFIG               => 0x0020;
    AI_IDN                      => 0x0040;
    AI_CANONIDN                 => 0x0080;
    AI_IDN_ALLOW_UNASSIGNED     => 0x0100;
    AI_IDN_USE_STD3_ASCII_RULES => 0x0200;
    AI_NUMERICSERV              => 0x0400;
);
 
class SockAddr is repr('CStruct') {
    has uint16 $.sa_family  is rw;
    has uint16 $.sa_port    is rw;
    has uint32 $.sa_addr1a  is rw;
    has uint64 $.sa_addr2   is rw;
    has uint64 $.sa_addr3   is rw;
    has uint32 $.sa_addr4a  is rw;
    has uint32 $.sa_addr4b  is rw;
    has uint64 $.sa_addr5   is rw;
    has uint64 $.sa_addr6   is rw;
    has uint64 $.sa_addr7   is rw;
    has uint64 $.sa_addr8   is rw;
    has uint64 $.sa_addr9   is rw;
    has uint64 $.sa_addr10  is rw;
    has uint64 $.sa_addr11  is rw;
    has uint64 $.sa_addr12  is rw;
    has uint64 $.sa_addr13  is rw;
    has uint64 $.sa_addr14  is rw;
    has uint64 $.sa_addr15  is rw;
    has uint64 $.sa_addr16  is rw;
}

class SockAddr-in is repr('CStruct') {
    has int16 $.sin_family is rw;
    has uint16 $.sin_port  is rw;
    has uint32 $.sin_addr  is rw;
 
    method address {
        my $buf = buf8.allocate(INET_ADDRSTRLEN);
        inet_ntop(AF_INET, Pointer.new(nativecast(Pointer,self)+4),
            $buf, INET_ADDRSTRLEN)
    }

    method port {
        return ntohs($.sin_port);
    }
}
 
class SockAddr-in6 is repr('CStruct') {
    has uint16 $.sin6_family    is rw;
    has uint16 $.sin6_port      is rw;
    has uint32 $.sin6_flowinfo  is rw;
    has uint64 $.sin6_addr0     is rw;
    has uint64 $.sin6_addr1     is rw;
    has uint32 $.sin6_scope_id  is rw;
 
    method address {
        my $buf = buf8.allocate(INET6_ADDRSTRLEN);
        inet_ntop(AF_INET6, Pointer.new(nativecast(Pointer,self)+8),
            $buf, INET6_ADDRSTRLEN)
    }

    method port {
        return ntohs($.sin6_port);
    }
}

class SockAddr-any is repr('CUnion') {
    HAS SockAddr-in  $.in;
    HAS SockAddr-in6 $.in6;
    HAS SockAddr     $.sock;

    method family(-->UInt) {
        return $!in.sin_family;
    }
}
 
class Addrinfo is repr('CStruct') {
    has int32         $.ai_flags;
    has int32         $.ai_family;
    has int32         $.ai_socktype;
    has int32         $.ai_protocol;
    has int32         $.ai_addrlen;
    has SockAddr-any  $.ai_addr       is rw;
    has Str           $.ai_cannonname is rw;
    has Addrinfo      $.ai_next       is rw;
}

# socket(domain, type, protocol)
my sub native-socket(int32, int32, int32 -->int32) is native is symbol('socket') { * }

method socket(-->Int) {
    if $!state ≠ SOCKET_CLOSED { die "Socket in improper state" }

    my $addrinfo = self.getaddrinfo($!my-host, $!my-port);
    my $family = $addrinfo.ai_family;
    self.freeaddrinfo($addrinfo);

    my $sockfd = native-socket($family, SOCK_STREAM, 0);
    if $sockfd == -1 { die("Could not create socket") };

    $!socket-fd = $sockfd;
    $!state     = SOCKET_CREATED;
    
    return $sockfd;
}

# bind(sockfd, *addr, addrlen)
my sub native-bind(int32, SockAddr-any is rw, int32 -->int32) is native is symbol('bind') { * }

method bind(-->Nil) {
    if $!state ≠ SOCKET_CREATED { die "Socket in improper state" }

    my $addrinfo = self.getaddrinfo($!my-host, $!my-port);

    my $size;
   if $addrinfo.ai_family == AF_INET {
        $size = INET_ADDRSTRLEN;
    } elsif $addrinfo.ai_family == AF_INET6 {
        $size = INET6_ADDRSTRLEN;
    } else {
        self.freeaddrinfo($addrinfo);
        die("Unknown address family");
    } 
    my $result = native-bind($!socket-fd, $addrinfo.ai_addr, $size);
    self.freeaddrinfo($addrinfo);

    if $result { die("Could not bind") }

    $!state = SOCKET_BOUND;

    for %!md5.keys -> $md5host { self.set-md5($md5host, %!md5{ $md5host }) }
}

sub native-getaddrinfo(
    Str $node,
    Str $service,
    Addrinfo $hints,
    Pointer $res is rw
    --> int32
) is native is symbol('getaddrinfo') {*};

### XXX We're only looking at the FIRST addr in ADDRFAMILY. We should do
### better than that.

# Get AddressInfo
method getaddrinfo(Str:D $host, Int:D $port, -->Addrinfo) {
    my Addrinfo $hint .= new(:ai_socktype(SOCK_STREAM), :ai_flags(AI_ADDRCONFIG));
    my Pointer  $res  .= new;

    my $rv = native-getaddrinfo($host, ~$port, $hint, $res);
    if $rv {
        native-freeaddrinfo($res);
        die("getaddrinfo() failed");
    }

    return nativecast(Addrinfo, $res);
}

my sub native-freeaddrinfo(Pointer) is native is symbol('freeaddrinfo') {*};
method freeaddrinfo(Addrinfo $addr) {
    native-freeaddrinfo( nativecast(Pointer, $addr) );
}

# sockfd, sockaddr * addr, addrlen
sub native-getsockname(
    int32,
    Pointer,
    int32 is rw
    -->int32
) is native is symbol('getsockname') {*}

# Gets bound port
method find-bound-port(-->Int) {
    if $!state ≠ SOCKET_BOUND {
        die "Socket in improper state";
    }

    # Port number is in the same location for both IPv4 and IPv6
    my SockAddr-in6 $addr = SockAddr-in6.new;
    my int32 $len = INET6_ADDRSTRLEN;

    my $rv = native-getsockname($!socket-fd, nativecast(Pointer, $addr), $len);
    my $var := cglobal('libc.so.6', 'errno', int32);
    if $rv { die("getsockname failed - $var") }

    return $addr.port;
}

# listen(sockfd, backlog)
sub native-listen(int32, int32) is native is symbol('listen') {*}

method listen(-->Nil) {
    if $!state ≠ SOCKET_BOUND { die "Socket in improper state ( $!state )" }

    my $rv = native-listen($!socket-fd, 64);
    if $rv { die("listen() failed") }

    $!bound-port = self.find-bound-port;
}

# connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
sub native-connect(int32, SockAddr-any is rw, int32 -->int32) is native is symbol('connect') {*}

### XXX We're only looking at the FIRST addr in ADDRFAMILY. We should do
### better than that.

method connect(Str:D $host, Int:D $port where ^(2¹⁶) -->Promise:D) {
    my $addrinfo = self.getaddrinfo($host, $port);
    my $size   = $addrinfo.ai_addrlen;
    my $family = $addrinfo.ai_family;

    if $!state == SOCKET_CLOSED {
        my $sockfd = native-socket($family, SOCK_STREAM, 0);
        if $sockfd == -1 { die("Could not create socket") };

        $!socket-fd = $sockfd;
        $!state     = SOCKET_CREATED;
    } elsif $!state == SOCKET_CREATED {
        # Do nothing here.
    } else {
        die "Socket in improper state";
    }

    # Set up MD5 keys
    if %!md5{ $host.fc }:exists {
        self.set-md5($host.fc, %!md5{ $host.fc });
    }

    my $promise = Promise.new;

    start {
        my $rv = native-connect($!socket-fd, $addrinfo.ai_addr, $size);
        self.freeaddrinfo($addrinfo);
        if $rv {
            $promise.break("Could not connect ($rv)");
        } else {
            $!state = SOCKET_BOUND;
            my $conn = Net::BGP::Socket-Connection-Linux.new(
                :my-host($!my-host),
                :my-port(self.find-bound-port),
                :peer-port($port),
                :peer-host($host),
                :peer-family($addrinfo.ai_family),
                :socket-fd($!socket-fd),
            );
            
            $promise.keep($conn);
        }
    }

    return $promise;
}


# accept(int32 sockfd, struct sockaddr *addr, socketlen_t *addrlen,
#        socketlen_t * addrlen)
sub native-accept(
    int32, 
    SockAddr-any is rw,
    int32 is rw 
    -->int32
) is native is symbol('accept') {*}

# Start accepting connections
# XXX Check out leaving informatin, quit when appropriate.
method acceptor(-->Supply:D) {
    if $!state ≠ SOCKET_BOUND { die "Socket in improper state" }

    my $supplier = Supplier::Preserving.new;
    my $supply   = $supplier.Supply;

    my SockAddr-any $sockaddr = SockAddr-any.new;
    my int32 $len = INET6_ADDRSTRLEN;

    start loop {
        my $rv = native-accept($!socket-fd, $sockaddr, $len);
        if $rv < 0 {
            # $supplier.quit("accept returned error");
            last;
        }

        my $addr;
        if $sockaddr.in.sin_family == AF_INET {
            $addr = $sockaddr.in;
        } elsif $sockaddr.in.sin_family == AF_INET6 {
            $addr = $sockaddr.in6;
        } else {
            # $supplier.quit("Unknown address family");
            last;
        }

        my $conn = Net::BGP::Socket-Connection-Linux.new(
            :my-host($!my-host),
            :my-port(self.bound-port),
            :peer-port($addr.port),
            :peer-host($addr.address),
            :peer-family($sockaddr.in.sin_family),
            :socket-fd($rv),
        );

        $supplier.emit($conn);

        CATCH {
            default {
                # $supplier.quit($_);
            }
        }
    }

    return $supply;
}

# close(int)
sub native-close(int32 -->int32) is native is symbol('close') {*}

method close(-->Nil) {
    if $!state == SOCKET_CLOSED {
        die("Socket is not closable");
    }

    my $rv = native-close($!socket-fd);
    if $rv { die("close failed") }

    $!socket-fd = 0;
    $!state     = SOCKET_CLOSED;
}

sub inet_ntop(int32, Pointer, Blob, int32 --> Str) is native {*}

# Conversions
sub ntohs(uint16 -->uint16) is native {*} 
sub ntohl(uint32 -->uint32) is native {*} 
sub htons(uint16 -->uint16) is native {*} 
sub htonl(uint32 -->uint32) is native {*} 

constant \TCP_MD5SIG_MAXKEYLEN = 80;

enum TCP-Socket-Options (
    TCP_MD5SIG => 14;
);

enum Socket-Options (
    SO_REUSEADDR => 2;
);

enum TCP-MD5-Flags (
    TCP_MD5SIG_FLAG_PREFIX => 0x01;
);

# bcopy(void *dest, void *src, size_t n)
sub bcopy(Pointer, Pointer, int32) is native {*};

# MD5 Signature Support
class TCP-MD5-Sig {
    has Str            $.tcpm_key;
    has SockAddr-any:D $.tcpm_addr      is rw = SockAddr-any.new;
    has uint8          $.tcpm_flags     is rw;
    has uint8          $.tcpm_prefixlen is rw;
    # has Str:D          $.tcpm_key       is rw where { $^s.chars ≤ 80 } = '';

    method Pointer(-->Pointer) {
        my $blob = CArray[uint8].allocate(216);  # Structure is 216 bytes long

        # 0-127
        if $!tcpm_addr.sock.sa_family == AF_INET {

            # 8 bytes
            my $a = blob-from-pointer(
                nativecast(Pointer, $!tcpm_addr),
                :elems(8),
                :type(buf8)
            );

            for ^8 -> $i { $blob[$i] = $a[$i] }

        } elsif $!tcpm_addr.sock.sa_family == AF_INET6 {

            # 32 bytes
            my $a = blob-from-pointer(
                nativecast(Pointer, $!tcpm_addr),
                :elems(32),
                :type(buf8)
            );

            for ^32 -> $i { $blob[$i] = $a[$i] }

        } else {
            die("Could not convert from address family");
        }

        $blob[128] = $!tcpm_flags;
        $blob[129] = $!tcpm_prefixlen;
        
        # 130-131 Keylen
        my $reorder = htons($!tcpm_key.chars); # Swap bytes if needed
        $blob[130] = ($reorder / 256).truncate;
        $blob[131] = ($reorder % 256);

        # 132-135 PAD

        # 136-215 Key
        for ^80 -> $i {
            if $i < $!tcpm_key.chars {
                $blob[136+$i] = $!tcpm_key.comb[$i].ord;
            }
        }

        return pointer-to($blob);
    }
}

# setsockopt(int sockfd, int level, int optname, void *optval, int optlen)
# sub native-setsockopt(int32, int32, int32, Pointer, int32 is rw -->int32)
sub native-setsockopt(int32, int32, int32, Pointer, int32 -->int32)
    is native is symbol('setsockopt') {*}

method add-md5(Str:D $host, Str $MD5) {
    %!md5{$host.fc} = $MD5;
}

method set-md5(Str:D $host, Str $MD5, Int $prefix-len? -->Nil) {
    if $!state == SOCKET_CLOSED { die "Socket in improper state" }

    if $MD5.chars > 80 { die("MD5 password must be ≤ 80 characters") }

    my $md5 = TCP-MD5-Sig.new(:tcpm_key($MD5));
    my $addrinfo = self.getaddrinfo($host, 0);

    $md5.tcpm_addr.sock.sa_family = $addrinfo.ai_addr.sock.sa_family;
    $md5.tcpm_addr.sock.sa_port   = $addrinfo.ai_addr.sock.sa_port;

    if $addrinfo.ai_addr.family == AF_INET {
        $md5.tcpm_addr.in.sin_addr       = $addrinfo.ai_addr.in.sin_addr;
    } elsif $addrinfo.ai_addr.family == AF_INET6 {
        $md5.tcpm_addr.in6.sin6_flowinfo = $addrinfo.ai_addr.in6.sin6_flowinfo;
        $md5.tcpm_addr.in6.sin6_addr0    = $addrinfo.ai_addr.in6.sin6_addr0;
        $md5.tcpm_addr.in6.sin6_addr1    = $addrinfo.ai_addr.in6.sin6_addr1;
        $md5.tcpm_addr.in6.sin6_scope_id = $addrinfo.ai_addr.in6.sin6_scope_id;
    } else {
        self.freeaddrinfo($addrinfo);
        die("Unknown address type");
    }
    self.freeaddrinfo($addrinfo);

    $md5.tcpm_flags     = 0;
    $md5.tcpm_prefixlen = 0;

    if $prefix-len.defined {
        $md5.flags          = $md5.flags +| TCP_MD5SIG_FLAG_PREFIX;
        $md5.tcpm_prefixlen = $prefix-len;
    }

    my $var := cglobal('libc.so.6', 'errno', int32);

    my int32 $size = 216;
    my $rv = native-setsockopt(
        $!socket-fd,
        IPPROTO_TCP,
        TCP_MD5SIG,
        $md5.Pointer,
        $size
    );
    if $rv { die("Could not set MD5 socket option - $var"); }
}

method set-reuseaddr(-->Nil) {
    if $!state ≠ SOCKET_CREATED {
        die "Socket in improper state";
    }

    my $blob = CArray[uint8].allocate(4);
    $blob[0] = $blob[1] = $blob[2] = 0;
    $blob[3] = 1;
    my int32 $size = 4;

    my $rv = native-setsockopt(
        $!socket-fd,
        AF_SOCKET,
        SO_REUSEADDR,
        pointer-to($blob),
        $size,
    );
    if $rv { die("Could not set SO_REUSE socket option"); }
}

method supports-md5(-->Bool:D) {
    my $inet = Net::BGP::Socket-Linux.new(:my-host('127.0.0.1'), :my-port(0));
    my $sock = $inet.socket;
    $inet.bind;
    {
        $inet.set-md5('192.0.2.0', 'key key key');
        CATCH {
            default {
                $inet.close;
                $supports-md5 = False;
                return False;
            }
        }
    }
    $inet.close;

    $supports-md5 = True;
    return True;
}

submethod DESTROY {
    if self.state ≠ SOCKET_CLOSED { self.close }
    CATCH {
        default { }
    }
}

