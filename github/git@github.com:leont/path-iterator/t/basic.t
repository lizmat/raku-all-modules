#! perl6

use v6;

use Test;

use Path::Iterator;

is-deeply(Path::Iterator.ext('pm').file.in('lib').list, ( $*SPEC.catfile(<lib Path Iterator.pm>).IO, ), 'Find only .pm file in lib - native');
is-deeply(find('lib', :ext<pm>, :file).list, ( $*SPEC.catfile(<lib Path Iterator.pm>).IO, ), 'Find only .pm file in lib - functional');
is-deeply(Path::Iterator.depth(1).skip-hidden.file.contents(rx/description/).not-empty.in.map(~*).list, ( 'META6.json', ), 'Find only file in root that contains "description" - native');
is-deeply(find(:file, :contents(rx/description/), :depth(1), :skip-hidden, :not-empty, :as(Str)).list, ( 'META6.json', ), 'Find only file in root that contains "description" - functional');

done-testing();
