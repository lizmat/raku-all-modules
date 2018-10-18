#!/usr/bin/env perl6

use nqp;
use Getopt::Advance;

my OptionSet $os .= new;

$os.push(
    'c=a',
    'c source file extension list.',
    value => [ "c", ]
);
$os.push(
    'h=a',
    'head file extension list.',
    value => [ "h", ]
);
$os.push(
    'cpp|=a',
    'cpp source file extension list.',
    value => Q :w ! C cpp c++ cxx hpp cc h++ hh hxx!
);
$os.push(
    'cfg|=a',
    'config file extension list.',
    value => Q :w ! ini config conf cfg xml !
);
$os.push(
    'm=a',
    'makefile extension list.',
    value => ["mk", ]
);
$os.push(
    'w=a',
    'match whole filename.',
    value => Q :w ! makefile Makefile !
);
$os.push(
    'a=a',
    'addition extension list.',
);
$os.push(
    'i=b',
    'enable ignore case mode.'
);
$os.push(
    'no|=a',
    'exclude file category.',
);
$os.push(
    'only|=s',
    'only search given category.',
);
$os.push(
    'd|debug=b',
    'print debug message.'
);
my $id = $os.insert-pos(
    "directory",
    sub find-and-print-source($os, $dira) {
        my @stack = $dira.value;
        my %ext := set (
            with $os<only> {
                fail "Not recognized category: {$_}." unless $_ (elem) < c h cpp cfg m a w >;
                $os<only> eq "w" ?? [] !! ($os{$_} // []);
            } else {
                my @ext = [];
                for < c h cpp cfg m a > {
                    if $_ !(elem) @($os<no>) {
                        @ext.append($os{$_} // []);
                    }
                }
                @ext;
            }
        );
        my %whole := set($os.get('only').has-value && $os<only> ne "w" ?? [] !! ($os<w> // []));

        note "GET ALL EXT => ", %ext if $os<d>;

        my $supplier = Supplier.new;

        $supplier.Supply.tap( sub (\v) {
            put Q :qq '"{v}"';
        });

        while @stack {
            note "CURR FILES => ", @stack if $os<d>;
            my @stack-t = (@stack.race.map(
                                  sub ($_) {
                                      note "\t|GOT FILE => ", $_ if $os<d>;
                                      if nqp::lstat(nqp::unbox_s($_), nqp::const::STAT_ISDIR) == 1 {
                                          return .&getSubFiles;
                                      } else {
                                          my $fp = &basename($_);
                                          if $fp.substr(($fp.rindex(".") // -1) + 1) (elem) %ext {
                                              $supplier.emit($_);
                                          }  elsif $os<w>.defined && $fp (elem) %whole {
                                              $supplier.emit($_);
                                          }
                                      }
                                      return ();
                                  }
                              ).flat);
            @stack = @stack-t;
        };
    },
    :last
);

&getopt($os);

sub basename($filepath) {
    return $filepath.substr(($filepath.rindex('/') // -1) + 1);
}

sub getSubFiles($path) {
    my @ret := [];
    my $dh := nqp::opendir($path);

    while (my $f = nqp::nextfiledir($dh)) {
        @ret.push("$path/$f") if $f ne ".." && $f ne ".";
    }

    nqp::closedir($dh);

    return @ret;
}
