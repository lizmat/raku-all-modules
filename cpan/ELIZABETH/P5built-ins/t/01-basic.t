use v6.c;
use Test;
use P5built-ins;

my @supported = <
  caller chdir chomp chop chr closedir each endgrent endnetent endprotoent
  endpwent endservent fc fileno getgrent getgrgid getgrnam getlogin getnetbyaddr
  getnetbyname getnetent getpgrp getppid getpriority getprotobyname getprotobynumber
  getprotoent getpwent getpwnam getpwuid getservbyname getservbyport getservent
  gmtime hex index lc lcfirst length localtime oct opendir ord pack pop print printf
  push quotemeta rand readdir readlink ref reset reverse rewinddir rindex say seek
  seekdir setgrent setnetent setpriority setprotoent setpwent setservent shift sleep 
  srand study substr telldir tie tied times uc ucfirst unpack unshift untie

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
