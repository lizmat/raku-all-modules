use v6.c;
use NativeCall;
use X::NativeCall::Errno;

module NativeCall::Errno {
    sub errno-location(--> Pointer[int]) is native is symbol($*KERNEL eq 'darwin' ?? '__error' !! '__errno_location') {*}

    #| C<errno> returns the value of C<errno> of the calling thread as
    #| documented by L<man:errno(3)>.
    sub errno(--> X::NativeCall::Errno:D) is export {
        X::NativeCall::Errno.new(code => errno-location.deref);
    }

    constant E2BIG = X::NativeCall::Errno.new(code => 7);
    constant EACCES = X::NativeCall::Errno.new(code => 13);
    constant EADDRINUSE = X::NativeCall::Errno.new(code => 48);
    constant EADDRNOTAVAIL = X::NativeCall::Errno.new(code => 49);
    constant EAFNOSUPPORT = X::NativeCall::Errno.new(code => 47);
    constant EAGAIN = X::NativeCall::Errno.new(code => 35);
    constant EALREADY = X::NativeCall::Errno.new(code => 37);
    constant EBADF = X::NativeCall::Errno.new(code => 9);
    constant EBADMSG = X::NativeCall::Errno.new(code => 94);
    constant EBUSY = X::NativeCall::Errno.new(code => 16);
    constant ECANCELED = X::NativeCall::Errno.new(code => 89);
    constant ECHILD = X::NativeCall::Errno.new(code => 10);
    constant ECONNABORTED = X::NativeCall::Errno.new(code => 53);
    constant ECONNREFUSED = X::NativeCall::Errno.new(code => 61);
    constant ECONNRESET = X::NativeCall::Errno.new(code => 54);
    constant EDEADLK = X::NativeCall::Errno.new(code => 11);
    constant EDESTADDRREQ = X::NativeCall::Errno.new(code => 39);
    constant EDOM = X::NativeCall::Errno.new(code => 33);
    constant EDQUOT = X::NativeCall::Errno.new(code => 69);
    constant EEXIST = X::NativeCall::Errno.new(code => 17);
    constant EFAULT = X::NativeCall::Errno.new(code => 14);
    constant EFBIG = X::NativeCall::Errno.new(code => 27);
    constant EHOSTUNREACH = X::NativeCall::Errno.new(code => 65);
    constant EIDRM = X::NativeCall::Errno.new(code => 90);
    constant EILSEQ = X::NativeCall::Errno.new(code => 92);
    constant EINPROGRESS = X::NativeCall::Errno.new(code => 36);
    constant EINTR = X::NativeCall::Errno.new(code => 4);
    constant EINVAL = X::NativeCall::Errno.new(code => 22);
    constant EIO = X::NativeCall::Errno.new(code => 5);
    constant EISCONN = X::NativeCall::Errno.new(code => 56);
    constant EISDIR = X::NativeCall::Errno.new(code => 21);
    constant ELOOP = X::NativeCall::Errno.new(code => 62);
    constant EMFILE = X::NativeCall::Errno.new(code => 24);
    constant EMLINK = X::NativeCall::Errno.new(code => 31);
    constant EMSGSIZE = X::NativeCall::Errno.new(code => 40);
    constant EMULTIHOP = X::NativeCall::Errno.new(code => 95);
    constant ENAMETOOLONG = X::NativeCall::Errno.new(code => 63);
    constant ENETDOWN = X::NativeCall::Errno.new(code => 50);
    constant ENETRESET = X::NativeCall::Errno.new(code => 52);
    constant ENETUNREACH = X::NativeCall::Errno.new(code => 51);
    constant ENFILE = X::NativeCall::Errno.new(code => 23);
    constant ENOBUFS = X::NativeCall::Errno.new(code => 55);
    constant ENODATA = X::NativeCall::Errno.new(code => 96);
    constant ENODEV = X::NativeCall::Errno.new(code => 19);
    constant ENOENT = X::NativeCall::Errno.new(code => 2);
    constant ENOEXEC = X::NativeCall::Errno.new(code => 8);
    constant ENOLCK = X::NativeCall::Errno.new(code => 77);
    constant ENOLINK = X::NativeCall::Errno.new(code => 97);
    constant ENOMEM = X::NativeCall::Errno.new(code => 12);
    constant ENOMSG = X::NativeCall::Errno.new(code => 91);
    constant ENOPROTOOPT = X::NativeCall::Errno.new(code => 42);
    constant ENOSPC = X::NativeCall::Errno.new(code => 28);
    constant ENOSR = X::NativeCall::Errno.new(code => 98);
    constant ENOSTR = X::NativeCall::Errno.new(code => 99);
    constant ENOSYS = X::NativeCall::Errno.new(code => 78);
    constant ENOTCONN = X::NativeCall::Errno.new(code => 57);
    constant ENOTDIR = X::NativeCall::Errno.new(code => 20);
    constant ENOTEMPTY = X::NativeCall::Errno.new(code => 66);
    constant ENOTSOCK = X::NativeCall::Errno.new(code => 38);
    constant ENOTSUP = X::NativeCall::Errno.new(code => 45);
    constant ENOTTY = X::NativeCall::Errno.new(code => 25);
    constant ENXIO = X::NativeCall::Errno.new(code => 6);
    constant EOPNOTSUPP = X::NativeCall::Errno.new(code => 102);
    constant EOVERFLOW = X::NativeCall::Errno.new(code => 84);
    constant EPERM = X::NativeCall::Errno.new(code => 1);
    constant EPIPE = X::NativeCall::Errno.new(code => 32);
    constant EPROTO = X::NativeCall::Errno.new(code => 100);
    constant EPROTONOSUPPORT = X::NativeCall::Errno.new(code => 43);
    constant EPROTOTYPE = X::NativeCall::Errno.new(code => 41);
    constant ERANGE = X::NativeCall::Errno.new(code => 34);
    constant EROFS = X::NativeCall::Errno.new(code => 30);
    constant ESPIPE = X::NativeCall::Errno.new(code => 29);
    constant ESRCH = X::NativeCall::Errno.new(code => 3);
    constant ESTALE = X::NativeCall::Errno.new(code => 70);
    constant ETIME = X::NativeCall::Errno.new(code => 101);
    constant ETIMEDOUT = X::NativeCall::Errno.new(code => 60);
    constant ETXTBSY = X::NativeCall::Errno.new(code => 26);
    constant EWOULDBLOCK = X::NativeCall::Errno.new(code => 35);
    constant EXDEV = X::NativeCall::Errno.new(code => 18);
}
