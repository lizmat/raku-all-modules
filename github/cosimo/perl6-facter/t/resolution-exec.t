use v6;
use Test;
use Facter;
use Facter::Util::Resolution;

my $uname_res = Facter::Util::Resolution.exec('uname -a');

diag('uname-res: ' ~ $uname_res);
ok($uname_res, 'uname -a should result in something');

done;

