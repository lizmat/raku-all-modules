use Test;

use lib 'lib';

use Crypt::Bcrypt;



# Generated with Python's module to test for compatibility
my $hash-old = '$2a$12$asr9zH69piPIONAAUurn0.8FlN9EoP7b/iqyAEBXDona3dCcHIPvK';
my $hash-new = '$2b$12$l.B85UMDjVX7Wi62xh4mJe23CJXEKTEzlE.BheXeeTq2mDGlPYNxO';

ok bcrypt-match("password", $hash-old), "2a positive check";
nok bcrypt-match("password1", $hash-old), "2a negative check";

ok bcrypt-match("password", $hash-new), "2b positive check";
nok bcrypt-match("password1", $hash-new), "2b negative check";



done-testing;
