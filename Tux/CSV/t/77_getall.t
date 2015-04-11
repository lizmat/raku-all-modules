#!perl6

use v6;
use Slang::Tuxic;

use Test;
use Text::CSV;

my $csv = Text::CSV.new;
my $tfn = "_77test.csv";

my @testlist = (
    [ "1", "a", "\x01", "A" ],
    [ "2", "b", "\x02", "B" ],
    [ "3", "c", "\x03", "C" ],
    [ "4", "d", "\x04", "D" ],
    );

my @list;

sub un-obj (@aoo) {
    my @aoa;
    for @aoo -> @aof {
        @aoa.push ([ @aof.map (~*) ]);
        }
    return @aoa;
    } # un-obj

sub do_tests (Sub $sub) {
    $sub.(@list);
    $sub.(@list,         0);
    $sub.(@list[2,3],    2);
    $sub.([],            0,  0);
    $sub.(@list,         0, 10);
    $sub.(@list[0,1],    0,  2);
    $sub.(@list[1,2],    1,  2);
    $sub.(@list[1,2,3], -3);
    $sub.([],           -3,  0);
    $sub.(@list[1,2],   -3,  2);
    $sub.(@list[1,2,3], -3,  3);
    } # do_tests

for ("\n", "\r") -> $eol {

    @list = @testlist;

    {   ok (my $csv = Text::CSV.new (eol => $eol), "csv out EOL "~$eol.perl);
        my $fh = open $tfn, :w or die "$tfn: $!";
        ok ($csv.print ($fh, $_), "write "~$_.perl) for @list;
        $fh.close;
        }

    {   ok (my $csv = Text::CSV.new (eol => $eol), "csv out EOL "~$eol.perl);

        do_tests (anon sub (@expect, *@args) {

            my @exp = @expect; # Needed as Parcels are not Arrays $(1,2) vs [1,2]
            my $s_args = @args.join (", ");

            my $fh = open $tfn, :r or die "$tfn: $!";
            # un-obj for is_deeply
            my @f = un-obj ($csv.getline_all ($fh, |@args));
            is_deeply (@f, @exp, "getline_all ($s_args)");
            $fh.close;

            $fh = open $tfn, :r or die "$tfn: $!";
            @f = $csv.getline_all ($fh, |@args, meta => False);
            is_deeply (@f, @exp, "getline_all ($s_args, no-meta)");
            $fh.close;
            });

        my $fh = open $tfn, :r or die "$tfn: $!";
        ok ($csv.colrange ("1;4"),      "ColRange 1;4");
        ok ($csv.rowrange ("2;4"),      "RowRange 2;4");
        is_deeply (un-obj ($csv.getline_all ($fh)),
            [["2","B"],["4","D"]],      "Selection");
        }

    unlink $tfn;
    }

my Str @hdr = < A B C D >;
sub expect_hr (@expect) {
    my @expect_hr;
    for @expect -> @r {
        my %h = @hdr Z @r;
        @expect_hr.push: { %h };
        }
    return @expect_hr;
    }

for ("\n", "\r") -> $eol {

    @list   = @testlist;
    my $hdr = [ @hdr ];

    {   ok (my $csv = Text::CSV.new (eol => $eol), "csv out EOL "~$eol.perl);
        my $fh = open $tfn, :w or die "$tfn: $!";
        ok ($csv.print ($fh, $_), "write "~$_.perl) for @list;
        $fh.close;
        }

    {   ok (my $csv = Text::CSV.new (eol => $eol), "csv out EOL "~$eol.perl);

        $csv.column_names (@hdr);

        my Bool $meta = False;

        do_tests (anon sub (@expect, *@args) {

            my @exp = expect_hr (@expect);
            my $s_args = @args.join (", ");

            my $fh  = open $tfn, :r or die "$tfn: $!";
            my @f = $csv.getline_hr_all ($fh, :$meta, |@args);
            is_deeply (@f, @exp, "getline_hr_all ($s_args)");
            $fh.close;
            });

        my $fh = open $tfn, :r or die "$tfn: $!";
        ok ($csv.colrange ("1;4"),      "ColRange 1;4");
        ok ($csv.rowrange ("2;4"),      "RowRange 2;4");
        is_deeply ($csv.getline_hr_all ($fh, :$meta),
            [{:A("2"), :D("B")},{:A("4"), :D("D")}], "Selection");
        }

    unlink $tfn;
    }

done;
