use v6;
unit module Term::Choose::NCurses;

my $VERSION = '0.112';


use NativeCall;

constant LIB = %*ENV<PERL6_NCURSES_LIB> || 'libncursesw.so.5';


class WINDOW is repr('CPointer') { }

class MEVENT is repr('CStruct') {
  #short id;           /* ID to distinguish multiple devices */
  has int16 $.id;
  #int x, y, z;        /* event coordinates (character-cell) */
  has int32 $.x;
  has int32 $.y;
  has int32 $.z;
  #mmask_t bstate;     /* button state bits */
  has int32 $.bstate;
};


#constant OK            is export( :all ) = 0; # ?
constant ERR           is export( :all ) = -1;  # T::F
constant KEY_CODE_YES  is export( :all ) = 256; # T::F

constant KEY_DOWN      is export( :all ) = 258;
constant KEY_UP        is export( :all ) = 259;
constant KEY_LEFT      is export( :all ) = 260;
constant KEY_RIGHT     is export( :all ) = 261;
constant KEY_HOME      is export( :all ) = 262;
constant KEY_BACKSPACE is export( :all ) = 263;
constant KEY_DC        is export( :all ) = 330;
constant KEY_NPAGE     is export( :all ) = 338;
constant KEY_PPAGE     is export( :all ) = 339;
constant KEY_ENTER     is export( :all ) = 343;
constant KEY_BTAB      is export( :all ) = 353;
constant KEY_END       is export( :all ) = 360;
constant KEY_MOUSE     is export( :all ) = 409;
#constant KEY_RESIZE   is export( :all ) = 410;


constant A_UNDERLINE is export( :all ) = 131072;
constant A_REVERSE   is export( :all ) = 262144;
constant A_BOLD      is export( :all ) = 2097152;


constant BUTTON1_RELEASED         is export( :all ) = 1;
constant BUTTON1_PRESSED          is export( :all ) = 2;
constant BUTTON1_CLICKED          is export( :all ) = 4;
constant BUTTON1_DOUBLE_CLICKED   is export( :all ) = 8;
constant BUTTON1_TRIPLE_CLICKED   is export( :all ) = 16;


#constant BUTTON2_RELEASED        is export( :all ) = 64;
#constant BUTTON2_PRESSED         is export( :all ) = 128;
#constant BUTTON2_CLICKED         is export( :all ) = 256;
#constant BUTTON2_DOUBLE_CLICKED  is export( :all ) = 512;
#constant BUTTON2_TRIPLE_CLICKED  is export( :all ) = 1024;

#constant BUTTON2_RELEASED         is export( :all ) = 32;
#constant BUTTON2_PRESSED          is export( :all ) = 64;
#constant BUTTON2_CLICKED          is export( :all ) = 128;
#constant BUTTON2_DOUBLE_CLICKED   is export( :all ) = 256;
#constant BUTTON2_TRIPLE_CLICKED   is export( :all ) = 512;


#constant BUTTON3_RELEASED        is export( :all ) = 4096;
#constant BUTTON3_PRESSED         is export( :all ) = 8192;
#constant BUTTON3_CLICKED         is export( :all ) = 16384;
#constant BUTTON3_DOUBLE_CLICKED  is export( :all ) = 32768;
#constant BUTTON3_TRIPLE_CLICKED  is export( :all ) = 65536;

#constant BUTTON3_RELEASED         is export( :all ) = 1024;
#constant BUTTON3_PRESSED          is export( :all ) = 2048;
#constant BUTTON3_CLICKED          is export( :all ) = 4096;
#constant BUTTON3_DOUBLE_CLICKED   is export( :all ) = 8192;
#constant BUTTON3_TRIPLE_CLICKED   is export( :all ) = 16384;


