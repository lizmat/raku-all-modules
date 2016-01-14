#! perl6

use v6;

use Test;

use Path::Iterator;

is-deeply(Path::Iterator.ext('pm').file.in('lib').list, ( 'lib/Path/Iterator.pm'.IO, ), 'Find only .pm file in lib - native');
is-deeply(find('lib', :ext<pm>, :file).list, ( 'lib/Path/Iterator.pm'.IO, ), 'Find only .pm file in lib - functional');
is-deeply(Path::Iterator.depth(1).skip-hidden.file.contents(rx/description/).in.map(~*).list, ( 'META.info', ), 'Find only file in root that contains "description" - native');
is-deeply(find(:file, :contents(rx/description/), :depth(1), :skip-hidden, :as(Str)).list, ( 'META.info', ), 'Find only file in root that contains "description" - functional');

done-testing();
