
use v6;
use Test;

use Net::FTP;

plan 5;

##013.3vftp.com is a ftp service
##mirrors.sohu.com is a anonymous ftp service 

my $host = '013.3vftp.com';
my $ftp = Net::FTP.new(:host($host));

ok($ftp.login() == 0, "ftp login failed");

$ftp = Net::FTP.new(:host('013.3vftp.com'),
					 :user<ftptest138>,
					 :pass('123456'));
				
ok($ftp.login() == 1, "ftp login success");
ok($ftp.quit == 1, "ftp quit");

$ftp = Net::FTP.new(:host('mirrors.sohu.com'));

ok($ftp.login() == 1, "anonymous ftp login success");
ok($ftp.quit == 1, "anonymous ftp quit");
			
