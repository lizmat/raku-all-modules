use HTTP::Tinyish;
use URI::Escape;
unit package WWW::Google::Time:ver<1.001001>;

my %months = <DUMMY January February March April May June July August
    September October November December>.antipairs;

sub google-time-in (Str:D $location) is export {
    my %res = HTTP::Tinyish.new( agent => "Mozilla/5.0" ).get:
        'http://google.com/search?num=100&hl=en&safe=off&btnG=Search'
        ~ '&meta=&q=' ~ uri-escape "time in $location";

    %res<status> == 200 or fail "Received HTTP status %res<status> from Google";
    %res<content> ~~ m{
        '<div class="_rkc _Peb">'
            $<time>=(.+?)
        '</div><div class="_HOb _Qeb"> '
            $<week-day>=(\w+)
        ', <span style="white-space:nowrap">'
            $<month>=(\w+) ' ' $<month-day>=(\d+) ', '
            $<year>=(\d+)
        '</span> (' $<tz>=(.+?) ') </div><span class="_HOb _Qeb">'
            \s+ 'Time in ' $<where>=(.+?) ' </span>'
    } or fail 'Did not find time for this location';

    my %time;
    %time<time  week-day  month  month-day  year  tz  where>
    =  $/<time  week-day  month  month-day  year  tz  where>».Str;
    %time<where> ~~ s:g/'<em>' | '</em>' | '<b>' | '</b>'//;
    %time<str> = "%time<time> %time<tz>, %time<week-day>, %time<month> "
                    ~ "%time<month-day>, %time<year>";

    my ($hour, $minute) = %time<time>.match(/(\d+) ':' (\d+)/).caps».value».Int;
    $hour -= 12 if $hour == 12 and %time<time>.match: /«AM»/;
    %time<DateTime> = DateTime.new:
        year        => %time<year>,
        month       => %months{ %time<month> },
        day         => %time<month-day>,
        hour        => (
            $hour + (12 if $hour < 12 and %time<time>.match: /«PM»/)
        ),
        minute      => $minute,
        second      => (59.999 min DateTime.now.utc.second),
        timezone    => (3600 * tz-offset-for %time<tz>).Int;

    return %time;
};

sub tz-offset-for ($tz) {
    state %tzs = <
        ACDT	10.5
        ACST	9.5
        ACT	-5
        ADT	-3
        AEDT	11
        AEST	10
        AFT	4.5
        AKDT	-8
        AKST	-9
        AMST	-3
        AMT	-4
        AMT	4
        ART	-3
        AST	3
        AST	-4
        AWST	8
        AZOST	0
        AZOT	-1
        AZT	4
        BDT	8
        BIOT	6
        BIT	-12
        BOT	-4
        BRST	-2
        BRT	-3
        BST	6
        BST	11
        BST	1
        BTT	6
        CAT	2
        CCT	6.5
        CDT	-5
        CDT	-4
        CEST	2
        CET	1
        CHADT	13.75
        CHAST	12.75
        CHOT	8
        CHOST	9
        CHST	10
        CHUT	10
        CIST	-8
        CIT	8
        CKT	-10
        CLST	-3
        CLT	-4
        COST	-4
        COT	-5
        CST	-6
        CST	8
        ACST	9.5
        ACDT	10.5
        CST	-5
        CT	8
        CVT	-1
        CWST	8.75
        CXT	7
        DAVT	7
        DDUT	10
        DFT	1
        EASST	-5
        EAST	-6
        EAT	3
        ECT	-4
        ECT	-5
        EDT	-4
        AEDT	11
        EEST	3
        EET	2
        EGST	0
        EGT	-1
        EIT	9
        EST	-5
        AEST	10
        FET	3
        FJT	12
        FKST	-3
        FKT	-4
        FNT	-2
        GALT	-6
        GAMT	-9
        GET	4
        GFT	-3
        GILT	12
        GIT	-9
        GMT	0
        GST	-2
        GST	4
        GYT	-4
        HADT	-9
        HAEC	2
        HAST	-10
        HKT	8
        HMT	5
        HOVST	8
        HOVT	7
        ICT	7
        IDT	3
        IOT	3
        IRDT	4.5
        IRKT	8
        IRST	3.5
        IST	5.5
        IST	1
        IST	2
        JST	9
        KGT	6
        KOST	11
        KRAT	7
        KST	9
        LHST	10.5
        LHST	11
        LINT	14
        MAGT	12
        MART	-9.5
        MAWT	5
        MDT	-6
        MET	1
        MEST	2
        MHT	12
        MIST	11
        MIT	-9.5
        MMT	6.5
        MSK	3
        MST	8
        MST	-7
        MUT	4
        MVT	5
        MYT	8
        NCT	11
        NDT	-2.5
        NFT	11
        NPT	5.75
        NST	-3.5
        NT	-3.5
        NUT	-11
        NZDT	13
        NZST	12
        OMST	6
        ORAT	5
        PDT	-7
        PET	-5
        PETT	12
        PGT	10
        PHOT	13
        PHT	8
        PKT	5
        PMDT	-2
        PMST	-3
        PONT	11
        PST	-8
        PST	8
        PYST	-3
        PYT	-4
        RET	4
        ROTT	-3
        SAKT	11
        SAMT	4
        SAST	2
        SBT	11
        SCT	4
        SGT	8
        SLST	5.5
        SRET	11
        SRT	-3
        SST	-11
        SST	8
        SYOT	3
        TAHT	-10
        THA	7
        TFT	5
        TJT	5
        TKT	13
        TLT	9
        TMT	5
        TRT	3
        TOT	13
        TVT	12
        ULAST	9
        ULAT	8
        USZ1	2
        UTC	0
        UYST	-2
        UYT	-3
        UZT	5
        VET	-4
        VLAT	10
        VOLT	4
        VOST	6
        VUT	11
        WAKT	12
        WAST	2
        WAT	1
        WEST	1
        WET	0
        WIT	7
        WST	8
        YAKT	9
        YEKT	5
        >;

    if $tz ~~ /^ 'GMT' [ $<neg>='-' | '+' ] $<h>=\d+ [':' $<m>=\d+ ]?/ {
        return ($<neg> ?? -1 !! 1) * ($<h> + ($<m>//0)/60);
    }
    (%tzs{ $tz } // 0).Numeric;
}
