use v6.c;
use Test;
use P5built-ins;

my @supported = <
  caller chdir chomp chop chr closedir each endgrent endpwent fc fileno
  getgrent getgrnam getgrgid getlogin getpwent getpwnam getpwuid gmtime hex
  index lc lcfirst length localtime oct opendir ord pack pop push quotemeta
  readdir readlink ref rewinddir rindex seek seekdir shift sleep study substr
  telldir tie tied times uc ucfirst unpack unshift untie

  prefix:<-r> prefix:<-w> prefix:<-x> prefix:<-e> prefix:<-d> prefix:<-f>
  prefix:<-s> prefix:<-z> prefix:<-l>
>.map: '&' ~ *;

plan +@supported;

for @supported {
    ok defined(::($_))              # something here by that name
      && ::($_) !=== SETTING::{$_}, # here, but not from the core Setting
      "is $_ imported?";
}

# vim: ft=perl6 expandtab sw=4
