use v6.c;
use Test;
use P5built-ins;

my @supported = <
  abs caller chdir chomp chop chr closedir cos crypt defined each endgrent
  endnetent endprotoent endpwent endservent exp fc fileno getgrent getgrgid
  getgrnam getlogin getnetbyaddr getnetbyname getnetent getpgrp getppid
  getpriority getprotobyname getprotobynumber getprotoent getpwent getpwnam
  getpwuid getservbyname getservbyport getservent gmtime hex index int lc
  lcfirst length localtime log oct opendir ord pack pop print printf push
  quotemeta rand readdir readlink ref reset reverse rewinddir rindex say
  seek seekdir setgrent setnetent setpriority setprotoent setpwent setservent
  shift sin sleep sqrt study substr telldir tie tied times uc ucfirst undef
  unpack unshift untie

  prefix:<-r> prefix:<-w> prefix:<-x> prefix:<-e> prefix:<-d> prefix:<-f>
  prefix:<-s> prefix:<-z> prefix:<-l>

  term:<SEEK_CUR> term:<SEEK_END> term:<SEEK_SET>
>.map: '&' ~ *;

@supported.push(    # somehow these need to be added literally
  '&term:<__FILE__>',
  '&term:<__LINE__>',
  '&term:<__PACKAGE__>',
  '&term:<__SUB__>',
  '&term:<STDERR>',
  '&term:<STDIN>',
  '&term:<STDOUT>',
);

plan +@supported;

for @supported {
    ok defined(::($_))              # something here by that name
      && ::($_) !=== SETTING::{$_}, # here, but not from the core Setting
      "is $_ imported?";
}

# vim: ft=perl6 expandtab sw=4
