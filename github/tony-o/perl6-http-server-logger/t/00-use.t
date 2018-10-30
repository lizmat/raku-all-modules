use HTTP::Server::Logger;
use Test;

plan 1;

my HTTP::Server::Logger $l .= new;

class test {
  has $.last is rw = '';
  method middleware(Sub $r) {
    $.last = $r(class { 
      has $.method   = 'GET';
      has $.uri      = '/', 
      has $.version  = 'HTTP/1.0' 
    }.new, class { 
      has $.status   = 200, 
      has $.bytes    = 20,
    }.new);
  }
};

my $a = test.new;
$a.middleware($l.logger);

say $a.last.perl;
ok $a.last ~~ / ^^ '- - - ' \d ** 2 '/' \w ** 3 '/' \d ** 4 ':' \d ** 2 ':' \d ** 2 ':' \d ** 2 ' ' (('+'|'-') \d ** 4 || 'Z') ' "GET / HTTP/1.0" 200 20' $$ /, 'Format matches';
