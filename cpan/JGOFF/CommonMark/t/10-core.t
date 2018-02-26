use v6;
use CommonMark;
use Test;

plan 6;

is CommonMark.to-html("Hello world!"),
   "<p>Hello world!</p>\n",
   'string converts to HTML'
;
ok CommonMark.version >= 7171,
   'version is at or after 2018-02-18';
;
#is CommonMark.version-string, '0.28.3';

my $cmn = CommonMark::Node.new( :type( 7 ) );
is $cmn.type, 7, 'CommonMark node has correct type';
is $cmn.type-string, 'custom_block', 'CommonMark node has correct type name';

my $cmi = CommonMark::Iterator.new;
isa-ok( $cmi, 'CommonMark::Iterator' );

my $cmp = CommonMark::Parser.new;
isa-ok( $cmp, 'CommonMark::Parser' );

done-testing;

# vim: ft=perl6
