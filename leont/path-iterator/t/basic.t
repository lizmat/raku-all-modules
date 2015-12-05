#! perl6

use v6;

use Test;

use Path::Iterator;

is-deeply(Path::Iterator.name(rx/\.pm$/).file.iter('lib').map(~*).list, ( 'lib/Path/Iterator.pm', ), 'Find only .pm file in lib');
is-deeply(Path::Iterator.depth(1..1).file.contents(rx/description/).iter.map(~*).list, ( 'META.info', ), 'Find only file in root that contains "description"');

done-testing();
