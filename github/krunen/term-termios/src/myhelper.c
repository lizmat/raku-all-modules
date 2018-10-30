// The portions of the code are from cpython v3.7.0a1:
// https://github.com/python/cpython/blob/v3.7.0a1/Modules/termios.c
//
// The license of cpython v3.7.0a1 is:
// https://github.com/python/cpython/blob/v3.7.0a1/LICENSE

/* Apparently, on SGI, termios.h won't define CTRL if _XOPEN_SOURCE
   is defined, so we define it here. */
#if defined(__sgi)
#define CTRL(c) ((c)&037)
#endif

#include <stdio.h>
#include <termios.h>
#include <sys/ioctl.h>

/* HP-UX requires that this be included to pick up MDCD, MCTS, MDSR,
 * MDTR, MRI, and MRTS (appearantly used internally by some things
 * defined as macros; these are not used here directly).
 */
#ifdef HAVE_SYS_MODEM_H
#include <sys/modem.h>
#endif
/* HP-UX requires that this be included to pick up TIOCGPGRP and friends */
#ifdef HAVE_SYS_BSDTTY_H
#include <sys/bsdtty.h>
#endif

#if defined(VSWTCH) && !defined(VSWTC)
#define VSWTC VSWTCH
#endif

#if defined(VSWTC) && !defined(VSWTCH)
#define VSWTCH VSWTC
#endif

