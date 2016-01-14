use IRC::Client::Plugin;
use WWW::Google::Time;
use Lingua::Conjunction;
use Number::Denominate;

unit class IRC::Client::Plugin::HNY:ver<1.001001> is IRC::Client::Plugin;

has Int $.short-announcement-at = 400;

method irc-connected ($irc) {
    my $utc-hny = utc-hny;
    $irc.debug and say "UTC HNY is $utc-hny";
    my $prev-offset = now + 10;
    for get-tzs().reverse -> $tz {
        my $tz-offset = $utc-hny.Instant - $tz<offset>*3600;
        next if $tz-offset - now <= 0;
        my $next-new-year = $tz-offset - $prev-offset;
        Promise.at( $prev-offset + 2 ).then: {
            announce-hny $irc, $tz,
                :next-new-year($next-new-year),
                :$!short-announcement-at;

            CATCH { warn .backtrace }
        };
        Promise.at( $tz-offset ).then: {
            announce-hny $irc, $tz, :$!short-announcement-at;
            CATCH { warn .backtrace }
        };
        $prev-offset = $tz-offset;
    }
    # say denominate $utc-hny.Instant - (DateTime.now.utc.Instant + (-5*3600) );
}

method irc-privmsg-me ($irc, $e) { irc-me $irc, $e; }
method irc-notice-me ($irc, $e) { irc-me $irc, $e; }
method irc-privmsg ($irc, $e) {
    say "WTF? $e";
    return IRC_NOT_HANDLED unless $e<params>[1] ~~ /"{$irc.nick}"/;
    irc-me $irc, $e;
}

sub irc-me ($irc, $e) {
    $irc.debug and say "HNY PLUGIN: triggered HNY";
    my $command = $e<params>[1].subst: /^ "{$irc.nick}" \s* <[,:]>? \s*/, '';
    say "HNY PLUGIN: $command";
    return IRC_NOT_HANDLED
        unless $command ~~ /^ \s* 'hny' [\s+ $<loc>=.+]?/;

    $irc.debug and say "HNY PLUGIN: Looking up HNY in $<loc>";
    if ( $<loc>.chars ) {
        $irc.privmsg: $e<params>[0], lookup-hny ~$<loc>;
    }

    return IRC_NOT_HANDLED;
}

sub lookup-hny (Str $where) {
    my $gt = try google-time-in $where
        or return "I don't know what location that is";
    my $offset = 0;
    if $gt<tz> ~~ /^ 'GMT' $<offset>=(<[+-]> \d+)/ {
        $offset = $/<offset>;
    }
    else {
        my $abbr = get-tz-abbr().grep(*<abbr> eq $gt<tz>).first;
        $abbr and $offset = $abbr<offset>;
    }
    say "Offset is $offset";
    my $when = utc-hny().Instant - $offset*3600 - now;
    return "New Year already happened in $gt<where>" if $when <= 0;
    return "New Year in $gt<where> will happen in "
        ~ denominate utc-hny().Instant - $offset*3600 - now ;
}

sub announce-hny (
    $irc, Hash $tz,
    :$next-new-year,
    Int     :$short-announcement-at
) {
    my @countries;
    for |$tz<countries> -> $country {
        @countries.append: $country<name> ~ (
            $country<cities>.elems ?? " [{conjunction $country<cities>}]" !! ''
        );
    }

    my $prefix = $next-new-year
        ?? "Next New Year is in {denominate $next-new-year} in"
        !! 'Happy New Year to';

    say "PREFIX DEBUG: $prefix [$next-new-year]";
    my $res = "$prefix {conjunction @countries}";
    $res = "$prefix {conjunction $tz<countries>.map: *<name>}"
        if $res.chars > $short-announcement-at;

    for $irc.channels -> $chan {
        $irc.privmsg: $chan, $_ for $res.comb: /. ** 1..400/;
    }
}

sub utc-hny {
    %*ENV<CUSTOM-NOW-TIME> and do {
        say "Using custom time %*ENV<CUSTOM-NOW-TIME>";
        return DateTime.new: %*ENV<CUSTOM-NOW-TIME>.Int;
    };

    my $now-utc = DateTime.now.utc;
    my $year = $now-utc.month == any(6..12)
        ?? $now-utc.year+1 !! $now-utc.year;

    return $now-utc.clone:
        :year($year) :month(1) :day(1) :hour(0) :minute(0) :second(0);
}

