#!/usr/bin/env perl6

use Test;
use lib 'lib';
use Image::Libexif;
use Image::Libexif::Constants;

my Image::Libexif $e2;

subtest {
  my Image::Libexif $e1 .= new;
  isa-ok $e1, Image::Libexif, 'simple initialization';
  lives-ok { $e1.open: 't/sample01.jpg' }, 'open existent file';
  throws-like { $e1.open: 'nonexistent' },
             X::Libexif,
             message => /'File nonexistent not found'/,
             'throws if file not found';
  $e2 .= new: :file('t/sample01.jpg');
  isa-ok $e2, Image::Libexif, 'initialization from file';
  throws-like
    { Image::Libexif.new: :file('nonexistent') }, # No assignment: it would throw
    X::Libexif,
    message => /'File nonexistent not found'/,
    'Open non-existent file fails';
  my $buffer = slurp 't/sample01.jpg', :bin;
  my Image::Libexif $e3 .= new: :data($buffer);
  isa-ok $e3, Image::Libexif, 'initialization from raw data';
  lives-ok { $e3.close }, 'close and free';
  my Image::Libexif $e4 .= new;
  $e4.load: $buffer;
  isa-ok $e4, Image::Libexif, 'load buffer data';
  cmp-ok $e4.alltags».keys.flat.elems, '==', 54, 'loaded tags';
  lives-ok {my @promises;
            for ^5 {@promises.push: start {my $ee = Image::Libexif.new: :file('t/sample01.jpg'); sleep .1; $ee.close}}
            await @promises},
          'concurrency';
}, 'initialization';

my %info = $e2.info;
is-deeply %info, {:datatype(4), :ordercode(1), :orderstr("Intel"), :tagcount(54)}, 'info';

subtest {
  is $e2.lookup(EXIF_TAG_MAKE), 'FUJIFILM', 'tag lookup constant';
  is $e2.lookup(0x010f), 'FUJIFILM', 'tag lookup (Int)';
  is-deeply $e2.tags(IMAGE_INFO), {"0x010f" => "FUJIFILM", "0x0110" => "FinePix F200EXR", "0x0112" => "Top-left",
                          "0x011a" => "72", "0x011b" => "72", "0x0128" => "Inch", "0x0131" => "GIMP 2.8.20",
                          "0x0132" => "2017:05:14 17:19:31", "0x0213" => "Co-sited",
                          "0x8298" => "[None] (Photographer) - [None] (Editor)", "0xc4a5" => "28 bytes undefined data"},
            'tags in ifd0';
  my %tags = $e2.tags(IMAGE_INFO, :tagdesc);
  is %tags<0xc4a5>[1], ‘Related to Epson's PRINT Image Matching technology’, 'tag description';
  my @alltags = $e2.alltags(:tagdesc);
  my $numkeys = @alltags».keys.flat.elems;
  cmp-ok $numkeys, '==', 54, 'alltags elems';
  is @alltags[IMAGE_INFO]<0xc4a5>[1], ‘Related to Epson's PRINT Image Matching technology’, 'alltags description';
  my @nalltags = $e2.alltags;
  ok all(
    gather {
      for ^5 -> $g {
        for @nalltags[$g].keys {
          take $e2.lookup(+$_, $g) eq @nalltags[$g]«{sprintf("0x%04x ", $_)}»;
        }
      }
    }
  ), 'alltags and lookup get the same values';
}, 'tags';

is ($e2.notes)[0], 'This number is unique and based on the date of manufacture. SerialNumber Serial Number FC  A4947710     592D32353433090328BC03301334D5', 'mnotes';

done-testing;
