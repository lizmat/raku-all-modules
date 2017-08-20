unit module GLFW::Key;

# Just a bunch of constants, really.

constant RELEASE = 0
constant PRESS = 1
constant REPEAT = 2

constant UNKNOWN = -1
constant SPACE = 32
constant APOSTROPHE = 39  # '
constant COMMA = 44  # ,
constant MINUS = 45  # -
constant PERIOD = 46  # .
constant SLASH = 47  # /

constant ZERO = 48
constant ONE = 49
constant TWO = 50
constant THREE = 51
constant FOUR = 52
constant FIVE = 53;
constant SIX = 54;
constant SEVEN = 55;
constant EIGHT = 56;
constant NINE = 57;

constant SEMICOLON = 59;  # ;
constant EQUAL = 61;  # =

constant A = 65;
constant B = 66;
constant C = 67;
constant D = 68;
constant E = 69;
constant F = 70;
constant G = 71;
constant H = 72;
constant I = 73;
constant J = 74;
constant K = 75;
constant L = 76;
constant M = 77;
constant N = 78;
constant O = 79;
constant P = 80;
constant Q = 81;
constant R = 82;
constant S = 83;
constant T = 84;
constant U = 85;
constant V = 86;
constant W = 87;
constant X = 88;
constant Y = 89;
constant Z = 90;

constant LEFT-BRACKET = 91;  # [
constant BACKSLASH = 92;  # \
constant RIGHT-BRACKET = 93;  # ]
constant GRAVE-ACCENT = 96;  # `
constant WORLD-ONE = 161;  # non-US #1, whatever that means
constant WORLD-TWO = 162;  # non-US #2, whatever that means

constant ESCAPE = 256;
constant ENTER = 257;
constant TAB = 258;
constant BACKSPACE = 259;
constant INSERT = 260;
constant DELETE = 261;
constant RIGHT = 262;
constant LEFT = 263;
constant DOWN = 264;
constant UP = 265;
constant PAGE-UP = 266;
constant PAGE-DOWN = 267;
constant HOME = 268;
constant END = 269;
constant CAPS-LOCK = 280;
constant SCROLL-LOCK = 281;
constant NUM-LOCK = 282;
constant PRINT-SCREEN = 283;
constant PAUSE = 284;

constant F1 = 290;
constant F2 = 291;
constant F3 = 292;
constant F4 = 293;
constant F5 = 294;
constant F6 = 295;
constant F7 = 296;
constant F8 = 297;
constant F9 = 298;
constant F10 = 299;
constant F11 = 300;
constant F12 = 301;
constant F13 = 302;
constant F14 = 303;
constant F15 = 304;
constant F16 = 305;
constant F17 = 306;
constant F18 = 307;
constant F19 = 308;
constant F20 = 309;
constant F21 = 310;
constant F22 = 311;
constant F23 = 312;
constant F24 = 313;
constant F25 = 314;

constant KEYPAD-ZERO = 320;
constant KEYPAD-ONE = 321;
constant KEYPAD-TWO = 322;
constant KEYPAD-THREE = 323;
constant KEYPAD-FOUR = 324;
constant KEYPAD-FIVE = 325;
constant KEYPAD-SIX = 326;
constant KEYPAD-SEVEN = 327;
constant KEYPAD-EIGHT = 328;
constant KEYPAD-NINE = 329;
constant KEYPAD-DECIMAL = 330;
constant KEYPAD-DIVIDE = 331;
constant KEYPAD-MULTIPLY = 332;
constant KEYPAD-SUBTRACT = 333;
constant KEYPAD-ADD = 334;
constant KEYPAD-ENTER = 335;
constant KEYPAD-EQUAL = 336;

constant LEFT-SHIFT = 340;
constant LEFT-CONTROL = 341;
constant LEFT-ALT = 342;
constant LEFT-SUPER = 343;
constant RIGHT-SHIFT = 344;
constant RIGHT-CONTROL = 345;
constant RIGHT-ALT = 346;
constant RIGHT-SUPER = 347;
constant MENU = 348;

constant LAST = $MENU;

module Modifier {
    constant SHIFT = 1;
    constant CONTROL = 2;
    constant ALT = 4;
    constant SUPER = 8;
}
