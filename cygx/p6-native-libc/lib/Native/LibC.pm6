module Native::LibC {
    use nqp;
    use NativeCall;

    my constant KERNEL = $*VM.config<os> // $*KERNEL.name;
    my constant CTDLL = './p6-native-libc';
    my constant RTDLL =
        (%*ENV<PREFIX> andthen "$_/lib/Native/p6-native-libc".IO.abspath) //
        do { warn '!!! environment var PREFIX not set !!!'; CTDLL };
    my constant LIBC = do given KERNEL {
        when 'win32' { 'msvcr110.dll' }
        when 'mingw32' { 'msvcrt.dll' }
        default { Str }
    }

    my constant PTRSIZE = nativesizeof(Pointer);
    die "Unsupported pointer size { PTRSIZE }"
        unless PTRSIZE ~~ 4|8;

    constant int    = int32;
    constant uint   = uint32;
    constant llong  = longlong;
    constant ullong = ulonglong;
    constant float  = num32;
    constant double = num64;

    constant intptr_t = do given PTRSIZE {
        when 4 { int32 }
        when 8 { int64 }
    }

    constant uintptr_t = do given PTRSIZE {
        when 4 { uint32 }
        when 8 { uint64 }
    }

    constant size_t    = uintptr_t;
    constant ptrdiff_t = intptr_t;

    constant clock_t = do {
        sub p6_native_libc_time_clock_size(--> size_t) is native(CTDLL) { * }
        sub p6_native_libc_time_clock_is_float(--> int) is native(CTDLL) { * }
        sub p6_native_libc_time_clock_is_signed(--> int) is native(CTDLL) { * }

        given p6_native_libc_time_clock_size() {
            when 4 {
                if p6_native_libc_time_clock_is_float() { float }
                else {
                    if p6_native_libc_time_clock_is_signed() { int32 }
                    else { uint32 }
                }
            }
            when 8 {
                if p6_native_libc_time_clock_is_float() { double }
                else {
                    if p6_native_libc_time_clock_is_signed() { int64 }
                    else { uint64 }
                }
            }
            default { die "Unsupported clock_t size $_" }
        }
    }

    constant time_t = do {
        sub p6_native_libc_time_time_size(--> size_t) is native(CTDLL) { * }
        sub p6_native_libc_time_time_is_float(--> int) is native(CTDLL) { * }
        sub p6_native_libc_time_time_is_signed(--> int) is native(CTDLL) { * }

        given p6_native_libc_time_time_size() {
            when 4 {
                if p6_native_libc_time_time_is_float() { float }
                else {
                    if p6_native_libc_time_time_is_signed() { int32 }
                    else { uint32 }
                }
            }
            when 8 {
                if p6_native_libc_time_time_is_float() { double }
                else {
                    if p6_native_libc_time_time_is_signed() { int64 }
                    else { uint64 }
                }
            }
            default { die "Unsupported time_t size $_" }
        }
    }

    constant _IOFBF = do {
        sub p6_native_libc_stdio_iofbf(--> int) is native(CTDLL) { * }
        p6_native_libc_stdio_iofbf;
    }

    constant _IOLBF = do {
        sub p6_native_libc_stdio_iolbf(--> int) is native(CTDLL) { * }
        p6_native_libc_stdio_iolbf;
    }

    constant _IONBF = do {
        sub p6_native_libc_stdio_ionbf(--> int) is native(CTDLL) { * }
        p6_native_libc_stdio_ionbf;
    }

    constant BUFSIZ = do {
        sub p6_native_libc_stdio_bufsiz(--> size_t) is native(CTDLL) { * }
        p6_native_libc_stdio_bufsiz;
    }

    constant EOF = do {
        sub p6_native_libc_stdio_eof(--> int) is native(CTDLL) { * }
        p6_native_libc_stdio_eof;
    }

    constant SEEK_CUR = do {
        sub p6_native_libc_stdio_seek_cur(--> int) is native(CTDLL) { * }
        p6_native_libc_stdio_seek_cur;
    }

    constant SEEK_END = do {
        sub p6_native_libc_stdio_seek_end(--> int) is native(CTDLL) { * }
        p6_native_libc_stdio_seek_end;
    }

    constant SEEK_SET = do {
        sub p6_native_libc_stdio_seek_set(--> int) is native(CTDLL) { * }
        p6_native_libc_stdio_seek_set;
    }

    constant Ptr = Pointer;
    constant &sizeof = &nativesizeof;

    our sub NULL { once Ptr.new(0) }

    # <ctype.h>
    our sub isalnum(int --> int) is native(LIBC) { * }
    our sub isalpha(int --> int) is native(LIBC) { * }
    our sub isblank(int --> int) is native(LIBC) { * }
    our sub iscntrl(int --> int) is native(LIBC) { * }
    our sub isdigit(int --> int) is native(LIBC) { * }
    our sub isgraph(int --> int) is native(LIBC) { * }
    our sub islower(int --> int) is native(LIBC) { * }
    our sub isprint(int --> int) is native(LIBC) { * }
    our sub ispunct(int --> int) is native(LIBC) { * }
    our sub isspace(int --> int) is native(LIBC) { * }
    our sub isupper(int --> int) is native(LIBC) { * }
    our sub isxdigit(int --> int) is native(LIBC) { * }
    our sub tolower(int --> int) is native(LIBC) { * }
    our sub toupper(int --> int) is native(LIBC) { * }

    # <errno.h>
    my constant @ERRNO-BASE =
        :EPERM(1),
        :ENOENT(2),
        :ESRCH(3),
        :EINTR(4),
        :EIO(5),
        :ENXIO(6),
        :E2BIG(7),
        :ENOEXEC(8),
        :EBADF(9),
        :ECHILD(10),
        :EAGAIN(11),
        :ENOMEM(12),
        :EACCES(13),
        :EFAULT(14),
        :ENOTBLK(15),
        :EBUSY(16),
        :EEXIST(17),
        :EXDEV(18),
        :ENODEV(19),
        :ENOTDIR(20),
        :EISDIR(21),
        :EINVAL(22),
        :ENFILE(23),
        :EMFILE(24),
        :ENOTTY(25),
        :ETXTBSY(26),
        :EFBIG(27),
        :ENOSPC(28),
        :ESPIPE(29),
        :EROFS(30),
        :EMLINK(31),
        :EPIPE(32),
        :EDOM(33),
        :ERANGE(34);

    my constant @ERRNO-WIN32 =
        :EDEADLK(36),
        :EDEADLOCK(36),
        :ENAMETOOLONG(38),
        :ENOLCK(39),
        :ENOSYS(40),
        :ENOTEMPTY(41),
        :EILSEQ(42),
        :STRUNCATE(80);

    my constant @ERRNO-LINUX =
        :EDEADLK(35),
        :ENAMETOOLONG(36),
        :ENOLCK(37),
        :ENOSYS(38),
        :ENOTEMPTY(39),
        :ELOOP(40),
        :EWOULDBLOCK(11),
        :ENOMSG(42),
        :EIDRM(43),
        :ECHRNG(44),
        :EL2NSYNC(45),
        :EL3HLT(46),
        :EL3RST(47),
        :ELNRNG(48),
        :EUNATCH(49),
        :ENOCSI(50),
        :EL2HLT(51),
        :EBADE(52),
        :EBADR(53),
        :EXFULL(54),
        :ENOANO(55),
        :EBADRQC(56),
        :EBADSLT(57),
        :EDEADLOCK(35),
        :EBFONT(59),
        :ENOSTR(60),
        :ENODATA(61),
        :ETIME(62),
        :ENOSR(63),
        :ENONET(64),
        :ENOPKG(65),
        :EREMOTE(66),
        :ENOLINK(67),
        :EADV(68),
        :ESRMNT(69),
        :ECOMM(70),
        :EPROTO(71),
        :EMULTIHOP(72),
        :EDOTDOT(73),
        :EBADMSG(74),
        :EOVERFLOW(75),
        :ENOTUNIQ(76),
        :EBADFD(77),
        :EREMCHG(78),
        :ELIBACC(79),
        :ELIBBAD(80),
        :ELIBSCN(81),
        :ELIBMAX(82),
        :ELIBEXEC(83),
        :EILSEQ(84),
        :ERESTART(85),
        :ESTRPIPE(86),
        :EUSERS(87),
        :ENOTSOCK(88),
        :EDESTADDRREQ(89),
        :EMSGSIZE(90),
        :EPROTOTYPE(91),
        :ENOPROTOOPT(92),
        :EPROTONOSUPPORT(93),
        :ESOCKTNOSUPPORT(94),
        :EOPNOTSUPP(95),
        :EPFNOSUPPORT(96),
        :EAFNOSUPPORT(97),
        :EADDRINUSE(98),
        :EADDRNOTAVAIL(99),
        :ENETDOWN(100),
        :ENETUNREACH(101),
        :ENETRESET(102),
        :ECONNABORTED(103),
        :ECONNRESET(104),
        :ENOBUFS(105),
        :EISCONN(106),
        :ENOTCONN(107),
        :ESHUTDOWN(108),
        :ETOOMANYREFS(109),
        :ETIMEDOUT(110),
        :ECONNREFUSED(111),
        :EHOSTDOWN(112),
        :EHOSTUNREACH(113),
        :EALREADY(114),
        :EINPROGRESS(115),
        :ESTALE(116),
        :EUCLEAN(117),
        :ENOTNAM(118),
        :ENAVAIL(119),
        :EISNAM(120),
        :EREMOTEIO(121),
        :EDQUOT(122),
        :ENOMEDIUM(123),
        :EMEDIUMTYPE(124),
        :ECANCELED(125),
        :ENOKEY(126),
        :EKEYEXPIRED(127),
        :EKEYREVOKED(128),
        :EKEYREJECTED(129),
        :EOWNERDEAD(130),
        :ENOTRECOVERABLE(131);

    my Int enum Errno ();
    my Errno @errno;

    BEGIN {
        @errno[.value] = Native::LibC::{.key} :=
            Errno.new(:key(.key), :value(.value)) for flat do given KERNEL {
                when 'win32'|'mingw32' { @ERRNO-BASE, @ERRNO-WIN32 }
                when 'linux' { @ERRNO-BASE, @ERRNO-LINUX }
                default {
                    warn "Unknown kernel '$_'";
                    @ERRNO-BASE;
                }
            }
    }

    our proto errno(|) { * }

    multi sub errno() {
        sub p6_native_libc_errno_get(--> int32) is native(RTDLL) { * }
        my Int \value = p6_native_libc_errno_get;
        @errno[value] // value;
    }

    multi sub errno(Int \value) {
        sub p6_native_libc_errno_set(int) is native(RTDLL) { * }
        p6_native_libc_errno_set(value);
        @errno[value] // value;
    }

    # <limits.h>
    constant CHAR_BIT = do {
        sub p6_native_libc_limits_char_bit(--> int) is native(CTDLL) { * }
        p6_native_libc_limits_char_bit;
    }

    constant SCHAR_MIN = do {
        sub p6_native_libc_limits_schar_min(--> int) is native(CTDLL) { * }
        p6_native_libc_limits_schar_min;
    }

    constant SCHAR_MAX = do {
        sub p6_native_libc_limits_schar_max(--> int) is native(CTDLL) { * }
        p6_native_libc_limits_schar_max;
    }

    constant UCHAR_MAX = do {
        sub p6_native_libc_limits_uchar_max(--> int) is native(CTDLL) { * }
        p6_native_libc_limits_uchar_max;
    }

    constant CHAR_MIN = do {
        sub p6_native_libc_limits_char_min(--> int) is native(CTDLL) { * }
        p6_native_libc_limits_char_min;
    }

    constant CHAR_MAX = do {
        sub p6_native_libc_limits_char_max(--> int) is native(CTDLL) { * }
        p6_native_libc_limits_char_max;
    }

    constant MB_LEN_MAX = do {
        sub p6_native_libc_limits_mb_len_max(--> int) is native(CTDLL) { * }
        p6_native_libc_limits_mb_len_max;
    }

    constant SHRT_MIN = do {
        sub p6_native_libc_limits_shrt_min(--> int) is native(CTDLL) { * }
        p6_native_libc_limits_shrt_min;
    }

    constant SHRT_MAX = do {
        sub p6_native_libc_limits_shrt_max(--> int) is native(CTDLL) { * }
        p6_native_libc_limits_shrt_max;
    }

    constant USHRT_MAX = do {
        sub p6_native_libc_limits_ushrt_max(--> int) is native(CTDLL) { * }
        p6_native_libc_limits_ushrt_max;
    }

    constant INT_MIN = do {
        sub p6_native_libc_limits_int_min(--> int) is native(CTDLL) { * }
        p6_native_libc_limits_int_min;
    }

    constant INT_MAX = do {
        sub p6_native_libc_limits_int_max(--> int) is native(CTDLL) { * }
        p6_native_libc_limits_int_max;
    }

    constant UINT_MAX = do {
        sub p6_native_libc_limits_uint_max(--> uint) is native(CTDLL) { * }
        p6_native_libc_limits_uint_max;
    }

    constant LONG_MIN = do {
        sub p6_native_libc_limits_long_min(--> long) is native(CTDLL) { * }
        p6_native_libc_limits_long_min;
    }

    constant LONG_MAX = do {
        sub p6_native_libc_limits_long_max(--> long) is native(CTDLL) { * }
        p6_native_libc_limits_long_max;
    }

    constant ULONG_MAX = do {
        sub p6_native_libc_limits_ulong_max(--> ulong) is native(CTDLL) { * }
        p6_native_libc_limits_ulong_max;
    }

    constant LLONG_MIN = do {
        sub p6_native_libc_limits_llong_min(--> llong) is native(CTDLL) { * }
        p6_native_libc_limits_llong_min;
    }

    constant LLONG_MAX = do {
        sub p6_native_libc_limits_llong_max(--> llong) is native(CTDLL) { * }
        p6_native_libc_limits_llong_max;
    }

    constant ULLONG_MAX = do {
        sub p6_native_libc_limits_ullong_max(--> ullong) is native(CTDLL) { * }
        my \value = p6_native_libc_limits_ullong_max;
        value < 0
            ?? value + 2 ** (sizeof(ullong) * CHAR_BIT) # BUG -- no 64-bit unsigned
            !! value;
    }

    constant limits = %(
        :CHAR_BIT(CHAR_BIT),
        :SCHAR_MIN(SCHAR_MIN),
        :SCHAR_MAX(SCHAR_MAX),
        :UCHAR_MAX(UCHAR_MAX),
        :CHAR_MIN(CHAR_MIN),
        :CHAR_MAX(CHAR_MAX),
        :MB_LEN_MAX(MB_LEN_MAX),
        :SHRT_MIN(SHRT_MIN),
        :SHRT_MAX(SHRT_MAX),
        :USHRT_MAX(USHRT_MAX),
        :INT_MIN(INT_MIN),
        :INT_MAX(INT_MAX),
        :UINT_MAX(UINT_MAX),
        :LONG_MIN(LONG_MIN),
        :LONG_MAX(LONG_MAX),
        :ULONG_MAX(ULONG_MAX),
        :LLONG_MIN(LLONG_MIN),
        :LLONG_MAX(LLONG_MAX),
        :ULLONG_MAX(ULLONG_MAX)
    );

    # <stdio.h>
    class FILE is repr('CPointer') { ... }

    our sub fopen(Str, Str --> FILE) is native(LIBC) { * }
    our sub fclose(FILE --> int) is native(LIBC) { * }
    our sub fflush(FILE --> int) is native(LIBC) { * }
    our sub puts(Str --> int) is native(LIBC) { * }
    our sub fgets(Ptr, int, FILE --> Str) is native(LIBC) { * }
    our sub fread(Ptr, size_t, size_t, FILE --> size_t) is native(LIBC) { * }
    our sub feof(FILE --> int) is native(LIBC) { * }
    our sub fseek(FILE, long, int --> int) is native(LIBC) { * };

    our sub malloc(size_t --> Ptr) is native(LIBC) { * }
    our sub realloc(Ptr, size_t --> Ptr) is native(LIBC) { * }
    our sub calloc(size_t, size_t --> Ptr) is native(LIBC) { * }
    our sub free(Ptr) is native(LIBC) { * }

    our sub memcpy(Ptr, Ptr, size_t --> Ptr) is native(LIBC) { * }
    our sub memmove(Ptr, Ptr, size_t --> Ptr) is native(LIBC) { * }
    our sub memset(Ptr, int, size_t --> Ptr) is native(LIBC) { * }

    our sub memcmp(Ptr, Ptr, size_t --> int) is native(LIBC) { * }

    our sub strlen(Ptr[int8] --> size_t) is native(LIBC) { * }

    our sub system(Str --> int) is native(LIBC) { * }
    our sub exit(int) is native(LIBC) { * }
    our sub abort() is native(LIBC) { * }
    our sub raise(int --> int) is native(LIBC) { * }

    our sub getenv(Str --> Str) is native(LIBC) { * }

    our sub srand(uint) is native(LIBC) { * };
    our sub rand(--> int) is native(LIBC) { * };

    # <time.h>
    constant CLOCKS_PER_SEC = do {
        sub p6_native_libc_time_clocks_per_sec(--> clock_t) is native(CTDLL) { * }
        p6_native_libc_time_clocks_per_sec;
    }

    our sub clock(--> clock_t) is native(LIBC) { * }
    our sub time(Ptr[time_t] --> time_t) is native(LIBC) { * }

    class FILE is Ptr {
        method open(FILE:U: Str \path, Str \mode = 'r') {
            fopen(path, mode)
        }

        method close(FILE:D:) {
            fclose(self) == 0 or fail
        }

        method flush(FILE:D:) {
            fflush(self) == 0 or fail
        }

        method eof(FILE:D:) {
            feof(self) != 0
        }

        method seek(FILE:D: Int \offset, Int \whence) {
            fseek(self, offset, whence) == 0 or fail
        }

        method gets(FILE:D: Ptr() \ptr, int \count) {
            fgets(ptr, count, self) orelse fail
        }
    }
}

sub EXPORT(*@list) {
    Map.new(
        'libc' => Native::LibC,
        @list.map({
            when Native::LibC::{"&$_"}:exists { "&$_" => Native::LibC::{"&$_"} }
            when Native::LibC::{"$_"}:exists { "$_" => Native::LibC::{"$_"} }
            default { die "Unknown identifier '$_'"}
        })
    );
}
