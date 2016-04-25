use Test;

use lib 'lib';

use Crypt::Argon2;


my $hash = argon2-hash("password");
my $hash-reference = '$argon2i$v=19$m=65536,t=4,p=2$QXtq7Djxz/q2h2uAFTy46g$D14zBbQDvfxjIOjCNCM0CsymTb5lns04CoOIMQUJYcs';

ok argon2-verify($hash, "password"), "Verify true new hash";
ok argon2-verify($hash-reference, "password"), "Verify true reference hash";

nok argon2-verify($hash, "password1"), "False-check on new hash";
nok argon2-verify($hash-reference, "password1"), "False-check on reference hash";



done-testing;
