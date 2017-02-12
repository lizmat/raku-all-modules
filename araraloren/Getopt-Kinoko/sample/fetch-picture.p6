#!/usr/bin/env perl6

use LWP::Simple;
use Getopt::Kinoko;
use Getopt::Kinoko::OptionSet;

constant $TIEBA_URI_PREFIX = "http://tieba.baidu.com/p/";
constant $ACFUN_URI_PREFIX = "http://www.acfun.tv/a/";
constant $GAMER_URI_PREFIX = "https://home.gamer.com.tw/creationDetail.php?sn=";
constant $BAIDU = "baidu";
constant $ACFUN = "acfun";
constant $GAMER = "gamer";
constant $TSOCKS_AF = 1;
constant $TSOCKS_AO = 2;
constant $TSOCKS_FO = 3;
constant $TSOCKS_NO = 4;
constant $TOOL_WGET = 'wget';
constant $TOOL_CURL = 'curl';
constant $TOOL_LWP  = 'lwp';
constant $TEMPFILE  = '.page';
constant $ENCODING  = 'latin1';

my OptionSet $opts .= new;

$opts.insert-normal("h|help=b");
$opts.push-option(
    "t|tempfile=s",
    $TEMPFILE,
    comment => "Temp file name used when wget fetch webpage. [{$TEMPFILE}]"
);
$opts.push-option(
    "tools=s",
    $TOOL_LWP,
    comment => "Which tool < {$TOOL_LWP} {$TOOL_CURL} {$TOOL_WGET} > use to fetch webpage and picture. [{$TOOL_LWP}]"
);
$opts.push-option(
    "encoding=s",
    $ENCODING,
    comment => "What encoding use of webpage. [{$ENCODING}]"
);
$opts.push-option(
    "beg=i",
    1,
    comment => 'The begin page fetched. [1]'
);
$opts.push-option(
    "end=i",
    1,
    comment => 'The last page fetched. [1]'
);
$opts.push-option(
    "type=s",
    $BAIDU,
    callback => -> $type {
        die "Not a valid type, must be one of [$BAIDU $ACFUN $GAMER]"
            if $type !(elem) ($BAIDU, $ACFUN, $GAMER);
    },
    comment => 'Current support website is baidu(fetch tieba picture) and acfun、gamer.'
);
$opts.push-option(
    "o|output=s",
    ".",
    callback => -> $dir {
        die "Not a valid directory"
            if $dir.IO !~~ :d;
    },
    comment => 'Output directory, default is working directory.'
);
$opts.push-option(
    "e=s",
    "jpg",
    comment => 'Output file extension. [jpg]'
);
$opts.push-option(
    "s|use-tsocks=i",
    $TSOCKS_NO,
    comment => "Use tsocks access website \{$TSOCKS_AF => access and fetch,
                $TSOCKS_AO => access, $TSOCKS_FO => fetch, $TSOCKS_NO => no tsocks}. [{$TSOCKS_NO}]"
);

sub noteMessage(Str \str, Int \count = 0) {
    note("{' ' x count}=> {str}");
}

main(getopt($opts), $opts);