static struct constant {
    char *name;
    long value;
} termios_constants[] = {
    /* cfgetospeed(), cfsetospeed() constants */
    {"B0", B0},
    {"B50", B50},
    {"B75", B75},
    {"B110", B110},
    {"B134", B134},
    {"B150", B150},
    {"B200", B200},
    {"B300", B300},
    {"B600", B600},
    {"B1200", B1200},
    {"B1800", B1800},
    {"B2400", B2400},
    {"B4800", B4800},
    {"B9600", B9600},
    {"B19200", B19200},
    {"B38400", B38400},
#ifdef B57600
    {"B57600", B57600},
#endif
#ifdef B115200
    {"B115200", B115200},
#endif
#ifdef B230400
    {"B230400", B230400},
#endif
#ifdef B460800
    {"B460800", B460800},
#endif
#ifdef B500000
    {"B500000", B500000},
#endif
#ifdef B576000
    {"B576000", B576000},
#endif
#ifdef B921600
    {"B921600", B921600},
#endif
#ifdef B1000000
    {"B1000000", B1000000},
#endif
#ifdef B1152000
    {"B1152000", B1152000},
#endif
#ifdef B1500000
    {"B1500000", B1500000},
#endif
#ifdef B2000000
    {"B2000000", B2000000},
#endif
#ifdef B2500000
    {"B2500000", B2500000},
#endif
#ifdef B3000000
    {"B3000000", B3000000},
#endif
#ifdef B3500000
    {"B3500000", B3500000},
#endif
#ifdef B4000000
    {"B4000000", B4000000},
#endif

#ifdef CBAUDEX
    {"CBAUDEX", CBAUDEX},
#endif

    /* tcsetattr() constants */
    {"TCSANOW", TCSANOW},
    {"TCSADRAIN", TCSADRAIN},
    {"TCSAFLUSH", TCSAFLUSH},
#ifdef TCSASOFT
    {"TCSASOFT", TCSASOFT},
#endif

    /* tcflush() constants */
    {"TCIFLUSH", TCIFLUSH},
    {"TCOFLUSH", TCOFLUSH},
    {"TCIOFLUSH", TCIOFLUSH},

    /* tcflow() constants */
    {"TCOOFF", TCOOFF},
    {"TCOON", TCOON},
    {"TCIOFF", TCIOFF},
    {"TCION", TCION},

    /* struct termios.c_iflag constants */
    {"IGNBRK", IGNBRK},
    {"BRKINT", BRKINT},
    {"IGNPAR", IGNPAR},
    {"PARMRK", PARMRK},
    {"INPCK", INPCK},
    {"ISTRIP", ISTRIP},
    {"INLCR", INLCR},
    {"IGNCR", IGNCR},
    {"ICRNL", ICRNL},
#ifdef IUCLC
    {"IUCLC", IUCLC},
#endif
    {"IXON", IXON},
    {"IXANY", IXANY},
    {"IXOFF", IXOFF},
#ifdef IMAXBEL
    {"IMAXBEL", IMAXBEL},
#endif

    /* struct termios.c_oflag constants */
    {"OPOST", OPOST},
#ifdef OLCUC
    {"OLCUC", OLCUC},
#endif
#ifdef ONLCR
    {"ONLCR", ONLCR},
#endif
#ifdef OCRNL
    {"OCRNL", OCRNL},
#endif
#ifdef ONOCR
    {"ONOCR", ONOCR},
#endif
#ifdef ONLRET
    {"ONLRET", ONLRET},
#endif
#ifdef OFILL
    {"OFILL", OFILL},
#endif
#ifdef OFDEL
    {"OFDEL", OFDEL},
#endif
#ifdef NLDLY
    {"NLDLY", NLDLY},
#endif
#ifdef CRDLY
    {"CRDLY", CRDLY},
#endif
#ifdef TABDLY
    {"TABDLY", TABDLY},
#endif
#ifdef BSDLY
    {"BSDLY", BSDLY},
#endif
#ifdef VTDLY
    {"VTDLY", VTDLY},
#endif
#ifdef FFDLY
    {"FFDLY", FFDLY},
#endif

    /* struct termios.c_oflag-related values (delay mask) */
#ifdef NL0
    {"NL0", NL0},
#endif
#ifdef NL1
    {"NL1", NL1},
#endif
#ifdef CR0
    {"CR0", CR0},
#endif
#ifdef CR1
    {"CR1", CR1},
#endif
#ifdef CR2
    {"CR2", CR2},
#endif
#ifdef CR3
    {"CR3", CR3},
#endif
#ifdef TAB0
    {"TAB0", TAB0},
#endif
#ifdef TAB1
    {"TAB1", TAB1},
#endif
#ifdef TAB2
    {"TAB2", TAB2},
#endif
#ifdef TAB3
    {"TAB3", TAB3},
#endif
#ifdef XTABS
    {"XTABS", XTABS},
#endif
#ifdef BS0
    {"BS0", BS0},
#endif
#ifdef BS1
    {"BS1", BS1},
#endif
#ifdef VT0
    {"VT0", VT0},
#endif
#ifdef VT1
    {"VT1", VT1},
#endif
#ifdef FF0
    {"FF0", FF0},
#endif
#ifdef FF1
    {"FF1", FF1},
#endif

    /* struct termios.c_cflag constants */
    {"CSIZE", CSIZE},
    {"CSTOPB", CSTOPB},
    {"CREAD", CREAD},
    {"PARENB", PARENB},
    {"PARODD", PARODD},
    {"HUPCL", HUPCL},
    {"CLOCAL", CLOCAL},
#ifdef CIBAUD
    {"CIBAUD", CIBAUD},
#endif
#ifdef CRTSCTS
    {"CRTSCTS", (long)CRTSCTS},
#endif

    /* struct termios.c_cflag-related values (character size) */
    {"CS5", CS5},
    {"CS6", CS6},
    {"CS7", CS7},
    {"CS8", CS8},

    /* struct termios.c_lflag constants */
    {"ISIG", ISIG},
    {"ICANON", ICANON},
#ifdef XCASE
    {"XCASE", XCASE},
#endif
    {"ECHO", ECHO},
    {"ECHOE", ECHOE},
    {"ECHOK", ECHOK},
    {"ECHONL", ECHONL},
#ifdef ECHOCTL
    {"ECHOCTL", ECHOCTL},
#endif
#ifdef ECHOPRT
    {"ECHOPRT", ECHOPRT},
#endif
#ifdef ECHOKE
    {"ECHOKE", ECHOKE},
#endif
#ifdef FLUSHO
    {"FLUSHO", FLUSHO},
#endif
    {"NOFLSH", NOFLSH},
    {"TOSTOP", TOSTOP},
#ifdef PENDIN
    {"PENDIN", PENDIN},
#endif
    {"IEXTEN", IEXTEN},

    /* indexes into the control chars array returned by tcgetattr() */
    {"VINTR", VINTR},
    {"VQUIT", VQUIT},
    {"VERASE", VERASE},
    {"VKILL", VKILL},
    {"VEOF", VEOF},
    {"VTIME", VTIME},
    {"VMIN", VMIN},
#ifdef VSWTC
    /* The #defines above ensure that if either is defined, both are,
     * but both may be omitted by the system headers.  ;-(  */
    {"VSWTC", VSWTC},
    {"VSWTCH", VSWTCH},
#endif
    {"VSTART", VSTART},
    {"VSTOP", VSTOP},
    {"VSUSP", VSUSP},
    {"VEOL", VEOL},
#ifdef VREPRINT
    {"VREPRINT", VREPRINT},
#endif
#ifdef VDISCARD
    {"VDISCARD", VDISCARD},
#endif
#ifdef VWERASE
    {"VWERASE", VWERASE},
#endif
#ifdef VLNEXT
    {"VLNEXT", VLNEXT},
#endif
#ifdef VEOL2
    {"VEOL2", VEOL2},
#endif


#ifdef B460800
    {"B460800", B460800},
#endif
#ifdef CBAUD
    {"CBAUD", CBAUD},
#endif
#ifdef CDEL
    {"CDEL", CDEL},
#endif
#ifdef CDSUSP
    {"CDSUSP", CDSUSP},
#endif
#ifdef CEOF
    {"CEOF", CEOF},
#endif
#ifdef CEOL
    {"CEOL", CEOL},
#endif
#ifdef CEOL2
    {"CEOL2", CEOL2},
#endif
#ifdef CEOT
    {"CEOT", CEOT},
#endif
#ifdef CERASE
    {"CERASE", CERASE},
#endif
#ifdef CESC
    {"CESC", CESC},
#endif
#ifdef CFLUSH
    {"CFLUSH", CFLUSH},
#endif
#ifdef CINTR
    {"CINTR", CINTR},
#endif
#ifdef CKILL
    {"CKILL", CKILL},
#endif
#ifdef CLNEXT
    {"CLNEXT", CLNEXT},
#endif
#ifdef CNUL
    {"CNUL", CNUL},
#endif
#ifdef COMMON
    {"COMMON", COMMON},
#endif
#ifdef CQUIT
    {"CQUIT", CQUIT},
#endif
#ifdef CRPRNT
    {"CRPRNT", CRPRNT},
#endif
#ifdef CSTART
    {"CSTART", CSTART},
#endif
#ifdef CSTOP
    {"CSTOP", CSTOP},
#endif
#ifdef CSUSP
    {"CSUSP", CSUSP},
#endif
#ifdef CSWTCH
    {"CSWTCH", CSWTCH},
#endif
#ifdef CWERASE
    {"CWERASE", CWERASE},
#endif
#ifdef EXTA
    {"EXTA", EXTA},
#endif
#ifdef EXTB
    {"EXTB", EXTB},
#endif
#ifdef FIOASYNC
    {"FIOASYNC", FIOASYNC},
#endif
#ifdef FIOCLEX
    {"FIOCLEX", FIOCLEX},
#endif
#ifdef FIONBIO
    {"FIONBIO", FIONBIO},
#endif
#ifdef FIONCLEX
    {"FIONCLEX", FIONCLEX},
#endif
#ifdef FIONREAD
    {"FIONREAD", FIONREAD},
#endif
#ifdef IBSHIFT
    {"IBSHIFT", IBSHIFT},
#endif
#ifdef INIT_C_CC
    {"INIT_C_CC", INIT_C_CC},
#endif
#ifdef IOCSIZE_MASK
    {"IOCSIZE_MASK", IOCSIZE_MASK},
#endif
#ifdef IOCSIZE_SHIFT
    {"IOCSIZE_SHIFT", IOCSIZE_SHIFT},
#endif
#ifdef NCC
    {"NCC", NCC},
#endif
#ifdef NCCS
    {"NCCS", NCCS},
#endif
#ifdef NSWTCH
    {"NSWTCH", NSWTCH},
#endif
#ifdef N_MOUSE
    {"N_MOUSE", N_MOUSE},
#endif
#ifdef N_PPP
    {"N_PPP", N_PPP},
#endif
#ifdef N_SLIP
    {"N_SLIP", N_SLIP},
#endif
#ifdef N_STRIP
    {"N_STRIP", N_STRIP},
#endif
#ifdef N_TTY
    {"N_TTY", N_TTY},
#endif
#ifdef TCFLSH
    {"TCFLSH", TCFLSH},
#endif
#ifdef TCGETA
    {"TCGETA", TCGETA},
#endif
#ifdef TCGETS
    {"TCGETS", TCGETS},
#endif
#ifdef TCSBRK
    {"TCSBRK", TCSBRK},
#endif
#ifdef TCSBRKP
    {"TCSBRKP", TCSBRKP},
#endif
#ifdef TCSETA
    {"TCSETA", TCSETA},
#endif
#ifdef TCSETAF
    {"TCSETAF", TCSETAF},
#endif
#ifdef TCSETAW
    {"TCSETAW", TCSETAW},
#endif
#ifdef TCSETS
    {"TCSETS", TCSETS},
#endif
#ifdef TCSETSF
    {"TCSETSF", TCSETSF},
#endif
#ifdef TCSETSW
    {"TCSETSW", TCSETSW},
#endif
#ifdef TCXONC
    {"TCXONC", TCXONC},
#endif
#ifdef TIOCCONS
    {"TIOCCONS", TIOCCONS},
#endif
#ifdef TIOCEXCL
    {"TIOCEXCL", TIOCEXCL},
#endif
#ifdef TIOCGETD
    {"TIOCGETD", TIOCGETD},
#endif
#ifdef TIOCGICOUNT
    {"TIOCGICOUNT", TIOCGICOUNT},
#endif
#ifdef TIOCGLCKTRMIOS
    {"TIOCGLCKTRMIOS", TIOCGLCKTRMIOS},
#endif
#ifdef TIOCGPGRP
    {"TIOCGPGRP", TIOCGPGRP},
#endif
#ifdef TIOCGSERIAL
    {"TIOCGSERIAL", TIOCGSERIAL},
#endif
#ifdef TIOCGSOFTCAR
    {"TIOCGSOFTCAR", TIOCGSOFTCAR},
#endif
#ifdef TIOCGWINSZ
    {"TIOCGWINSZ", TIOCGWINSZ},
#endif
#ifdef TIOCINQ
    {"TIOCINQ", TIOCINQ},
#endif
#ifdef TIOCLINUX
    {"TIOCLINUX", TIOCLINUX},
#endif
#ifdef TIOCMBIC
    {"TIOCMBIC", TIOCMBIC},
#endif
#ifdef TIOCMBIS
    {"TIOCMBIS", TIOCMBIS},
#endif
#ifdef TIOCMGET
    {"TIOCMGET", TIOCMGET},
#endif
#ifdef TIOCMIWAIT
    {"TIOCMIWAIT", TIOCMIWAIT},
#endif
#ifdef TIOCMSET
    {"TIOCMSET", TIOCMSET},
#endif
#ifdef TIOCM_CAR
    {"TIOCM_CAR", TIOCM_CAR},
#endif
#ifdef TIOCM_CD
    {"TIOCM_CD", TIOCM_CD},
#endif
#ifdef TIOCM_CTS
    {"TIOCM_CTS", TIOCM_CTS},
#endif
#ifdef TIOCM_DSR
    {"TIOCM_DSR", TIOCM_DSR},
#endif
#ifdef TIOCM_DTR
    {"TIOCM_DTR", TIOCM_DTR},
#endif
#ifdef TIOCM_LE
    {"TIOCM_LE", TIOCM_LE},
#endif
#ifdef TIOCM_RI
    {"TIOCM_RI", TIOCM_RI},
#endif
#ifdef TIOCM_RNG
    {"TIOCM_RNG", TIOCM_RNG},
#endif
#ifdef TIOCM_RTS
    {"TIOCM_RTS", TIOCM_RTS},
#endif
#ifdef TIOCM_SR
    {"TIOCM_SR", TIOCM_SR},
#endif
#ifdef TIOCM_ST
    {"TIOCM_ST", TIOCM_ST},
#endif
#ifdef TIOCNOTTY
    {"TIOCNOTTY", TIOCNOTTY},
#endif
#ifdef TIOCNXCL
    {"TIOCNXCL", TIOCNXCL},
#endif
#ifdef TIOCOUTQ
    {"TIOCOUTQ", TIOCOUTQ},
#endif
#ifdef TIOCPKT
    {"TIOCPKT", TIOCPKT},
#endif
#ifdef TIOCPKT_DATA
    {"TIOCPKT_DATA", TIOCPKT_DATA},
#endif
#ifdef TIOCPKT_DOSTOP
    {"TIOCPKT_DOSTOP", TIOCPKT_DOSTOP},
#endif
#ifdef TIOCPKT_FLUSHREAD
    {"TIOCPKT_FLUSHREAD", TIOCPKT_FLUSHREAD},
#endif
#ifdef TIOCPKT_FLUSHWRITE
    {"TIOCPKT_FLUSHWRITE", TIOCPKT_FLUSHWRITE},
#endif
#ifdef TIOCPKT_NOSTOP
    {"TIOCPKT_NOSTOP", TIOCPKT_NOSTOP},
#endif
#ifdef TIOCPKT_START
    {"TIOCPKT_START", TIOCPKT_START},
#endif
#ifdef TIOCPKT_STOP
    {"TIOCPKT_STOP", TIOCPKT_STOP},
#endif
#ifdef TIOCSCTTY
    {"TIOCSCTTY", TIOCSCTTY},
#endif
#ifdef TIOCSERCONFIG
    {"TIOCSERCONFIG", TIOCSERCONFIG},
#endif
#ifdef TIOCSERGETLSR
    {"TIOCSERGETLSR", TIOCSERGETLSR},
#endif
#ifdef TIOCSERGETMULTI
    {"TIOCSERGETMULTI", TIOCSERGETMULTI},
#endif
#ifdef TIOCSERGSTRUCT
    {"TIOCSERGSTRUCT", TIOCSERGSTRUCT},
#endif
#ifdef TIOCSERGWILD
    {"TIOCSERGWILD", TIOCSERGWILD},
#endif
#ifdef TIOCSERSETMULTI
    {"TIOCSERSETMULTI", TIOCSERSETMULTI},
#endif
#ifdef TIOCSERSWILD
    {"TIOCSERSWILD", TIOCSERSWILD},
#endif
#ifdef TIOCSER_TEMT
    {"TIOCSER_TEMT", TIOCSER_TEMT},
#endif
#ifdef TIOCSETD
    {"TIOCSETD", TIOCSETD},
#endif
#ifdef TIOCSLCKTRMIOS
    {"TIOCSLCKTRMIOS", TIOCSLCKTRMIOS},
#endif
#ifdef TIOCSPGRP
    {"TIOCSPGRP", TIOCSPGRP},
#endif
#ifdef TIOCSSERIAL
    {"TIOCSSERIAL", TIOCSSERIAL},
#endif
#ifdef TIOCSSOFTCAR
    {"TIOCSSOFTCAR", TIOCSSOFTCAR},
#endif
#ifdef TIOCSTI
    {"TIOCSTI", TIOCSTI},
#endif
#ifdef TIOCSWINSZ
    {"TIOCSWINSZ", TIOCSWINSZ},
#endif
#ifdef TIOCTTYGSTRUCT
    {"TIOCTTYGSTRUCT", TIOCTTYGSTRUCT},
#endif

    /* sentinel */
    {NULL, 0}
};

struct constant*
termios_create_constant(void)
{
    struct constant *constant = termios_constants;
    return constant;
}

struct constant*
termios_get_next_constant(struct constant* constant) {
  if (constant == NULL) return NULL;
  return ++constant;
}

char*
termios_get_name(struct constant* constant) {
  if(constant == NULL) return NULL;
  return constant->name;
}

long
termios_get_value(struct constant* constant) {
  if(constant == NULL) return -1;
  return constant->value;
}
