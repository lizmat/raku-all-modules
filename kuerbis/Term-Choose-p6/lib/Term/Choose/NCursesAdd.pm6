use v6;
unit module Term::Choose::NCursesAdd;


use NativeCall;

# from locale.h

sub setlocale(int32, Str) returns Str is native(Str) is export {*};




# from  curses.h   -   /* mouse interface */
# EMM_... if NCURSES_MOUSE_VERSION  > 1  (libncursesw.so.6)

#constant EMM_BUTTON1_RELEASED       is export = 1;
constant EMM_BUTTON1_PRESSED        is export = 2;
constant EMM_BUTTON1_CLICKED        is export = 4;
#constant EMM_BUTTON1_DOUBLE_CLICKED is export = 8;
#constant EMM_BUTTON1_TRIPLE_CLICKED is export = 16;

#constant EMM_BUTTON2_RELEASED       is export = 32;
#constant EMM_BUTTON2_PRESSED        is export = 64;
#constant EMM_BUTTON2_CLICKED        is export = 128;
#constant EMM_BUTTON2_DOUBLE_CLICKED is export = 256;
#constant EMM_BUTTON2_TRIPLE_CLICKED is export = 512;

constant EMM_BUTTON3_RELEASED       is export = 1024;
constant EMM_BUTTON3_PRESSED        is export = 2048;
constant EMM_BUTTON3_CLICKED        is export = 4096;
#constant EMM_BUTTON3_DOUBLE_CLICKED is export = 8192;
#constant EMM_BUTTON3_TRIPLE_CLICKED is export = 16384;

#constant EMM_BUTTON4_RELEASED       is export = 32768;
constant EMM_BUTTON4_PRESSED        is export = 65536;
#constant EMM_BUTTON4_CLICKED        is export = 131072;
#constant EMM_BUTTON4_DOUBLE_CLICKED is export = 262144;
#constant EMM_BUTTON4_TRIPLE_CLICKED is export = 524288;

#constant EMM_BUTTON5_RELEASED       is export = 1048576;
constant EMM_BUTTON5_PRESSED        is export = 2097152;
#constant EMM_BUTTON5_CLICKED        is export = 4194304;
#constant EMM_BUTTON5_DOUBLE_CLICKED is export = 8388608;
#constant EMM_BUTTON5_TRIPLE_CLICKED is export = 16777216;

#constant EMM_BUTTON_SHIFT           is export = 33554432;
#constant EMM_BUTTON_CTRL            is export = 67108864;
#constant EMM_BUTTON_ALT             is export = 134217728;

constant EMM_REPORT_MOUSE_POSITION  is export = 268435456;
constant EMM_ALL_MOUSE_EVENTS       is export = 268435455;


