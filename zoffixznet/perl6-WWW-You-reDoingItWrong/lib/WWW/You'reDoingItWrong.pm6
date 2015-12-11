unit package WWW::You'reDoingItWrong:ver<1.001001>;

use HTTP::Tinyish;
class WWW::You'reDoingItWrong_private {}
sub you're (WWW::You'reDoingItWrong_private $ ) is export {
    my %res = HTTP::Tinyish.new( agent => "Mozilla/5.0" )
                            .get: 'http://www.doingitwrong.com';
    %res<status> == 200 or fail "Received HTTP status %res<status> from Google";
    %res<content> ~~ m{'<img src="' $<pic>=(<-["]>+) }
        or fail 'Did not find a pic in the content';
    return "You're doing it wrong: http://www.doingitwrong.com" ~ $/<pic>;
}
sub doing  (WWW::You'reDoingItWrong_private $x) is export { $x }
sub it     (WWW::You'reDoingItWrong_private $x) is export { $x }
sub wrong  () is export { return WWW::You'reDoingItWrong_private.new; }
