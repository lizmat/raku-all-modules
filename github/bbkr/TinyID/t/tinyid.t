use lib 'lib';

use Test;
use TinyID;

plan 6;

my $tid;

subtest {
    lives-ok { $tid = TinyID.new( key => 'ab' ) }, 'new using key "ab"';
    is $tid.encode( 0 ), 'a', 'encode 0';
    is $tid.decode( 'a' ), 0, 'decode "a"';
    is $tid.encode( 1 ), 'b', 'encode 1';
    is $tid.decode( 'b' ), 1, 'decode "b"';
    is $tid.encode( 18446744073709551615 ), 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', 'encode unsigned bigint';
    is $tid.decode( 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' ), 18446744073709551615, 'decode unsigned bigint';
}, 'shortest key possible';

subtest {
    lives-ok { $tid = TinyID.new( key => 'ąä' ) }, 'new using key "ąä"';
    is $tid.encode( 2 ), 'äą', 'encode 2';
    is $tid.decode( 'äą' ), 2, 'decode "äą"';
}, 'accent sensitive';

subtest {
    lives-ok { $tid = TinyID.new( key => 'Aa' ) }, 'new using key "Aa"';
    is $tid.encode( 2 ), 'aA', 'encode 2';
    is $tid.decode( 'aA' ), 2, 'decode "aA"';
}, 'case sensitive';

subtest {
    my $key = 'FujSBZHkPMincNQr6pq0mgxw2tXAsyb8DWV534EC1RUIlYoGOJhed9afKT7vzL';
    
    lives-ok { $tid = TinyID.new( key => $key ) }, 'new using alphanumeric key';
    is $tid.encode( 18446744073709551615 ), 'gzUp3uHipVr', 'encode unsigned bigint';
    is $tid.decode( 'gzUp3uHipVr' ), 18446744073709551615, 'decode unsigned bigint';
}, 'alphanumeric key';

subtest {
    my $key = ( '⠁' .. '⣿', '←' .. '⇿', '∀' .. '⋿' ).flat.pick( * ).join; # 623 characters total
    
    lives-ok { $tid = TinyID.new( key => $key ) }, 'new using braille + arrows + math symbols key';
    is $tid.decode( $tid.encode( 18446744073709551615 ) ), 18446744073709551615, 'encode and decode unsigned bigint';
}, 'very long unicode key';

subtest {
    dies-ok { TinyID.new( key => 'a' ) }, 'key too short';
    dies-ok { TinyID.new( key => 'aa' ) }, 'key contains duplicated characters';
    dies-ok { TinyID.new( key => 'ab' ).encode( -1 ) }, 'cannot encode negative number';
    dies-ok { TinyID.new( key => 'ab' ).decode( 'x' ) }, 'cannot decode string with characters not in key';
        
}, 'failures';