sub main(@pid, OptionSet \opts) {
    if opts{'h'} {
        note "{$*PROGRAM-NAME} {$opts.usage}\n";
        note(.join("") ~ "\n") if .[1].chars > 1 for opts.comment(2);
        exit 0;
    }
    my @uris = do given opts<type> {
        when $BAIDU {
            $TIEBA_URI_PREFIX X~ @pid;
        }
        when $ACFUN {
            $ACFUN_URI_PREFIX X~ @pid;
        }
        when $GAMER {
            $GAMER_URI_PREFIX X~ @pid;
        }
    };
    my $access-s = (opts<s> == $TSOCKS_AF | $TSOCKS_AO) ?? "tsocks" !! "";
    my &get-page = -> \opts, \uri {
        my $cmd = "";
        given opts{'tools'} {
            when /lwp/ {
                if $access-s ne "tsocks" {
                    my $handle = opts<t>.IO.open(:w);
                    $handle.print(LWP::Simple.new.get(uri));
                    $handle.close;
                }
                else {
                    &noteMessage("LWP not support tsocks!");
                    exit 0;
                }
            }
            when /curl/ {
                $cmd = "{$access-s} curl -o {opts<t>} {uri} -s";
            }
            when /wget/ {
                $cmd = "{$access-s} wget -O {opts<t>} {uri} -q";
            }
            default {
                &noteMessage("Not implement!");
                exit 0;
            }
        }
        QX($cmd);
        opts<t>.IO.open(enc => opts{'encoding'}).slurp-rest;
    };

    my &get-npage = -> \opts, \content {
        my Int $n = do given opts<type> {
            when $BAIDU {
                if content ~~ /'<span class="red">'(\d+)'</span>'/ {
                    $/[0].Int;
                }
                else {
                    0
                }
            }
            default {
                1;
            }
        };
        $n;
    };
    my $fetch-s = (opts<s> eq $TSOCKS_AF | $TSOCKS_FO) ?? "tsocks" !! "";
    my &fetch-picture = -> \opts, \dir, \count, \uri, \tsocks {
        my ($cmd, $file) = ("", "{opts<o>.IO.abspath}/{dir}/{count}.{opts<e>}");
        given opts{'tools'} {
            when /lwp/ {
                if tsocks ne "tsocks" {
                    my $handle = $file.IO.open(:w);
                    $handle.write(LWP::Simple.new.get(uri));
                    $handle.close;
                }
                else {
                    &noteMessage("LWP not support tsocks!");
                    exit 0;
                }
            }
            when /curl/ {
                $cmd = "{tsocks} curl -o {$file} {uri} -s";
            }
            when /wget/ {
                $cmd = "{tsocks} wget -O {$file} {uri} -q";
            }
            default {
                &noteMessage("Not implement!");
                exit 0;
            }
        }
        QX($cmd);
    };
    for @uris -> \uri {
        my ($dir, $content, $npage, $beg, $end, $count);

        $dir        = @pid.shift;
        &noteMessage("Fetch page total count: {uri}");
        $content    = &get-page(opts, uri);
        if $content.chars < 1 {
            &noteMessage( "Failed!", 1);
            next;
        }
        $npage      = &get-npage(opts, $content);
        $beg        = opts<beg> >= 0 ?? opts<beg> !! 1;
        $end        = opts<end> > $npage ?? $npage !! opts<end>;
        $count      = 0;
        &noteMessage( "Fetch page {$beg} - {$end}", 1);

        loop (my $i = $beg; $i <= $end; ++$i) {
            &noteMessage( "Fetch page {$i} content", 2);
            $content = &get-page(
                opts,
                do given opts<type> {
                    when $BAIDU {
                        "{uri}?pn={$i}"
                    }
                    default {
                        uri
                    }
                }
            );
            if $content.chars < 1 {
                &noteMessage( "Failed!", 2);
                next;
            }
            &noteMessage( "Try parse page {$i} picture urls", 2);
            given opts<type> {
                when $BAIDU {
                    if $content ~~ m:g/\<img \s+
                        class\=\"BDE_Image\" <-[\>]>+?
                        src\=\"(<-[\"\>]>+)\" \s+
                        / {
                        $dir.IO.mkdir if $dir.IO !~~ :d;
                        &noteMessage( "Get {+@$/} picture url", 2);
                        for @$/ -> \picture {
                            &noteMessage( "Fetch picture {picture.[0]}", 2);
                            &fetch-picture( opts, $dir, $count++, picture.[0].Str, $fetch-s);
                        }
                    }
                    else {
                        &noteMessage( "Parse page {$i} picture urls failed!", 2);
                    }
                }
                when $ACFUN {
                    if $content ~~ m:g/\<img \s+
                        id\=\"bigImg\" <-[\>]>+?
                        src\=\"(<-[\"\>]>+)\" \s+
                        / {
                        $dir.IO.mkdir if $dir.IO !~~ :d;
                        &noteMessage( "Get {+@$/} picture url", 2);
                        for @$/ -> \picture {
                            &noteMessage( "Fetch picture {picture.[0]}", 2);
                            &fetch-picture( opts, $dir, $count++, picture.[0].Str, $fetch-s);
                        }
                    }
                    else {
                        &noteMessage( "Parse page {$i} picture urls failed!", 2);
                    }
                }
                when $GAMER {
                    if $content ~~ m:g/\<img \s+
                        <-[\>]>+?
                        data\-src\=\"(<-[\"\>]>+)\" \s+
                        / {
                        $dir.IO.mkdir if $dir.IO !~~ :d;
                        &noteMessage( "Get {+@$/} picture url", 2);
                        for @$/ -> \picture {
                            &noteMessage( "Fetch picture {picture.[0]}", 2);
                            &fetch-picture( opts, $dir, $count++, picture.[0].Str, $fetch-s);
                        }
                    }
                    else {
                        &noteMessage( "Parse page {$i} picture urls failed!", 2);
                    }
                }
            }
        }
    }
}
