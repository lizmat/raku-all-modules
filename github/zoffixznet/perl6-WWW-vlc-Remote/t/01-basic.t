use lib 'lib';
use Test;
use WWW::vlc::Remote;

plan 1;
isa-ok WWW::vlc::Remote.new, WWW::vlc::Remote;
