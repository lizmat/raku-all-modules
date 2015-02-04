use v6;
use Test;
use Crypt::Bcrypt;

plan 19;

my $hash = Crypt::Bcrypt.hash("test", Crypt::Bcrypt.gensalt());
ok Crypt::Bcrypt.compare("test", $hash), 'hash matches';
nok Crypt::Bcrypt.compare("testing", $hash), 'hash correctly does not match';

ok Crypt::Bcrypt.compare('Perl 6', '$2a$04$9.hb78Br4PfyiwWa65pmo.s106eoPNlDFKDzmJY5Jp9Iw/zoHVvLu'), 'matches 04 rounds';

ok Crypt::Bcrypt.compare('Perl 6', '$2a$05$savTFFe4A4xRSFQQXzVYP.atTP7BeCnogZu0coFEJdO4itf281Ta6'), 'matches 05 rounds';

ok Crypt::Bcrypt.compare('Perl 6', '$2a$06$7t7WaJA6TPPxk74tNzLTC.nlilX4ATnv/8W/skolky0uh29tiuwCa'), 'matches 06 rounds';

ok Crypt::Bcrypt.compare('Perl 6', '$2a$07$yJ9MxWEu0Lu5TnMitv.6I.rd/165ZlyvpA7We9zrFGSFgqKxj2BWe'), 'matches 07 rounds';

ok Crypt::Bcrypt.compare('Perl 6', '$2a$08$OiLT/6HqoYGRlVSLmoE/uuYvT8UX/dOL8eEgLdvXyuojq0dqk.1Zu'), 'matches 08 rounds';

ok Crypt::Bcrypt.compare('Perl 6', '$2a$09$6hgSuklfu..9sJYG.j5j0eB28HUlAoZY8wp9hjHmJ4SpYVELZd7/m'), 'matches 09 rounds';

ok Crypt::Bcrypt.compare('Perl 6', '$2a$10$ObF4WP/lM2z7yrH96zG8HO/9RgC.RXfi5u3QOKvA08HakB95Qt4Oq'), 'matches 10 rounds';

ok Crypt::Bcrypt.compare('Perl 6', '$2a$11$JCAHn2oLOLLZXrmvoRq53.7el6ZfKy/L4eO4TrbB8bJTXwyqS58kO'), 'matches 11 rounds';

ok Crypt::Bcrypt.compare('Perl 6', '$2a$12$Z2zFH7VuHl2YkMirrcneGOZ5kxGNPrS7ZK0FBUVZp60gikhkMVd7m'), 'matches 12 rounds';

ok Crypt::Bcrypt.compare('Perl 6', '$2a$13$QUVrI5M30UOXJ2AEwOmVXuiZqe90JH1kKbJBQKREsLd19HcXVJ2zS'), 'matches 13 rounds';

ok Crypt::Bcrypt.compare('Perl 6', '$2a$14$7zA8MMWdKbxiEtc5KFJbMeVJ5GE/DwRADMzR4WM9ud4gvE2B32pbq'), 'matches 14 rounds';

ok Crypt::Bcrypt.compare('Perl 6', '$2a$15$FPbnJKF1j70EbrGN89Tt6.bbp2qg0EGs4B04Tv4LsAmiTlmD4T6YS'), 'matches 15 rounds';

# would be nice to test more rounds but this becomes too slow on some hardware

$hash = Crypt::Bcrypt.hash('MQyKyjdvI5kp', Crypt::Bcrypt.gensalt());
ok Crypt::Bcrypt.compare('MQyKyjdvI5kp', $hash), 'matches known hash';
nok Crypt::Bcrypt.compare('MQyKyjdvI5k', $hash), 'letter short at end';
nok Crypt::Bcrypt.compare('QyKyjdvI5kp', $hash), 'letter short at beginning';
nok Crypt::Bcrypt.compare('MQyKyjdvI5kq', $hash), 'letter different at end';
nok Crypt::Bcrypt.compare($hash, $hash), 'hash does not match itself';

# vim: ft=perl6
