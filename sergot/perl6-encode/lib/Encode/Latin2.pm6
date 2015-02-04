module Encode::Latin2;

our %map =
    0xA0 => 0x0a0,
    0xA1 => 0x104,
    0xA2 => 0x2d8,
    0xA3 => 0x141,
    0xA4 => 0x0a4,
    0xA5 => 0x13d,
    0xA6 => 0x15a,
    0xA7 => 0x0a7,
    0xA8 => 0x0a8,
    0xA9 => 0x160,
    0xAA => 0x15e,
    0xAB => 0x164,
    0xAC => 0x179,
    0xAD => 0x0ad,
    0xAE => 0x17d,
    0xAF => 0x17b,
    0xB0 => 0x0b0,
    0xB1 => 0x105,
    0xB2 => 0x2db,
    0xB3 => 0x142,
    0xB4 => 0x0b4,
    0xB5 => 0x13e,
    0xB6 => 0x15b,
    0xB7 => 0x2c7,
    0xB8 => 0x0b8,
    0xB9 => 0x161,
    0xBA => 0x15f,
    0xBB => 0x165,
    0xBC => 0x17a,
    0xBD => 0x2dd,
    0xBE => 0x17e,
    0xBF => 0x17c,
    0xC0 => 0x154,
    0xC1 => 0x0c1,
    0xC2 => 0x0c2,
    0xC3 => 0x102,
    0xC4 => 0x0c4,
    0xC5 => 0x139,
    0xC6 => 0x106,
    0xC7 => 0x0c7,
    0xC8 => 0x10c,
    0xC9 => 0x0c9,
    0xCA => 0x118,
    0xCB => 0x0cb,
    0xCC => 0x11a,
    0xCD => 0x0cd,
    0xCE => 0x0ce,
    0xCF => 0x10e,
    0xD0 => 0x110,
    0xD1 => 0x143,
    0xD2 => 0x147,
    0xD3 => 0x0d3,
    0xD4 => 0x0d4,
    0xD5 => 0x150,
    0xD6 => 0x0d6,
    0xD7 => 0x0d7,
    0xD8 => 0x158,
    0xD9 => 0x16e,
    0xDA => 0x0da,
    0xDB => 0x170,
    0xDC => 0x0dc,
    0xDD => 0x0dd,
    0xDE => 0x162,
    0xDF => 0x0df,
    0xE0 => 0x155,
    0xE1 => 0x0e1,
    0xE2 => 0x0e2,
    0xE3 => 0x103,
    0xE4 => 0x0e4,
    0xE5 => 0x13a,
    0xE6 => 0x107,
    0xE7 => 0x0e7,
    0xE8 => 0x10d,
    0xE9 => 0x0e9,
    0xEA => 0x119,
    0xEB => 0x0eb,
    0xEC => 0x11b,
    0xED => 0x0ed,
    0xEE => 0x0ee,
    0xEF => 0x10f,
    0xF0 => 0x111,
    0xF1 => 0x144,
    0xF2 => 0x148,
    0xF3 => 0x0f3,
    0xF4 => 0x0f4,
    0xF5 => 0x151,
    0xF6 => 0x0f6,
    0xF7 => 0x0f7,
    0xF8 => 0x159,
    0xF9 => 0x16f,
    0xFA => 0x0fa,
    0xFB => 0x171,
    0xFC => 0x0fc,
    0xFD => 0x0fd,
    0xFE => 0x163,
    0xFF => 0x2d9
;
