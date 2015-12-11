
use v6;
use Test;

use Net::FTP;

plan 4;

##mirrors.sohu.com is a anonymous ftp service
my $ftp = Net::FTP.new(:host('013.3vftp.com'),:user('ftptest138'), :pass('123456'));

$ftp.login();
isnt($ftp.ls(), (), "list file success");
isnt($ftp.ls('fedora'), (), "list file success");
isnt($ftp.ls('./root/'), (), "list file success");
isnt($ftp.ls('./'), (), "list file success");
$ftp.quit();
