
use v6;
use Test;

use Net::FTP;

plan 2;

my $ftp = Net::FTP.new(:host('013.3vftp.com'),:user('ftptest138'), :pass('123456'), :passive);

$ftp.login();
$ftp.rmdir("/newdir"); ## make sure newdir not exist
ok($ftp.mkdir("/newdir"), "Mkdir success");
ok($ftp.rmdir("/newdir") == 1, "Rmdir success");
$ftp.quit();
