
use v6;
use Test;
use Net::FTP;

plan 2;

my $ftp = Net::FTP.new(:host('013.3vftp.com'),:user('ftptest138'), :pass('123456'), :passive);

$ftp.login();
ok($ftp.get("stor.txt", "some.txt", :binary) == 1, "Get file stor.txt success");
ok($ftp.put("some.txt") == 1, "Put file some.txt success");
$ftp.quit();
