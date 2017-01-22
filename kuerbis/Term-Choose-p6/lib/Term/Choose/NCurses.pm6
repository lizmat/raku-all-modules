use v6;
unit module Term::Choose::NCurses;

my $VERSION = '0.118';


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


constant OK            is export = 0;   #
constant ERR           is export = -1;  # T::F
constant KEY_CODE_YES  is export = 256; # T::F

constant KEY_DOWN      is export = 258;
constant KEY_UP        is export = 259;
constant KEY_LEFT      is export = 260;
constant KEY_RIGHT     is export = 261;
constant KEY_HOME      is export = 262;
constant KEY_BACKSPACE is export = 263;
constant KEY_DC        is export = 330;
constant KEY_NPAGE     is export = 338;
constant KEY_PPAGE     is export = 339;
constant KEY_ENTER     is export = 343;
constant KEY_BTAB      is export = 353;
constant KEY_END       is export = 360;
constant KEY_MOUSE     is export = 409;
#constant KEY_RESIZE   is export = 410;


constant A_UNDERLINE is export = 131072;
constant A_REVERSE   is export = 262144;
constant A_BOLD      is export = 2097152;


constant BUTTON1_RELEASED         is export = 1;
constant BUTTON1_PRESSED          is export = 2;
constant BUTTON1_CLICKED          is export = 4;
constant BUTTON1_DOUBLE_CLICKED   is export = 8;
constant BUTTON1_TRIPLE_CLICKED   is export = 16;


#constant BUTTON2_RELEASED        is export = 64;
#constant BUTTON2_PRESSED         is export = 128;
#constant BUTTON2_CLICKED         is export = 256;
#constant BUTTON2_DOUBLE_CLICKED  is export = 512;
#constant BUTTON2_TRIPLE_CLICKED  is export = 1024;

#constant BUTTON2_RELEASED         is export = 32;
#constant BUTTON2_PRESSED          is export = 64;
#constant BUTTON2_CLICKED          is export = 128;
#constant BUTTON2_DOUBLE_CLICKED   is export = 256;
#constant BUTTON2_TRIPLE_CLICKED   is export = 512;


#constant BUTTON3_RELEASED        is export = 4096;
#constant BUTTON3_PRESSED         is export = 8192;
#constant BUTTON3_CLICKED         is export = 16384;
#constant BUTTON3_DOUBLE_CLICKED  is export = 32768;
#constant BUTTON3_TRIPLE_CLICKED  is export = 65536;

#constant BUTTON3_RELEASED         is export = 1024;
#constant BUTTON3_PRESSED          is export = 2048;
#constant BUTTON3_CLICKED          is export = 4096;
#constant BUTTON3_DOUBLE_CLICKED   is export = 8192;
#constant BUTTON3_TRIPLE_CLICKED   is export = 16384;


#constant BUTTON4_RELEASED        is export = 262144;
#constant BUTTON4_PRESSED         is export = 524288;
#constant BUTTON4_CLICKED         is export = 1048576;
#constant BUTTON4_DOUBLE_CLICKED  is export = 2097152;
#constant BUTTON4_TRIPLE_CLICKED  is export = 4194304;

#constant BUTTON4_RELEASED         is export = 32768;
#constant BUTTON4_PRESSED          is export = 65536;
#constant BUTTON4_CLICKED          is export = 131072;
#constant BUTTON4_DOUBLE_CLICKED   is export = 262144;
#constant BUTTON4_TRIPLE_CLICKED   is export = 524288;


#constant BUTTON5_RELEASED         is export = 1048576;
#constant BUTTON5_PRESSED          is export = 2097152;
#constant BUTTON5_CLICKED          is export = 4194304;
#constant BUTTON5_DOUBLE_CLICKED   is export = 8388608;
#constant BUTTON5_TRIPLE_CLICKED   is export = 16777216;


#constant BUTTON_CTRL             is export = 16777216;
#constant BUTTON_SHIFT            is export = 33554432;
#constant BUTTON_ALT              is export = 67108864;

#constant BUTTON_SHIFT             is export = 33554432;
#constant BUTTON_CTRL              is export = 67108864;
#constant BUTTON_ALT               is export = 134217728;


constant REPORT_MOUSE_POSITION    is export = 134217728;
constant ALL_MOUSE_EVENTS         is export = 134217727;




# functions from curses.h below

sub attroff(int32)                    returns int32  is native(LIB) is export {*};
sub attron(int32)                     returns int32  is native(LIB) is export {*};
sub beep()                            returns int32  is native(LIB) is export {*};
sub cbreak()                          returns int32  is native(LIB) is export {*};
sub clear()                           returns int32  is native(LIB) is export {*};
sub clrtobot()                        returns int32  is native(LIB) is export {*};
sub clrtoeol()                        returns int32  is native(LIB) is export {*};
sub curs_set(int32)                   returns int32  is native(LIB) is export {*};
sub endwin()                          returns int32  is native(LIB) is export {*};
sub getch()                           returns int32  is native(LIB) is export {*};
sub initscr()                         returns WINDOW is native(LIB) is export {*};
sub keypad(WINDOW,int32)              returns int32  is native(LIB) is export {*};
sub move(int32,int32)                 returns int32  is native(LIB) is export {*};
sub mvaddstr(int32,int32,Str)         returns int32  is native(LIB) is export {*};
sub noecho()                          returns int32  is native(LIB) is export {*};
sub nc_refresh() is symbol('refresh') returns int32  is native(LIB) is export {*};
sub getmaxx(WINDOW)                   returns int32  is native(LIB) is export {*};
sub getmaxy(WINDOW)                   returns int32  is native(LIB) is export {*};
sub getmouse(MEVENT)                  returns int32  is native(LIB) is export {*};
sub mousemask(int32,CArray[int32])    returns int32  is native(LIB) is export {*};
sub ungetch(int32)                    returns int32  is native(LIB) is export {*};

sub nodelay(WINDOW, bool)             returns int32  is native(LIB) is export {*};  # T::F
sub get_wch(int32 is rw)              returns int32  is native(LIB) is export {*};  # T::F



# from locale.h

sub setlocale(int32, Str)             returns Str    is native(Str) is export {*};