sub get-tz-abbr {
    return (
    {
      'offset' => 1,
      'abbr' => 'A'
    },
    {
      'offset' => '10.5',
      'abbr' => 'ACDT'
    },
    {
      'offset' => '9.5',
      'abbr' => 'ACST'
    },
    {
      'abbr' => 'ACT',
      'offset' => -5
    },
    {
      'offset' => '10.5',
      'abbr' => 'ACT'
    },
    {
      'offset' => '8.75',
      'abbr' => 'ACWST'
    },
    {
      'abbr' => 'ADT',
      'offset' => 3
    },
    {
      'abbr' => 'ADT',
      'offset' => -3
    },
    {
      'offset' => 11,
      'abbr' => 'AEDT'
    },
    {
      'abbr' => 'AEST',
      'offset' => 10
    },
    {
      'abbr' => 'AET',
      'offset' => 11
    },
    {
      'offset' => '4.5',
      'abbr' => 'AFT'
    },
    {
      'offset' => -8,
      'abbr' => 'AKDT'
    },
    {
      'abbr' => 'AKST',
      'offset' => -9
    },
    {
      'abbr' => 'ALMT',
      'offset' => 6
    },
    {
      'offset' => -3,
      'abbr' => 'AMST'
    },
    {
      'offset' => 5,
      'abbr' => 'AMST'
    },
    {
      'abbr' => 'AMT',
      'offset' => -4
    },
    {
      'abbr' => 'AMT',
      'offset' => 4
    },
    {
      'offset' => 12,
      'abbr' => 'ANAST'
    },
    {
      'offset' => 12,
      'abbr' => 'ANAT'
    },
    {
      'offset' => 5,
      'abbr' => 'AQTT'
    },
    {
      'abbr' => 'ART',
      'offset' => -3
    },
    {
      'offset' => 3,
      'abbr' => 'AST'
    },
    {
      'offset' => -4,
      'abbr' => 'AST'
    },
    {
      'abbr' => 'AT',
      'offset' => -4
    },
    {
      'abbr' => 'AWDT',
      'offset' => 9
    },
    {
      'abbr' => 'AWST',
      'offset' => 8
    },
    {
      'abbr' => 'AZOST',
      'offset' => 0
    },
    {
      'offset' => -1,
      'abbr' => 'AZOT'
    },
    {
      'offset' => 5,
      'abbr' => 'AZST'
    },
    {
      'offset' => 4,
      'abbr' => 'AZT'
    },
    {
      'offset' => -12,
      'abbr' => 'AoE'
    },
    {
      'abbr' => 'B',
      'offset' => 2
    },
    {
      'abbr' => 'BNT',
      'offset' => 8
    },
    {
      'offset' => -4,
      'abbr' => 'BOT'
    },
    {
      'offset' => -2,
      'abbr' => 'BRST'
    },
    {
      'abbr' => 'BRT',
      'offset' => -3
    },
    {
      'abbr' => 'BST',
      'offset' => 6
    },
    {
      'offset' => 11,
      'abbr' => 'BST'
    },
    {
      'abbr' => 'BST',
      'offset' => 1
    },
    {
      'offset' => 6,
      'abbr' => 'BTT'
    },
    {
      'abbr' => 'C',
      'offset' => 3
    },
    {
      'offset' => 8,
      'abbr' => 'CAST'
    },
    {
      'offset' => 2,
      'abbr' => 'CAT'
    },
    {
      'abbr' => 'CCT',
      'offset' => '6.5'
    },
    {
      'abbr' => 'CDT',
      'offset' => -5
    },
    {
      'abbr' => 'CDT',
      'offset' => -4
    },
    {
      'abbr' => 'CEST',
      'offset' => 2
    },
    {
      'abbr' => 'CET',
      'offset' => 1
    },
    {
      'offset' => '13.75',
      'abbr' => 'CHADT'
    },
    {
      'abbr' => 'CHAST',
      'offset' => '12.75'
    },
    {
      'abbr' => 'CHOT',
      'offset' => 8
    },
    {
      'offset' => 10,
      'abbr' => 'CHUT'
    },
    {
      'abbr' => 'CIDST',
      'offset' => -4
    },
    {
      'offset' => -5,
      'abbr' => 'CIST'
    },
    {
      'abbr' => 'CKT',
      'offset' => -10
    },
    {
      'offset' => -3,
      'abbr' => 'CLST'
    },
    {
      'offset' => -3,
      'abbr' => 'CLT'
    },
    {
      'abbr' => 'COT',
      'offset' => -5
    },
    {
      'offset' => -6,
      'abbr' => 'CST'
    },
    {
      'offset' => 8,
      'abbr' => 'CST'
    },
    {
      'abbr' => 'CST',
      'offset' => -5
    },
    {
      'abbr' => 'CT',
      'offset' => -6
    },
    {
      'abbr' => 'CVT',
      'offset' => -1
    },
    {
      'offset' => 7,
      'abbr' => 'CXT'
    },
    {
      'abbr' => 'ChST',
      'offset' => 10
    },
    {
      'offset' => 4,
      'abbr' => 'D'
    },
    {
      'abbr' => 'DAVT',
      'offset' => 7
    },
    {
      'offset' => 10,
      'abbr' => 'DDUT'
    },
    {
      'abbr' => 'E',
      'offset' => 5
    },
    {
      'offset' => -5,
      'abbr' => 'EASST'
    },
    {
      'offset' => -5,
      'abbr' => 'EAST'
    },
    {
      'offset' => 3,
      'abbr' => 'EAT'
    },
    {
      'abbr' => 'ECT',
      'offset' => -5
    },
    {
      'offset' => -4,
      'abbr' => 'EDT'
    },
    {
      'offset' => 3,
      'abbr' => 'EEST'
    },
    {
      'offset' => 2,
      'abbr' => 'EET'
    },
    {
      'offset' => 0,
      'abbr' => 'EGST'
    },
    {
      'offset' => -1,
      'abbr' => 'EGT'
    },
    {
      'offset' => -5,
      'abbr' => 'EST'
    },
    {
      'abbr' => 'ET',
      'offset' => -5
    },
    {
      'offset' => 6,
      'abbr' => 'F'
    },
    {
      'offset' => 3,
      'abbr' => 'FET'
    },
    {
      'offset' => 13,
      'abbr' => 'FJST'
    },
    {
      'offset' => 12,
      'abbr' => 'FJT'
    },
    {
      'abbr' => 'FKST',
      'offset' => -3
    },
    {
      'offset' => -4,
      'abbr' => 'FKT'
    },
    {
      'abbr' => 'FNT',
      'offset' => -2
    },
    {
      'offset' => 7,
      'abbr' => 'G'
    },
    {
      'abbr' => 'GALT',
      'offset' => -6
    },
    {
      'abbr' => 'GAMT',
      'offset' => -9
    },
    {
      'offset' => 4,
      'abbr' => 'GET'
    },
    {
      'abbr' => 'GFT',
      'offset' => -3
    },
    {
      'offset' => 12,
      'abbr' => 'GILT'
    },
    {
      'offset' => 0,
      'abbr' => 'GMT'
    },
    {
      'offset' => 4,
      'abbr' => 'GST'
    },
    {
      'abbr' => 'GST',
      'offset' => -2
    },
    {
      'offset' => -4,
      'abbr' => 'GYT'
    },
    {
      'abbr' => 'H',
      'offset' => 8
    },
    {
      'offset' => -9,
      'abbr' => 'HADT'
    },
    {
      'offset' => -10,
      'abbr' => 'HAST'
    },
    {
      'offset' => 8,
      'abbr' => 'HKT'
    },
    {
      'abbr' => 'HOVT',
      'offset' => 7
    },
    {
      'offset' => 9,
      'abbr' => 'I'
    },
    {
      'abbr' => 'ICT',
      'offset' => 7
    },
    {
      'offset' => 3,
      'abbr' => 'IDT'
    },
    {
      'abbr' => 'IOT',
      'offset' => 6
    },
    {
      'offset' => '4.5',
      'abbr' => 'IRDT'
    },
    {
      'offset' => 9,
      'abbr' => 'IRKST'
    },
    {
      'abbr' => 'IRKT',
      'offset' => 8
    },
    {
      'offset' => '3.5',
      'abbr' => 'IRST'
    },
    {
      'abbr' => 'IST',
      'offset' => '5.5'
    },
    {
      'offset' => 1,
      'abbr' => 'IST'
    },
    {
      'offset' => 2,
      'abbr' => 'IST'
    },
    {
      'offset' => 9,
      'abbr' => 'JST'
    },
    {
      'abbr' => 'K',
      'offset' => 10
    },
    {
      'abbr' => 'KGT',
      'offset' => 6
    },
    {
      'abbr' => 'KOST',
      'offset' => 11
    },
    {
      'abbr' => 'KRAST',
      'offset' => 8
    },
    {
      'abbr' => 'KRAT',
      'offset' => 7
    },
    {
      'abbr' => 'KST',
      'offset' => 9
    },
    {
      'offset' => 4,
      'abbr' => 'KUYT'
    },
    {
      'offset' => 11,
      'abbr' => 'L'
    },
    {
      'offset' => 11,
      'abbr' => 'LHDT'
    },
    {
      'offset' => '10.5',
      'abbr' => 'LHST'
    },
    {
      'offset' => 14,
      'abbr' => 'LINT'
    },
    {
      'abbr' => 'M',
      'offset' => 12
    },
    {
      'abbr' => 'MAGST',
      'offset' => 12
    },
    {
      'offset' => 10,
      'abbr' => 'MAGT'
    },
    {
      'abbr' => 'MART',
      'offset' => '-8.5'
    },
    {
      'abbr' => 'MAWT',
      'offset' => 5
    },
    {
      'offset' => -6,
      'abbr' => 'MDT'
    },
    {
      'abbr' => 'MHT',
      'offset' => 12
    },
    {
      'abbr' => 'MMT',
      'offset' => '6.5'
    },
    {
      'offset' => 4,
      'abbr' => 'MSD'
    },
    {
      'abbr' => 'MSK',
      'offset' => 3
    },
    {
      'abbr' => 'MST',
      'offset' => -7
    },
    {
      'offset' => -7,
      'abbr' => 'MT'
    },
    {
      'abbr' => 'MUT',
      'offset' => 4
    },
    {
      'offset' => 5,
      'abbr' => 'MVT'
    },
    {
      'abbr' => 'MYT',
      'offset' => 8
    },
    {
      'offset' => -1,
      'abbr' => 'N'
    },
    {
      'abbr' => 'NCT',
      'offset' => 11
    },
    {
      'offset' => '-1.5',
      'abbr' => 'NDT'
    },
    {
      'offset' => 11,
      'abbr' => 'NFT'
    },
    {
      'offset' => 7,
      'abbr' => 'NOVST'
    },
    {
      'offset' => 6,
      'abbr' => 'NOVT'
    },
    {
      'offset' => '5.75',
      'abbr' => 'NPT'
    },
    {
      'abbr' => 'NRT',
      'offset' => 12
    },
    {
      'offset' => '-2.5',
      'abbr' => 'NST'
    },
    {
      'offset' => -11,
      'abbr' => 'NUT'
    },
    {
      'abbr' => 'NZDT',
      'offset' => 13
    },
    {
      'offset' => 12,
      'abbr' => 'NZST'
    },
    {
      'offset' => -2,
      'abbr' => 'O'
    },
    {
      'offset' => 7,
      'abbr' => 'OMSST'
    },
    {
      'offset' => 6,
      'abbr' => 'OMST'
    },
    {
      'offset' => 5,
      'abbr' => 'ORAT'
    },
    {
      'offset' => -3,
      'abbr' => 'P'
    },
    {
      'abbr' => 'PDT',
      'offset' => -7
    },
    {
      'offset' => -5,
      'abbr' => 'PET'
    },
    {
      'abbr' => 'PETST',
      'offset' => 12
    },
    {
      'abbr' => 'PETT',
      'offset' => 12
    },
    {
      'abbr' => 'PGT',
      'offset' => 10
    },
    {
      'offset' => 13,
      'abbr' => 'PHOT'
    },
    {
      'abbr' => 'PHT',
      'offset' => 8
    },
    {
      'offset' => 5,
      'abbr' => 'PKT'
    },
    {
      'abbr' => 'PMDT',
      'offset' => -2
    },
    {
      'offset' => -3,
      'abbr' => 'PMST'
    },
    {
      'abbr' => 'PONT',
      'offset' => 11
    },
    {
      'offset' => -8,
      'abbr' => 'PST'
    },
    {
      'abbr' => 'PST',
      'offset' => -8
    },
    {
      'offset' => -8,
      'abbr' => 'PT'
    },
    {
      'abbr' => 'PWT',
      'offset' => 9
    },
    {
      'abbr' => 'PYST',
      'offset' => -3
    },
    {
      'abbr' => 'PYT',
      'offset' => -4
    },
    {
      'abbr' => 'Q',
      'offset' => -4
    },
    {
      'offset' => 6,
      'abbr' => 'QYZT'
    },
    {
      'offset' => -5,
      'abbr' => 'R'
    },
    {
      'offset' => 4,
      'abbr' => 'RET'
    },
    {
      'abbr' => 'ROTT',
      'offset' => -3
    },
    {
      'offset' => -6,
      'abbr' => 'S'
    },
    {
      'offset' => 10,
      'abbr' => 'SAKT'
    },
    {
      'offset' => 4,
      'abbr' => 'SAMT'
    },
    {
      'offset' => 2,
      'abbr' => 'SAST'
    },
    {
      'offset' => 11,
      'abbr' => 'SBT'
    },
    {
      'abbr' => 'SCT',
      'offset' => 4
    },
    {
      'offset' => 8,
      'abbr' => 'SGT'
    },
    {
      'offset' => 11,
      'abbr' => 'SRET'
    },
    {
      'abbr' => 'SRT',
      'offset' => -3
    },
    {
      'abbr' => 'SST',
      'offset' => -11
    },
    {
      'offset' => 3,
      'abbr' => 'SYOT'
    },
    {
      'abbr' => 'T',
      'offset' => -7
    },
    {
      'offset' => -10,
      'abbr' => 'TAHT'
    },
    {
      'offset' => 5,
      'abbr' => 'TFT'
    },
    {
      'abbr' => 'TJT',
      'offset' => 5
    },
    {
      'abbr' => 'TKT',
      'offset' => 13
    },
    {
      'abbr' => 'TLT',
      'offset' => 9
    },
    {
      'abbr' => 'TMT',
      'offset' => 5
    },
    {
      'abbr' => 'TOT',
      'offset' => 13
    },
    {
      'abbr' => 'TVT',
      'offset' => 12
    },
    {
      'offset' => -8,
      'abbr' => 'U'
    },
    {
      'offset' => 8,
      'abbr' => 'ULAT'
    },
    {
      'offset' => -2,
      'abbr' => 'UYST'
    },
    {
      'abbr' => 'UYT',
      'offset' => -3
    },
    {
      'offset' => 5,
      'abbr' => 'UZT'
    },
    {
      'abbr' => 'V',
      'offset' => -9
    },
    {
      'abbr' => 'VET',
      'offset' => '-3.5'
    },
    {
      'offset' => 11,
      'abbr' => 'VLAST'
    },
    {
      'abbr' => 'VLAT',
      'offset' => 10
    },
    {
      'abbr' => 'VOST',
      'offset' => 6
    },
    {
      'offset' => 11,
      'abbr' => 'VUT'
    },
    {
      'offset' => -10,
      'abbr' => 'W'
    },
    {
      'offset' => 12,
      'abbr' => 'WAKT'
    },
    {
      'offset' => -3,
      'abbr' => 'WARST'
    },
    {
      'abbr' => 'WAST',
      'offset' => 2
    },
    {
      'offset' => 1,
      'abbr' => 'WAT'
    },
    {
      'abbr' => 'WEST',
      'offset' => 1
    },
    {
      'offset' => 0,
      'abbr' => 'WET'
    },
    {
      'offset' => 12,
      'abbr' => 'WFT'
    },
    {
      'abbr' => 'WGST',
      'offset' => -2
    },
    {
      'offset' => -3,
      'abbr' => 'WGT'
    },
    {
      'offset' => 7,
      'abbr' => 'WIB'
    },
    {
      'abbr' => 'WIT',
      'offset' => 9
    },
    {
      'abbr' => 'WITA',
      'offset' => 8
    },
    {
      'abbr' => 'WST',
      'offset' => 13
    },
    {
      'offset' => 1,
      'abbr' => 'WST'
    },
    {
      'abbr' => 'WT',
      'offset' => 0
    },
    {
      'offset' => -11,
      'abbr' => 'X'
    },
    {
      'offset' => -12,
      'abbr' => 'Y'
    },
    {
      'offset' => 10,
      'abbr' => 'YAKST'
    },
    {
      'offset' => 9,
      'abbr' => 'YAKT'
    },
    {
      'abbr' => 'YAPT',
      'offset' => 10
    },
    {
      'abbr' => 'YEKST',
      'offset' => 6
    },
    {
      'offset' => 5,
      'abbr' => 'YEKT'
    },
    {
      'abbr' => 'Z',
      'offset' => 0
    }
    );
}