#constant BUTTON4_RELEASED        is export( :all ) = 262144;
#constant BUTTON4_PRESSED         is export( :all ) = 524288;
#constant BUTTON4_CLICKED         is export( :all ) = 1048576;
#constant BUTTON4_DOUBLE_CLICKED  is export( :all ) = 2097152;
#constant BUTTON4_TRIPLE_CLICKED  is export( :all ) = 4194304;

#constant BUTTON4_RELEASED         is export( :all ) = 32768;
#constant BUTTON4_PRESSED          is export( :all ) = 65536;
#constant BUTTON4_CLICKED          is export( :all ) = 131072;
#constant BUTTON4_DOUBLE_CLICKED   is export( :all ) = 262144;
#constant BUTTON4_TRIPLE_CLICKED   is export( :all ) = 524288;


#constant BUTTON5_RELEASED         is export( :all ) = 1048576;
#constant BUTTON5_PRESSED          is export( :all ) = 2097152;
#constant BUTTON5_CLICKED          is export( :all ) = 4194304;
#constant BUTTON5_DOUBLE_CLICKED   is export( :all ) = 8388608;
#constant BUTTON5_TRIPLE_CLICKED   is export( :all ) = 16777216;


#constant BUTTON_CTRL             is export( :all ) = 16777216;
#constant BUTTON_SHIFT            is export( :all ) = 33554432;
#constant BUTTON_ALT              is export( :all ) = 67108864;

#constant BUTTON_SHIFT             is export( :all ) = 33554432;
#constant BUTTON_CTRL              is export( :all ) = 67108864;
#constant BUTTON_ALT               is export( :all ) = 134217728;


constant REPORT_MOUSE_POSITION    is export( :all ) = 134217728;
constant ALL_MOUSE_EVENTS         is export( :all ) = 134217727;




# functions from curses.h below

sub attroff(int32)                    returns int32  is native(LIB) is export( :all ) {*};
sub attron(int32)                     returns int32  is native(LIB) is export( :all ) {*};
sub beep()                            returns int32  is native(LIB) is export( :all ) {*};
sub cbreak()                          returns int32  is native(LIB) is export( :all ) {*};
sub clear()                           returns int32  is native(LIB) is export( :all ) {*};
sub clrtobot()                        returns int32  is native(LIB) is export( :all ) {*};
sub clrtoeol()                        returns int32  is native(LIB) is export( :all ) {*};
sub curs_set(int32)                   returns int32  is native(LIB) is export( :all ) {*};
sub endwin()                          returns int32  is native(LIB) is export( :all ) {*};
sub getch()                           returns int32  is native(LIB) is export( :all ) {*};
sub initscr()                         returns WINDOW is native(LIB) is export( :all ) {*};
sub keypad(WINDOW,int32)              returns int32  is native(LIB) is export( :all ) {*};
sub move(int32,int32)                 returns int32  is native(LIB) is export( :all ) {*};
sub mvaddstr(int32,int32,Str)         returns int32  is native(LIB) is export( :all ) {*};
sub noecho()                          returns int32  is native(LIB) is export( :all ) {*};
sub nc_refresh() is symbol('refresh') returns int32  is native(LIB) is export( :all ) {*};
sub getmaxx(WINDOW)                   returns int32  is native(LIB) is export( :all ) {*};
sub getmaxy(WINDOW)                   returns int32  is native(LIB) is export( :all ) {*};
sub getmouse(MEVENT)                  returns int32  is native(LIB) is export( :all ) {*};
sub mousemask(int32,CArray[int32])    returns int32  is native(LIB) is export( :all ) {*};
sub ungetch(int32)                    returns int32  is native(LIB) is export( :all ) {*};

sub nodelay(WINDOW, bool)             returns int32  is native(LIB) is export( :all ) {*};  # T::F
sub get_wch(int32 is rw)              returns int32  is native(LIB) is export( :all ) {*};  # T::F



# from locale.h

sub setlocale(int32, Str)             returns Str    is native(Str) is export( :all ) {*};
