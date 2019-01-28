use v6.c;
use Test;
use P5opendir;

plan 12;

ok defined(::('&opendir')),           '&opendir imported?';
ok !defined(P5opendir::<&opendir>),   '&opendir externally NOT accessible?';
ok defined(::('&readdir')),           '&readdir imported?';
ok !defined(P5opendir::<&readdir>),   '&readdir externally NOT accessible?';
ok defined(::('&telldir')),           '&telldir imported?';
ok !defined(P5opendir::<&telldir>),   '&telldir externally NOT accessible?';
ok defined(::('&seekdir')),           '&seekdir imported?';
ok !defined(P5opendir::<&seekdir>),   '&seekdir externally NOT accessible?';
ok defined(::('&rewinddir')),         '&rewinddir imported?';
ok !defined(P5opendir::<&rewinddir>), '&rewinddir externally NOT accessible?';
ok defined(::('&closedir')),          '&closedir imported?';
ok !defined(P5opendir::<&closedir>),  '&closedir externally NOT accessible?';

# vim: ft=perl6 expandtab sw=4
