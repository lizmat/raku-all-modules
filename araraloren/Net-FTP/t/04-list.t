
use v6;
use Test;

use Net::FTP;

plan 4;

##mirrors.sohu.com is a anonymous ftp service
my $ftp = Net::FTP.new(:host('mirrors.sohu.com'), :passive);

$ftp.login();
isnt($ftp.ls(), (), "list file success");
isnt($ftp.ls('fedora'), (), "list file success");
is($ftp.ls('/notexistdir'), (), "list file success");
isnt($ftp.ls('./'), (), "list file success");
$ftp.quit();