sub get-tzs {
    return (
    {
                'offset' => '-12',
                'countries' => [
                                 {
                                   'name' => 'U.S. Minor Outlying Islands',
                                   'cities' => [
                                                 'Baker Island',
                                                 'Howland Island',
                                               ]
                                 },
                               ]
              },
              {
                'offset' => '-11',
                'countries' => [
                                 {
                                   'name' => 'American Samoa',
                                   'cities' => [
                                                 'Pago Pago',
                                               ]
                                 },
                                 {
                                   'name' => 'Niue',
                                   'cities' => [
                                                 'Alofi',
                                               ]
                                 },
                                 {
                                   'name' => 'U.S. Minor Outlying Islands',
                                   'cities' => [
                                                 'Itascatown pre-WW2',
                                               ]
                                 },
                               ]
              },
              {
                'countries' => [
                                 {
                                   'name' => 'Cook Islands',
                                   'cities' => [
                                                 'Avarua',
                                               ]
                                 },
                                 {
                                   'name' => 'French Polynesia',
                                   'cities' => [
                                                 'Papeete',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Millersville - pre-WW2 settlement',
                                               ],
                                   'name' => 'U.S. Minor Outlying Islands'
                                 },
                                 {
                                   'name' => 'United States',
                                   'cities' => [
                                                 'Hawaii',
                                                 'Honolulu',
                                               ]
                                 },
                               ],
                'offset' => '-10'
              },
              {
                'offset' => '-8.5',
                'countries' => [
                                 {
                                   'name' => 'French Polynesia',
                                   'cities' => [
                                                 'Atuona',
                                               ]
                                 },
                               ]
              },
              {
                'offset' => '-9',
                'countries' => [
                                 {
                                   'name' => 'French Polynesia',
                                   'cities' => [
                                                 'Rikitea',
                                               ]
                                 },
                                 {
                                   'name' => 'United States',
                                   'cities' => [
                                                 'Alaska',
                                                 'Anchorage',
                                               ]
                                 },
                               ]
              },
              {
                'offset' => '-8',
                'countries' => [
                                 {
                                   'cities' => [
                                                 'British Columbia',
                                                 'Surrey',
                                                 'Vancouver',
                                                 'Yukon',
                                               ],
                                   'name' => 'Canada'
                                 },
                                 {
                                   'name' => 'Mexico',
                                   'cities' => [
                                                 'Mexicali',
                                                 'Tijuana',
                                               ]
                                 },
                                 {
                                   'name' => 'Pitcairn Islands',
                                   'cities' => [
                                                 'Adamstown',
                                               ]
                                 },
                                 {
                                   'name' => 'United States',
                                   'cities' => [
                                                 'California',
                                                 'Los Angeles',
                                                 'Nevada',
                                                 'Oregon',
                                                 'San Diego',
                                                 'San Francisco',
                                                 'San Jose',
                                                 'Seattle',
                                                 'Washington',
                                               ]
                                 },
                               ]
              },
              {
                'countries' => [
                                 {
                                   'cities' => [
                                                 'Alberta',
                                                 'Calgary',
                                                 'Edmonton',
                                                 'Northwest Territories',
                                                 'Nunavut',
                                               ],
                                   'name' => 'Canada'
                                 },
                                 {
                                   'name' => 'Mexico',
                                   'cities' => [
                                                 'Chihuahua',
                                                 "Ciudad Ju\x[e1]rez",
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Albuquerque',
                                                 'Arizona',
                                                 'Colorado',
                                                 'Denver',
                                                 'El Paso',
                                                 'Idaho',
                                                 'Montana',
                                                 'New Mexico',
                                                 'Phoenix',
                                                 'Utah',
                                                 'Wyoming',
                                               ],
                                   'name' => 'United States'
                                 },
                               ],
                'offset' => '-7'
              },
              {
                'offset' => '-6',
                'countries' => [
                                 {
                                   'name' => 'Belize',
                                   'cities' => [
                                                 'Belmopan',
                                               ]
                                 },
                                 {
                                   'name' => 'Canada',
                                   'cities' => [
                                                 'Manitoba',
                                                 'Regina',
                                                 'Saskatchewan',
                                                 'Saskatoon',
                                                 'Winnipeg',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 "Lim\x[f3]n",
                                                 "San Jos\x[e9]",
                                               ],
                                   'name' => 'Costa Rica'
                                 },
                                 {
                                   'cities' => [
                                                 'Puerto Ayora',
                                               ],
                                   'name' => 'Ecuador'
                                 },
                                 {
                                   'cities' => [
                                                 'San Salvador',
                                                 'Santa Ana',
                                               ],
                                   'name' => 'El Salvador'
                                 },
                                 {
                                   'name' => 'Guatemala',
                                   'cities' => [
                                                 'Guatemala City',
                                               ]
                                 },
                                 {
                                   'name' => 'Honduras',
                                   'cities' => [
                                                 'San Pedro Sula',
                                                 'Tegucigalpa',
                                               ]
                                 },
                                 {
                                   'name' => 'Mexico',
                                   'cities' => [
                                                 'Ciudad Neza',
                                                 'Ecatepec de Morelos',
                                                 'Guadalajara',
                                                 "Le\x[f3]n",
                                                 'Mexico City',
                                                 'Monterrey',
                                                 'Puebla',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 "Le\x[f3]n",
                                                 'Managua',
                                               ],
                                   'name' => 'Nicaragua'
                                 },
                                 {
                                   'cities' => [
                                                 'Alabama',
                                                 'Arkansas',
                                                 'Austin',
                                                 'Chicago',
                                                 'Dallas',
                                                 'Fort Worth',
                                                 'Houston',
                                                 'Illinois',
                                                 'Iowa',
                                                 'Kansas',
                                                 'Kansas City',
                                                 'Louisiana',
                                                 'Memphis',
                                                 'Milwaukee',
                                                 'Minneapolis',
                                                 'Minnesota',
                                                 'Mississippi',
                                                 'Missouri',
                                                 'Nashville',
                                                 'Nebraska',
                                                 'North Dakota',
                                                 'Oklahoma',
                                                 'Oklahoma City',
                                                 'Omaha',
                                                 'San Antonio',
                                                 'South Dakota',
                                                 'Tennessee',
                                                 'Texas',
                                                 'Tulsa',
                                                 'Wisconsin',
                                               ],
                                   'name' => 'United States'
                                 },
                               ]
              },
              {
                'countries' => [
                                 {
                                   'name' => 'Bahamas',
                                   'cities' => [
                                                 'Nassau',
                                               ]
                                 },
                                 {
                                   'name' => 'Brazil',
                                   'cities' => [
                                                 'Acre',
                                                 'Rio Branco',
                                               ]
                                 },
                                 {
                                   'name' => 'Canada',
                                   'cities' => [
                                                 'Montreal',
                                                 'Ontario',
                                                 'Ottawa',
                                                 'Quebec',
                                                 'Toronto',
                                               ]
                                 },
                                 {
                                   'name' => 'Cayman Islands',
                                   'cities' => [
                                                 'George Town',
                                               ]
                                 },
                                 {
                                   'cities' => [,],
                                   'name' => 'Chile'
                                 },
                                 {
                                   'name' => 'Colombia',
                                   'cities' => [
                                                 'Barranquilla',
                                                 "Bogot\x[e1]",
                                                 'Cali',
                                                 'Cartagena',
                                                 "Medell\x[ed]n",
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Guayaquil',
                                                 'Quito',
                                               ],
                                   'name' => 'Ecuador'
                                 },
                                 {
                                   'name' => 'Haiti',
                                   'cities' => [
                                                 'Port-au-Prince',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Kingston',
                                                 'Spanish Town',
                                               ],
                                   'name' => 'Jamaica'
                                 },
                                 {
                                   'cities' => [
                                                 "Canc\x[fa]n",
                                               ],
                                   'name' => 'Mexico'
                                 },
                                 {
                                   'cities' => [
                                                 'Panama City',
                                               ],
                                   'name' => 'Panama'
                                 },
                                 {
                                   'name' => 'Peru',
                                   'cities' => [
                                                 'Arequipa',
                                                 'Lima',
                                                 'Trujillo',
                                               ]
                                 },
                                 {
                                   'name' => 'United States',
                                   'cities' => [
                                                 'Atlanta',
                                                 'Baltimore',
                                                 'Boston',
                                                 'Charlotte',
                                                 'Cincinnati',
                                                 'Cleveland',
                                                 'Columbus',
                                                 'Connecticut',
                                                 'Delaware',
                                                 'Detroit',
                                                 'Florida',
                                                 'Georgia',
                                                 'Indiana',
                                                 'Indianapolis',
                                                 'Jacksonville',
                                                 'Kentucky',
                                                 'Lexington-Fayette',
                                                 'Maine',
                                                 'Maryland',
                                                 'Massachusetts',
                                                 'Miami',
                                                 'Michigan',
                                                 'New Hampshire',
                                                 'New Jersey',
                                                 'New York',
                                                 'North Carolina',
                                                 'Ohio',
                                                 'Pennsylvania',
                                                 'Philadelphia',
                                                 'Pittsburgh',
                                                 'Raleigh',
                                                 'Rhode Island',
                                                 'South Carolina',
                                                 'Staten Island',
                                                 'Tampa',
                                                 'Vermont',
                                                 'Virginia',
                                                 'Virginia Beach',
                                                 'Washington, D.C.',
                                                 'West Virginia',
                                               ]
                                 },
                               ],
                'offset' => '-5'
              },
              {
                'countries' => [
                                 {
                                   'cities' => [
                                                 'Caracas',
                                                 'Maracaibo',
                                                 'Maracay',
                                               ],
                                   'name' => 'Venezuela'
                                 },
                               ],
                'offset' => '-3.5'
              },
              {
                'countries' => [
                                 {
                                   'name' => 'Anguilla',
                                   'cities' => [
                                                 'The Valley',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'St. John\'s',
                                               ],
                                   'name' => 'Antigua and Barbuda'
                                 },
                                 {
                                   'cities' => [
                                                 'Oranjestad',
                                               ],
                                   'name' => 'Aruba'
                                 },
                                 {
                                   'name' => 'Barbados',
                                   'cities' => [
                                                 'Bridgetown',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'La Paz',
                                                 'Santa Cruz',
                                               ],
                                   'name' => 'Bolivia'
                                 },
                                 {
                                   'name' => 'Bonaire, Sint Eustatius and Saba',
                                   'cities' => [
                                                 'Kralendijk',
                                               ]
                                 },
                                 {
                                   'name' => 'Brazil',
                                   'cities' => [
                                                 'Amazonas',
                                                 'Campo Grande',
                                                 'Manaus',
                                                 'Mato Grosso',
                                                 'Mato Grosso do Sul',
                                                 "Par\x[e1]",
                                                 "Rond\x[f4]nia",
                                                 'Roraima',
                                               ]
                                 },
                                 {
                                   'name' => 'British Virgin Islands',
                                   'cities' => [
                                                 'Road Town',
                                               ]
                                 },
                                 {
                                   'name' => 'Canada',
                                   'cities' => [,]
                                 },
                                 {
                                   'name' => 'Cuba',
                                   'cities' => [
                                                 'Havana',
                                                 'Santiago de Cuba',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Willemstad',
                                               ],
                                   'name' => "Cura\x[e7]ao"
                                 },
                                 {
                                   'name' => 'Dominica',
                                   'cities' => [
                                                 'Roseau',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Santiago de los Caballeros',
                                                 'Santo Domingo',
                                               ],
                                   'name' => 'Dominican Republic'
                                 },
                                 {
                                   'name' => 'Grenada',
                                   'cities' => [
                                                 'St. George\'s',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Basse-Terre',
                                               ],
                                   'name' => 'Guadeloupe'
                                 },
                                 {
                                   'name' => 'Guyana',
                                   'cities' => [
                                                 'Georgetown',
                                               ]
                                 },
                                 {
                                   'name' => 'Martinique',
                                   'cities' => [
                                                 'Fort-de-France',
                                               ]
                                 },
                                 {
                                   'name' => 'Montserrat',
                                   'cities' => [
                                                 'Plymouth',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Carolina',
                                                 'San Juan',
                                               ],
                                   'name' => 'Puerto Rico'
                                 },
                                 {
                                   'cities' => [
                                                 'Basseterre',
                                               ],
                                   'name' => 'Saint Kitts and Nevis'
                                 },
                                 {
                                   'name' => 'Saint Lucia',
                                   'cities' => [
                                                 'Castries',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Marigot',
                                               ],
                                   'name' => 'Saint Martin'
                                 },
                                 {
                                   'cities' => [
                                                 'Kingstown',
                                               ],
                                   'name' => 'Saint Vincent and the Grenadines'
                                 },
                                 {
                                   'cities' => [
                                                 'Gustavia',
                                               ],
                                   'name' => "Saint-Barth\x[e9]lemy"
                                 },
                                 {
                                   'name' => 'Trinidad and Tobago',
                                   'cities' => [
                                                 'Chaguanas',
                                                 'Port of Spain',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Cockburn Town',
                                               ],
                                   'name' => 'Turks and Caicos Islands'
                                 },
                                 {
                                   'name' => 'U.S. Virgin Islands',
                                   'cities' => [
                                                 'Charlotte Amalie',
                                               ]
                                 },
                               ],
                'offset' => '-4'
              },
              {
                'countries' => [
                                 {
                                   'cities' => [
                                                 'Buenos Aires',
                                                 "C\x[f3]rdoba",
                                                 'Rosario',
                                               ],
                                   'name' => 'Argentina'
                                 },
                                 {
                                   'cities' => [
                                                 'Hamilton',
                                               ],
                                   'name' => 'Bermuda'
                                 },
                                 {
                                   'name' => 'Brazil',
                                   'cities' => [
                                                 'Alagoas',
                                                 "Amap\x[e1]",
                                                 'Bahia',
                                                 'Belo Horizonte',
                                                 "Bel\x[e9]m",
                                                 "Bras\x[ed]lia",
                                                 "Cear\x[e1]",
                                                 'Curitiba',
                                                 "Esp\x[ed]rito Santo",
                                                 'Federal District',
                                                 'Fortaleza',
                                                 "Goi\x[e1]s",
                                                 "Maranh\x[e3]o",
                                                 'Minas Gerais',
                                                 "Paran\x[e1]",
                                                 "Para\x[ed]ba",
                                                 'Pernambuco',
                                                 "Piau\x[ed]",
                                                 'Porto Alegre',
                                                 'Recife',
                                                 'Rio Grande do Norte',
                                                 'Rio Grande do Sul',
                                                 'Rio de Janeiro',
                                                 'Salvador',
                                                 'Santa Catarina',
                                                 'Sergipe',
                                                 "S\x[e3]o Paulo",
                                                 'Tocantins',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Halifax',
                                                 'New Brunswick',
                                                 'Nova Scotia',
                                                 'Prince Edward Island',
                                                 'Saint John',
                                               ],
                                   'name' => 'Canada'
                                 },
                                 {
                                   'name' => 'Chile',
                                   'cities' => [
                                                 'Puente Alto',
                                                 'Santiago',
                                               ]
                                 },
                                 {
                                   'name' => 'Falkland Islands',
                                   'cities' => [
                                                 'Stanley',
                                               ]
                                 },
                                 {
                                   'name' => 'French Guiana',
                                   'cities' => [
                                                 'Cayenne',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Nuuk',
                                               ],
                                   'name' => 'Greenland'
                                 },
                                 {
                                   'cities' => [
                                                 "Asunci\x[f3]n",
                                                 'Ciudad del Este',
                                               ],
                                   'name' => 'Paraguay'
                                 },
                                 {
                                   'name' => 'Suriname',
                                   'cities' => [
                                                 'Paramaribo',
                                               ]
                                 },
                                 {
                                   'name' => 'Uruguay',
                                   'cities' => [
                                                 'Montevideo',
                                                 'Salto',
                                               ]
                                 },
                               ],
                'offset' => '-3'
              },
              {
                'countries' => [
                                 {
                                   'name' => 'Canada',
                                   'cities' => [
                                                 'Newfoundland and Labrador',
                                                 'St Johns',
                                               ]
                                 },
                               ],
                'offset' => '-1.5'
              },
              {
                'countries' => [
                                 {
                                   'cities' => [,],
                                   'name' => 'Brazil'
                                 },
                                 {
                                   'name' => 'Saint Pierre and Miquelon',
                                   'cities' => [
                                                 'Saint-Pierre',
                                               ]
                                 },
                                 {
                                   'cities' => [,],
                                   'name' => 'South Georgia and South Sandwich Islands'
                                 },
                               ],
                'offset' => '-2'
              },
              {
                'offset' => '-1',
                'countries' => [
                                 {
                                   'cities' => [
                                                 'Ponta Delgada',
                                               ],
                                   'name' => 'Azores'
                                 },
                                 {
                                   'name' => 'Cape Verde',
                                   'cities' => [
                                                 'Praia',
                                               ]
                                 },
                                 {
                                   'name' => 'Greenland',
                                   'cities' => [
                                                 'Ittoqqortoormiit',
                                               ]
                                 },
                               ]
              },
              {
                'offset' => '0',
                'countries' => [
                                 {
                                   'name' => 'Burkina Faso',
                                   'cities' => [
                                                 'Bobo-Dioulasso',
                                                 'Ouagadougou',
                                               ]
                                 },
                                 {
                                   'name' => 'Canary Islands',
                                   'cities' => [
                                                 'Las Palmas',
                                               ]
                                 },
                                 {
                                   'name' => 'Faroe Islands',
                                   'cities' => [
                                                 "T\x[f3]rshavn",
                                               ]
                                 },
                                 {
                                   'name' => 'Gambia',
                                   'cities' => [
                                                 'Banjul',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Accra',
                                                 'Kumasi',
                                               ],
                                   'name' => 'Ghana'
                                 },
                                 {
                                   'name' => 'Greenland',
                                   'cities' => [,]
                                 },
                                 {
                                   'cities' => [,],
                                   'name' => 'Guernsey'
                                 },
                                 {
                                   'cities' => [
                                                 'Conakry',
                                                 "Nz\x[e9]r\x[e9]kor\x[e9]",
                                               ],
                                   'name' => 'Guinea'
                                 },
                                 {
                                   'cities' => [
                                                 "Bafat\x[e1]",
                                                 'Bissau',
                                               ],
                                   'name' => 'Guinea-Bissau'
                                 },
                                 {
                                   'cities' => [
                                                 'Reykjavik',
                                               ],
                                   'name' => 'Iceland'
                                 },
                                 {
                                   'cities' => [
                                                 'Cork',
                                                 'Dublin',
                                               ],
                                   'name' => 'Ireland'
                                 },
                                 {
                                   'name' => 'Isle of Man',
                                   'cities' => [,]
                                 },
                                 {
                                   'cities' => [
                                                 'Abidjan',
                                                 "Bouak\x[e9]",
                                                 'Yamoussoukro',
                                               ],
                                   'name' => 'Ivory Coast'
                                 },
                                 {
                                   'name' => 'Jersey',
                                   'cities' => [,]
                                 },
                                 {
                                   'name' => 'Liberia',
                                   'cities' => [
                                                 'Monrovia',
                                               ]
                                 },
                                 {
                                   'name' => 'Mali',
                                   'cities' => [
                                                 'Bamako',
                                                 'Sikasso',
                                               ]
                                 },
                                 {
                                   'name' => 'Mauritania',
                                   'cities' => [
                                                 'Nouadhibou',
                                                 'Nouakchott',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Casablanca',
                                                 'Rabat',
                                               ],
                                   'name' => 'Morocco'
                                 },
                                 {
                                   'name' => 'Portugal',
                                   'cities' => [
                                                 'Lisbon',
                                                 'Porto',
                                               ]
                                 },
                                 {
                                   'name' => 'Senegal',
                                   'cities' => [
                                                 'Dakar',
                                                 'Touba',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Bo',
                                                 'Freetown',
                                               ],
                                   'name' => 'Sierra Leone'
                                 },
                                 {
                                   'name' => "S\x[e3]o Tom\x[e9] and Pr\x[ed]ncipe",
                                   'cities' => [,]
                                 },
                                 {
                                   'name' => 'Togo',
                                   'cities' => [
                                                 "Lom\x[e9]",
                                                 "Sokod\x[e9]",
                                               ]
                                 },
                                 {
                                   'name' => 'United Kingdom',
                                   'cities' => [
                                                 'Birmingham',
                                                 'Bristol',
                                                 'Edinburgh',
                                                 'Glasgow',
                                                 'Leeds',
                                                 'Leicester',
                                                 'Liverpool',
                                                 'London',
                                                 'Manchester',
                                                 'Sheffield',
                                               ]
                                 },
                                 {
                                   'cities' => [,],
                                   'name' => 'Western Sahara'
                                 },
                               ]
              },
              {
                'offset' => '1',
                'countries' => [
                                 {
                                   'name' => 'Albania',
                                   'cities' => [
                                                 "Durr\x[eb]s",
                                                 'Tirana',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Algiers',
                                                 'Boumerdas',
                                                 'Oran',
                                               ],
                                   'name' => 'Algeria'
                                 },
                                 {
                                   'name' => 'Andorra',
                                   'cities' => [,]
                                 },
                                 {
                                   'cities' => [
                                                 'Luanda',
                                                 'N\'dalatando',
                                               ],
                                   'name' => 'Angola'
                                 },
                                 {
                                   'cities' => [
                                                 'Graz',
                                                 'Vienna',
                                               ],
                                   'name' => 'Austria'
                                 },
                                 {
                                   'name' => 'Belgium',
                                   'cities' => [
                                                 'Antwerp',
                                                 'Brussels',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Abomey-Calavi',
                                                 'Porto-Novo',
                                               ],
                                   'name' => 'Benin'
                                 },
                                 {
                                   'name' => 'Bosnia and Herzegovina',
                                   'cities' => [
                                                 'Sarajevo',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Douala',
                                                 "Yaound\x[e9]",
                                               ],
                                   'name' => 'Cameroon'
                                 },
                                 {
                                   'cities' => [
                                                 'Bangui',
                                                 'Bimbo',
                                               ],
                                   'name' => 'Central African Republic'
                                 },
                                 {
                                   'cities' => [
                                                 'Moundou',
                                                 'N\'Djamena',
                                               ],
                                   'name' => 'Chad'
                                 },
                                 {
                                   'cities' => [
                                                 'Brazzaville',
                                                 'Pointe-Noire',
                                               ],
                                   'name' => 'Congo-Brazzaville'
                                 },
                                 {
                                   'cities' => [
                                                 'Kikwit',
                                                 'Kinshasa',
                                               ],
                                   'name' => 'Congo-Kinshasa'
                                 },
                                 {
                                   'cities' => [
                                                 'Zagreb',
                                               ],
                                   'name' => 'Croatia'
                                 },
                                 {
                                   'name' => 'Czechia',
                                   'cities' => [
                                                 'Brno',
                                                 'Prague',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Aarhus',
                                                 'Copenhagen',
                                               ],
                                   'name' => 'Denmark'
                                 },
                                 {
                                   'name' => 'Equatorial Guinea',
                                   'cities' => [
                                                 'Bata',
                                                 'Malabo',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Lyon',
                                                 'Marseille',
                                                 'Nice',
                                                 'Paris',
                                                 'Toulouse',
                                               ],
                                   'name' => 'France'
                                 },
                                 {
                                   'cities' => [
                                                 'Libreville',
                                                 'Port-Gentil',
                                               ],
                                   'name' => 'Gabon'
                                 },
                                 {
                                   'cities' => [
                                                 'Berlin',
                                                 'Cologne',
                                                 'Essen',
                                                 'Frankfurt',
                                                 'Hamburg',
                                                 'Munich',
                                                 'Stuttgart',
                                               ],
                                   'name' => 'Germany'
                                 },
                                 {
                                   'cities' => [,],
                                   'name' => 'Gibraltar'
                                 },
                                 {
                                   'name' => 'Hungary',
                                   'cities' => [
                                                 'Budapest',
                                                 'Debrecen',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Milan',
                                                 'Naples',
                                                 'Palermo',
                                                 'Rome',
                                                 'Turin',
                                               ],
                                   'name' => 'Italy'
                                 },
                                 {
                                   'cities' => [,],
                                   'name' => 'Liechtenstein'
                                 },
                                 {
                                   'cities' => [,],
                                   'name' => 'Luxembourg'
                                 },
                                 {
                                   'name' => 'Macedonia',
                                   'cities' => [
                                                 'Bitola',
                                                 'Skopje',
                                               ]
                                 },
                                 {
                                   'name' => 'Malta',
                                   'cities' => [
                                                 'Valletta',
                                               ]
                                 },
                                 {
                                   'name' => 'Monaco',
                                   'cities' => [,]
                                 },
                                 {
                                   'cities' => [
                                                 'Podgorica',
                                               ],
                                   'name' => 'Montenegro'
                                 },
                                 {
                                   'cities' => [
                                                 'Amsterdam',
                                                 'The Hague',
                                               ],
                                   'name' => 'Netherlands'
                                 },
                                 {
                                   'name' => 'Niger',
                                   'cities' => [
                                                 'Niamey',
                                               ]
                                 },
                                 {
                                   'name' => 'Nigeria',
                                   'cities' => [
                                                 'Aba',
                                                 'Abuja',
                                                 'Benin City',
                                                 'Ibadan',
                                                 'Kaduna',
                                                 'Kano',
                                                 'Lagos',
                                                 'Maiduguri',
                                                 'Port Harcourt',
                                                 'Zaria',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Bergen',
                                                 'Oslo',
                                               ],
                                   'name' => 'Norway'
                                 },
                                 {
                                   'cities' => [
                                                 'Krakow',
                                                 'Warsaw',
                                                 "\x[141]\x[f3]d\x[17a]",
                                               ],
                                   'name' => 'Poland'
                                 },
                                 {
                                   'name' => 'San Marino',
                                   'cities' => [,]
                                 },
                                 {
                                   'cities' => [
                                                 'Belgrade',
                                                 "Ni\x[161]",
                                               ],
                                   'name' => 'Serbia'
                                 },
                                 {
                                   'name' => 'Slovakia',
                                   'cities' => [
                                                 'Bratislava',
                                                 "Ko\x[161]ice",
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Ljubljana',
                                                 'Maribor',
                                               ],
                                   'name' => 'Slovenia'
                                 },
                                 {
                                   'name' => 'Spain',
                                   'cities' => [
                                                 'Barcelona',
                                                 'Madrid',
                                                 'Seville',
                                                 'Valencia',
                                                 'Zaragoza',
                                               ]
                                 },
                                 {
                                   'name' => 'Sweden',
                                   'cities' => [
                                                 'Gothenburg',
                                                 'Stockholm',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Bern',
                                                 'Zurich',
                                               ],
                                   'name' => 'Switzerland'
                                 },
                                 {
                                   'cities' => [
                                                 'Tunis',
                                               ],
                                   'name' => 'Tunisia'
                                 },
                                 {
                                   'cities' => [,],
                                   'name' => 'Vatican City'
                                 },
                               ]
              },
              {
                'offset' => '2',
                'countries' => [
                                 {
                                   'cities' => [
                                                 'Francistown',
                                                 'Gaborone',
                                               ],
                                   'name' => 'Botswana'
                                 },
                                 {
                                   'name' => 'Bulgaria',
                                   'cities' => [
                                                 'Plovdiv',
                                                 'Sofia',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Bujumbura',
                                                 'Muyinga',
                                               ],
                                   'name' => 'Burundi'
                                 },
                                 {
                                   'name' => 'Congo-Kinshasa',
                                   'cities' => [
                                                 'Kisangani',
                                                 'Lubumbashi',
                                                 'Mbuji-Mayi',
                                               ]
                                 },
                                 {
                                   'name' => 'Cyprus',
                                   'cities' => [
                                                 'Limassol',
                                                 'Nicosia',
                                               ]
                                 },
                                 {
                                   'name' => 'Egypt',
                                   'cities' => [
                                                 'Alexandria',
                                                 'Cairo',
                                                 'Port Said',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Tallinn',
                                                 'Tartu',
                                               ],
                                   'name' => 'Estonia'
                                 },
                                 {
                                   'cities' => [
                                                 'Espoo',
                                                 'Helsinki',
                                               ],
                                   'name' => 'Finland'
                                 },
                                 {
                                   'cities' => [
                                                 'Athens',
                                                 'Thessaloniki',
                                               ],
                                   'name' => 'Greece'
                                 },
                                 {
                                   'name' => 'Israel',
                                   'cities' => [
                                                 'Haifa',
                                                 'Jerusalem',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Amman',
                                                 'Zarqa',
                                               ],
                                   'name' => 'Jordan'
                                 },
                                 {
                                   'name' => 'Latvia',
                                   'cities' => [
                                                 'Daugavpils',
                                                 'Riga',
                                               ]
                                 },
                                 {
                                   'name' => 'Lebanon',
                                   'cities' => [
                                                 'Beirut',
                                                 'Tripoli',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Mafeteng',
                                                 'Maseru',
                                               ],
                                   'name' => 'Lesotho'
                                 },
                                 {
                                   'cities' => [
                                                 'Tripoli',
                                               ],
                                   'name' => 'Libya'
                                 },
                                 {
                                   'name' => 'Lithuania',
                                   'cities' => [
                                                 'Kaunas',
                                                 'Vilnius',
                                               ]
                                 },
                                 {
                                   'name' => 'Malawi',
                                   'cities' => [
                                                 'Blantyre',
                                                 'Lilongwe',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 "Chi\x[15f]in\x[103]u",
                                                 'Tiraspol',
                                               ],
                                   'name' => 'Moldova'
                                 },
                                 {
                                   'name' => 'Mozambique',
                                   'cities' => [
                                                 'Maputo',
                                                 'Matola',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Rundu',
                                                 'Windhoek',
                                               ],
                                   'name' => 'Namibia'
                                 },
                                 {
                                   'name' => 'Palestine',
                                   'cities' => [
                                                 'Gaza',
                                               ]
                                 },
                                 {
                                   'name' => 'Romania',
                                   'cities' => [
                                                 'Bucharest',
                                                 "Ia\x[219]i",
                                               ]
                                 },
                                 {
                                   'name' => 'Russia',
                                   'cities' => [
                                                 'Kaliningrad',
                                               ]
                                 },
                                 {
                                   'name' => 'Rwanda',
                                   'cities' => [
                                                 'Kigali',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Cape Town',
                                                 'Durban',
                                                 'Johannesburg',
                                                 'Pretoria',
                                                 'Soweto',
                                               ],
                                   'name' => 'South Africa'
                                 },
                                 {
                                   'name' => 'Swaziland',
                                   'cities' => [
                                                 'Manzini',
                                                 'Mbabane',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Aleppo',
                                                 'Damascus',
                                               ],
                                   'name' => 'Syria'
                                 },
                                 {
                                   'cities' => [
                                                 'Adana',
                                                 'Ankara',
                                                 'Bursa',
                                                 'Gaziantep',
                                                 'Istanbul',
                                                 'Izmir',
                                                 'Konya',
                                               ],
                                   'name' => 'Turkey'
                                 },
                                 {
                                   'name' => 'Ukraine',
                                   'cities' => [
                                                 'Dnipropetrovsk',
                                                 'Kharkiv',
                                                 'Kyiv',
                                               ]
                                 },
                                 {
                                   'name' => 'Zambia',
                                   'cities' => [
                                                 'Kitwe',
                                                 'Lusaka',
                                               ]
                                 },
                                 {
                                   'name' => 'Zimbabwe',
                                   'cities' => [
                                                 'Bulawayo',
                                                 'Harare',
                                               ]
                                 },
                                 {
                                   'name' => "\x[c5]land",
                                   'cities' => [
                                                 'Mariehamn',
                                               ]
                                 },
                               ]
              },
              {
                'offset' => '3',
                'countries' => [
                                 {
                                   'name' => 'Bahrain',
                                   'cities' => [
                                                 'Manama',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Gomel',
                                                 'Minsk',
                                                 'Mogilev',
                                               ],
                                   'name' => 'Belarus'
                                 },
                                 {
                                   'cities' => [
                                                 'Moroni',
                                               ],
                                   'name' => 'Comoros'
                                 },
                                 {
                                   'name' => 'Djibouti',
                                   'cities' => [
                                                 'Djibouti',
                                               ]
                                 },
                                 {
                                   'name' => 'Eritrea',
                                   'cities' => [
                                                 'Asmara',
                                                 'Cheren',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Addis Ababa',
                                                 'Bahir Dar',
                                                 'Dire Dawa',
                                                 "Mek\x[2019]el\x[113]",
                                                 "Nazr\x[113]t",
                                               ],
                                   'name' => 'Ethiopia'
                                 },
                                 {
                                   'cities' => [
                                                 'Baghdad',
                                                 'Basra',
                                               ],
                                   'name' => 'Iraq'
                                 },
                                 {
                                   'name' => 'Kenya',
                                   'cities' => [
                                                 'Mombasa',
                                                 'Nairobi',
                                                 'Nakuru',
                                               ]
                                 },
                                 {
                                   'name' => 'Kuwait',
                                   'cities' => [
                                                 'Al Ahmadi',
                                                 'Kuwait City',
                                               ]
                                 },
                                 {
                                   'name' => 'Madagascar',
                                   'cities' => [
                                                 'Antananarivo',
                                                 'Toamasina',
                                               ]
                                 },
                                 {
                                   'name' => 'Mayotte',
                                   'cities' => [
                                                 'Mamoutzou',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Doha',
                                               ],
                                   'name' => 'Qatar'
                                 },
                                 {
                                   'cities' => [
                                                 'Kazan',
                                                 'Moscow',
                                                 'Nizhny Novgorod',
                                                 'Rostov-on-Don',
                                                 'Saint Petersburg',
                                               ],
                                   'name' => 'Russia'
                                 },
                                 {
                                   'name' => 'Saudi Arabia',
                                   'cities' => [
                                                 'Jeddah',
                                                 'Mecca',
                                                 'Riyadh',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Mogadishu',
                                               ],
                                   'name' => 'Somalia'
                                 },
                                 {
                                   'cities' => [
                                                 'Juba',
                                                 'Malakal',
                                               ],
                                   'name' => 'South Sudan'
                                 },
                                 {
                                   'name' => 'Sudan',
                                   'cities' => [
                                                 'Kassala',
                                                 'Khartoum',
                                                 'Port Sudan',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Dar es Salaam',
                                                 'Dodoma',
                                               ],
                                   'name' => 'Tanzania'
                                 },
                                 {
                                   'cities' => [
                                                 'Gulu',
                                                 'Kampala',
                                                 'Lira',
                                               ],
                                   'name' => 'Uganda'
                                 },
                                 {
                                   'name' => 'Ukraine',
                                   'cities' => [
                                                 'Donetsk',
                                                 'Luhansk',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Al Hudaydah',
                                                 'Sanaa',
                                               ],
                                   'name' => 'Yemen'
                                 },
                               ]
              },
              {
                'offset' => '3.5',
                'countries' => [
                                 {
                                   'name' => 'Iran',
                                   'cities' => [
                                                 'Isfahan',
                                                 'Karaj',
                                                 'Mashhad',
                                                 'Qom',
                                                 'Shiraz',
                                                 'Tabriz',
                                                 'Tehran',
                                               ]
                                 },
                               ]
              },
              {
                'countries' => [
                                 {
                                   'name' => 'Armenia',
                                   'cities' => [
                                                 'Yerevan',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Baku',
                                                 'Ganja',
                                               ],
                                   'name' => 'Azerbaijan'
                                 },
                                 {
                                   'cities' => [
                                                 'Kutaisi',
                                                 'Tbilisi',
                                               ],
                                   'name' => 'Georgia'
                                 },
                                 {
                                   'name' => 'Mauritius',
                                   'cities' => [
                                                 'Port Louis',
                                                 'Vacoas',
                                               ]
                                 },
                                 {
                                   'name' => 'Oman',
                                   'cities' => [
                                                 "As S\x[12b]b al Jad\x[12b]dah",
                                                 'Muscat',
                                               ]
                                 },
                                 {
                                   'name' => 'Russia',
                                   'cities' => [
                                                 'Samara',
                                                 'Tolyatti',
                                               ]
                                 },
                                 {
                                   'name' => "R\x[e9]union",
                                   'cities' => [
                                                 'Saint-Denis',
                                               ]
                                 },
                                 {
                                   'name' => 'Seychelles',
                                   'cities' => [
                                                 'Victoria',
                                               ]
                                 },
                                 {
                                   'name' => 'United Arab Emirates',
                                   'cities' => [
                                                 'Abu Dhabi',
                                                 'Dubai',
                                               ]
                                 },
                               ],
                'offset' => '4'
              },
              {
                'countries' => [
                                 {
                                   'name' => 'Afghanistan',
                                   'cities' => [
                                                 'Kabul',
                                                 'Kandahar',
                                                 'Mazari Sharif',
                                               ]
                                 },
                               ],
                'offset' => '4.5'
              },
              {
                'offset' => '5',
                'countries' => [
                                 {
                                   'cities' => [
                                                 "Port-aux-Fran\x[e7]ais",
                                               ],
                                   'name' => 'French Southern Territories'
                                 },
                                 {
                                   'name' => 'Kazakhstan',
                                   'cities' => [
                                                 "Aqt\x[f6]be",
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 "Mal\x[e9]",
                                               ],
                                   'name' => 'Maldives'
                                 },
                                 {
                                   'name' => 'Pakistan',
                                   'cities' => [
                                                 'Faisalabad',
                                                 'Gujranwala',
                                                 'Hyderabad',
                                                 'Islamabad',
                                                 'Karachi',
                                                 'Lahore',
                                                 'Multan',
                                                 'Peshawar',
                                                 'Quetta',
                                                 'Rawalpindi',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Chelyabinsk',
                                                 'Yekaterinburg',
                                               ],
                                   'name' => 'Russia'
                                 },
                                 {
                                   'cities' => [
                                                 'Dushanbe',
                                                 'Khujand',
                                               ],
                                   'name' => 'Tajikistan'
                                 },
                                 {
                                   'cities' => [
                                                 'Ashkabad',
                                                 'Turkmenabat',
                                               ],
                                   'name' => 'Turkmenistan'
                                 },
                                 {
                                   'cities' => [
                                                 'Namangan',
                                                 'Tashkent',
                                               ],
                                   'name' => 'Uzbekistan'
                                 },
                               ]
              },
              {
                'offset' => '5.5',
                'countries' => [
                                 {
                                   'cities' => [
                                                 'Ahmedabad',
                                                 'Bangalore',
                                                 'Chennai',
                                                 'Hyderabad',
                                                 'Kanpur',
                                                 'Kolkata',
                                                 'Mumbai',
                                                 'New Delhi',
                                                 'Pune',
                                                 'Surat',
                                               ],
                                   'name' => 'India'
                                 },
                                 {
                                   'name' => 'Sri Lanka',
                                   'cities' => [
                                                 'Colombo',
                                                 'Galkissa',
                                               ]
                                 },
                               ]
              },
              {
                'offset' => '5.75',
                'countries' => [
                                 {
                                   'name' => 'Nepal',
                                   'cities' => [
                                                 'Biratnagur',
                                                 'Kathmandu',
                                                 'Pokhara',
                                               ]
                                 },
                               ]
              },
              {
                'offset' => '6',
                'countries' => [
                                 {
                                   'cities' => [
                                                 'Chittagong',
                                                 'Comilla',
                                                 "Cox\x[2019]s B\x[101]z\x[101]r",
                                                 'Dhaka',
                                                 'Jessore',
                                                 'Khulna',
                                                 'Narsingdi',
                                                 'Rajshahi',
                                                 'Rangpur',
                                                 'Tongi',
                                               ],
                                   'name' => 'Bangladesh'
                                 },
                                 {
                                   'cities' => [
                                                 'Thimphu',
                                               ],
                                   'name' => 'Bhutan'
                                 },
                                 {
                                   'name' => 'British Indian Ocean Territory',
                                   'cities' => [,]
                                 },
                                 {
                                   'name' => 'Kazakhstan',
                                   'cities' => [
                                                 'Almaty',
                                                 'Astana',
                                               ]
                                 },
                                 {
                                   'name' => 'Kyrgyzstan',
                                   'cities' => [
                                                 'Bishkek',
                                                 'Osh',
                                               ]
                                 },
                                 {
                                   'name' => 'Russia',
                                   'cities' => [
                                                 'Novosibirsk',
                                                 'Omsk',
                                               ]
                                 },
                               ]
              },
              {
                'offset' => '6.5',
                'countries' => [
                                 {
                                   'cities' => [
                                                 'Naypyidaw',
                                                 'Yangon',
                                               ],
                                   'name' => 'Burma'
                                 },
                                 {
                                   'name' => 'Cocos [Keeling,] Islands',
                                   'cities' => [,]
                                 },
                               ]
              },
              {
                'offset' => '7',
                'countries' => [
                                 {
                                   'name' => 'Cambodia',
                                   'cities' => [
                                                 'Phnom Penh',
                                                 'Takeo',
                                               ]
                                 },
                                 {
                                   'name' => 'Christmas Island',
                                   'cities' => [,]
                                 },
                                 {
                                   'cities' => [
                                                 'Bandung',
                                                 'Bekasi',
                                                 'Depok',
                                                 'Jakarta',
                                                 'Medan',
                                                 'Palembang',
                                                 'Semarang',
                                                 'South Tangerang',
                                                 'Surabaya',
                                                 'Tangerang',
                                               ],
                                   'name' => 'Indonesia'
                                 },
                                 {
                                   'name' => 'Laos',
                                   'cities' => [
                                                 'Pakxe',
                                                 'Vientiane',
                                               ]
                                 },
                                 {
                                   'name' => 'Mongolia',
                                   'cities' => [
                                                 'Khovd',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Krasnoyarsk',
                                                 'Novokuznetsk',
                                               ],
                                   'name' => 'Russia'
                                 },
                                 {
                                   'name' => 'Thailand',
                                   'cities' => [
                                                 'Bangkok',
                                                 'Chon Buri',
                                                 'Mueang Nonthaburi',
                                                 'Mueang Samut Prakan',
                                                 'Udon Thani',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 "Bi\x[ea]n H\x[f2]a",
                                                 'Da Nang',
                                                 'Haiphong',
                                                 'Hanoi',
                                                 'HoChiMinh City',
                                                 "Hu\x[1ebf]",
                                                 'Nha Trang',
                                               ],
                                   'name' => 'Vietnam'
                                 },
                               ]
              },
              {
                'countries' => [
                                 {
                                   'name' => 'Australia',
                                   'cities' => [
                                                 'Mandurah',
                                                 'Perth',
                                                 'Western Australia',
                                               ]
                                 },
                                 {
                                   'name' => 'Brunei',
                                   'cities' => [
                                                 'Bandar Seri Begawan',
                                               ]
                                 },
                                 {
                                   'name' => 'China',
                                   'cities' => [
                                                 'Beijing',
                                                 'Chengdu',
                                                 'Chongqing',
                                                 'Dongguan',
                                                 'Guangzhou',
                                                 'Nanjing',
                                                 'Shanghai',
                                                 'Shenzhen',
                                                 'Tianjin',
                                                 'Wuhan',
                                               ]
                                 },
                                 {
                                   'cities' => [,],
                                   'name' => 'Hong Kong'
                                 },
                                 {
                                   'name' => 'Indonesia',
                                   'cities' => [
                                                 'Banjarmasin',
                                                 'City of Balikpapan',
                                                 'Makassar',
                                               ]
                                 },
                                 {
                                   'cities' => [,],
                                   'name' => 'Macau'
                                 },
                                 {
                                   'name' => 'Malaysia',
                                   'cities' => [
                                                 'Klang',
                                                 'Kota Bharu',
                                                 'Kuala Lumpur',
                                               ]
                                 },
                                 {
                                   'name' => 'Mongolia',
                                   'cities' => [
                                                 'Erdenet',
                                                 'Ulan Bator',
                                               ]
                                 },
                                 {
                                   'name' => 'Philippines',
                                   'cities' => [
                                                 'Antipolo',
                                                 'Bacolod City',
                                                 'City of Cebu',
                                                 'Dadiangas',
                                                 'Davao City',
                                                 'Manila',
                                                 'Zamboanga City',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Irkutsk',
                                               ],
                                   'name' => 'Russia'
                                 },
                                 {
                                   'cities' => [,],
                                   'name' => 'Singapore'
                                 },
                                 {
                                   'cities' => [
                                                 'Kaohsiung',
                                                 'Taipei',
                                               ],
                                   'name' => 'Taiwan'
                                 },
                               ],
                'offset' => '8'
              },
              {
                'offset' => '8.5',
                'countries' => [
                                 {
                                   'name' => 'North Korea',
                                   'cities' => [
                                                 'Hamhung',
                                                 'Pyongyang',
                                               ]
                                 },
                               ]
              },
              {
                'offset' => '8.75',
                'countries' => [
                                 {
                                   'cities' => [,],
                                   'name' => 'Australia'
                                 },
                               ]
              },
              {
                'countries' => [
                                 {
                                   'name' => 'East Timor',
                                   'cities' => [
                                                 'Dili',
                                               ]
                                 },
                                 {
                                   'name' => 'Indonesia',
                                   'cities' => [
                                                 'Ambon City',
                                                 'Jayapura',
                                               ]
                                 },
                                 {
                                   'name' => 'Japan',
                                   'cities' => [
                                                 'Osaka',
                                                 'Tokyo',
                                                 'Yokohama',
                                               ]
                                 },
                                 {
                                   'name' => 'Palau',
                                   'cities' => [,]
                                 },
                                 {
                                   'name' => 'Russia',
                                   'cities' => [
                                                 'Chita',
                                                 'Yakutsk',
                                               ]
                                 },
                                 {
                                   'name' => 'South Korea',
                                   'cities' => [
                                                 'Busan',
                                                 'Incheon',
                                                 'Seoul',
                                               ]
                                 },
                               ],
                'offset' => '9'
              },
              {
                'countries' => [
                                 {
                                   'name' => 'Australia',
                                   'cities' => [
                                                 'Darwin',
                                                 'Northern Territory',
                                               ]
                                 },
                               ],
                'offset' => '9.5'
              },
              {
                'countries' => [
                                 {
                                   'cities' => [
                                                 'Brisbane',
                                                 'Gold Coast',
                                                 'Queensland',
                                               ],
                                   'name' => 'Australia'
                                 },
                                 {
                                   'cities' => [
                                                 "Hag\x[e5]t\x[f1]a",
                                               ],
                                   'name' => 'Guam'
                                 },
                                 {
                                   'cities' => [
                                                 'Moen',
                                               ],
                                   'name' => 'Micronesia'
                                 },
                                 {
                                   'name' => 'Northern Mariana Islands',
                                   'cities' => [,]
                                 },
                                 {
                                   'cities' => [
                                                 'Lae',
                                                 'Port Moresby',
                                               ],
                                   'name' => 'Papua New Guinea'
                                 },
                                 {
                                   'cities' => [
                                                 'Khabarovsk',
                                                 'Vladivostok',
                                               ],
                                   'name' => 'Russia'
                                 },
                               ],
                'offset' => '10'
              },
              {
                'countries' => [
                                 {
                                   'cities' => [
                                                 'Adelaide',
                                                 'Adelaide Hills',
                                                 'South Australia',
                                               ],
                                   'name' => 'Australia'
                                 },
                               ],
                'offset' => '10.5'
              },
              {
                'offset' => '11',
                'countries' => [
                                 {
                                   'cities' => [
                                                 'Australian Capital Territory',
                                                 'Canberra',
                                                 'New South Wales',
                                                 'Sydney',
                                                 'Tasmania',
                                                 'Victoria',
                                               ],
                                   'name' => 'Australia'
                                 },
                                 {
                                   'cities' => [
                                                 'Palikir',
                                               ],
                                   'name' => 'Micronesia'
                                 },
                                 {
                                   'name' => 'New Caledonia',
                                   'cities' => [
                                                 'Noumea',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Kingston',
                                               ],
                                   'name' => 'Norfolk Island'
                                 },
                                 {
                                   'cities' => [
                                                 'Honiara',
                                               ],
                                   'name' => 'Solomon Islands'
                                 },
                                 {
                                   'name' => 'Vanuatu',
                                   'cities' => [
                                                 'Port Vila',
                                               ]
                                 },
                               ]
              },
              {
                'offset' => '12',
                'countries' => [
                                 {
                                   'cities' => [
                                                 'Suva',
                                               ],
                                   'name' => 'Fiji'
                                 },
                                 {
                                   'name' => 'Kiribati',
                                   'cities' => [
                                                 'Tarawa',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Majuro',
                                               ],
                                   'name' => 'Marshall Islands'
                                 },
                                 {
                                   'name' => 'Nauru',
                                   'cities' => [,]
                                 },
                                 {
                                   'name' => 'Russia',
                                   'cities' => [
                                                 'Petropavlovsk-Kamchatsky',
                                               ]
                                 },
                                 {
                                   'cities' => [,],
                                   'name' => 'Tuvalu'
                                 },
                                 {
                                   'name' => 'U.S. Minor Outlying Islands',
                                   'cities' => [,]
                                 },
                                 {
                                   'name' => 'Wallis and Futuna',
                                   'cities' => [
                                                 'Mata-Utu',
                                               ]
                                 },
                               ]
              },
              {
                'countries' => [
                                 {
                                   'name' => 'Kiribati',
                                   'cities' => [,]
                                 },
                                 {
                                   'cities' => [
                                                 'Auckland',
                                                 'Wellington',
                                               ],
                                   'name' => 'New Zealand'
                                 },
                                 {
                                   'name' => 'Tokelau',
                                   'cities' => [,]
                                 },
                                 {
                                   'cities' => [
                                                 'Nuku\'alofa',
                                               ],
                                   'name' => 'Tonga'
                                 },
                               ],
                'offset' => '13'
              },
              {
                'countries' => [
                                 {
                                   'cities' => [,],
                                   'name' => 'New Zealand'
                                 },
                               ],
                'offset' => '13.75'
              },
              {
                'offset' => '14',
                'countries' => [
                                 {
                                   'name' => 'Kiribati',
                                   'cities' => [
                                                 'Tabwakea Village',
                                               ]
                                 },
                                 {
                                   'cities' => [
                                                 'Apia',
                                               ],
                                   'name' => 'Samoa'
                                 },
                               ]
              }
    );
}
