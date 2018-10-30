
use v6;
use Test;

use Net::FTP;

plan 7;

##mirrors.sohu.com is a anonymous ftp service

my $ftp = Net::FTP.new(:host('mirrors.sohu.com'));

ok($ftp.login() == 1, "anonymous ftp login success");
isnt($ftp.pwd(), '', "get current directory.");
ok($ftp.cwd('fedora') == 1, "change current directory to fedora");
isnt($ftp.pwd(), '', "get current directory.");
ok($ftp.cdup() == 1, "change current directory to fedora");
isnt($ftp.pwd(), '', "get current directory.");
ok($ftp.quit == 1, "anonymous ftp quit");
