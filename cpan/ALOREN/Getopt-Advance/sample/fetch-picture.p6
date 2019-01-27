#!/usr/bin/env perl6

use LWP::Simple;
use Getopt::Advance;
use Getopt::Advance::Parser;
use Getopt::Advance::Option;

constant $TIEBA_URI_PREFIX = "https://tieba.baidu.com/p/";
constant $ACFUN_URI_PREFIX = "http://www.acfun.tv/a/";
constant $GAMER_URI_PREFIX = "https://home.gamer.com.tw/creationDetail.php?sn=";
constant $BAIDU = "baidu";
constant $ACFUN = "acfun";
constant $GAMER = "gamer";
constant $TOOL_WGET = 'wget';
constant $TOOL_CURL = 'curl';
constant $TOOL_LWP  = 'lwp';
constant $TEMPFILE  = '.page';
constant $ENCODING  = 'latin1';

grammar MyOptionGrammar { ... }

my OptionSet $opts .= new;

$opts.push("h|help=b");
$opts.push(
    "t|tempfile=s",
    "Temp file name used when wget fetch webpage. ",
    value => $TEMPFILE,
);
$opts.push(
    "tools=s",
    "Which tool < {$TOOL_LWP} {$TOOL_CURL} {$TOOL_WGET} > use to fetch webpage and picture. ",
    value => $TOOL_LWP,
);
$opts.push(
    "encoding=s",
    "What encoding use of webpage. ",
    value => $ENCODING,
);
$opts.push(
    "beg=i",
    'The begin page fetched. ',
    value => 1,
);
$opts.push(
    "end=i",
    'The last page fetched. ',
    value => 1,
);
$opts.push(
    "type=s",
    'Current support website is baidu(fetch tieba picture) and acfun、gamer.',
    value => $BAIDU,
    callback => -> $, $type {
        die "Not a valid type, must be one of [$BAIDU $ACFUN $GAMER]"
            if $type !(elem) ($BAIDU, $ACFUN, $GAMER);
    },
);
$opts.push(
    "o|output=s",
    'Output directory, default is working directory.',
    value => ".",
    callback => -> $, $dir {
        die "Not a valid directory"
            if $dir.IO !~~ :d;
    },
);
$opts.push(
    "e=s",
    'Output file extension. ',
    value => "jpg",
);
$opts.insert-main(&main);

# hook the method need to fix
&ga-parser.wrap(sub ($parserobj, |c) {
    $parserobj.typeoverload.optgrammar = MyOptionGrammar;
    nextwith($parserobj, |c);
});
for $opts.types.values -> $type {
    if $type.^lookup('lprefix') {
        $type.^lookup('lprefix').wrap(sub (|c) { return "+"; });
        $type.^lookup('sprefix').wrap(sub (|c) { return ":"; });
    }
}

&getopt($opts, :autohv, styles => [ :long, :short ]);

sub main(OptionSet \opts, @pidarg) {
    my @pid = @pidarg>>.value;
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
    my &get-page = -> \opts, \uri {
        my $cmd = "";
        given opts{'tools'} {
            when /lwp/ {
                my $handle = opts<t>.IO.open(:w);
                $handle.print(LWP::Simple.new.get(uri));
                $handle.close;
            }
            when /curl/ {
                $cmd = "curl -o {opts<t>} {uri} -s";
            }
            when /wget/ {
                $cmd = "wget -O {opts<t>} {uri} -q";
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
    my &fetch-picture = -> \opts, \dir, \count, \uri{
        my ($cmd, $file) = ("", "{opts<o>.IO.absolute}/{dir}/{count}.{opts<e>}");
        given opts{'tools'} {
            when /lwp/ {
                my $handle = $file.IO.open(:w);
                $handle.write(LWP::Simple.new.get(uri));
                $handle.close;
            }
            when /curl/ {
                $cmd = "curl -o {$file} {uri} -s";
            }
            when /wget/ {
                $cmd = "wget -O {$file} {uri} -q";
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
                            &fetch-picture( opts, $dir, $count++, picture.[0].Str);
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
                            &fetch-picture( opts, $dir, $count++, picture.[0].Str);
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
                            &fetch-picture( opts, $dir, $count++, picture.[0].Str);
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

grammar MyOptionGrammar {
	token TOP { ^ <option> $ }

	proto token option {*}

	token option:sym<s> { ':'  <optname> }

	token option:sym<l> { '+' <optname> }

	token option:sym<ds>{ ':/' <optname> }

	token option:sym<dl>{ '+/'<optname> }

	token option:sym<sv>{ ':'  <optname> '=' <optvalue> }

	token option:sym<lv>{ '+' <optname> '=' <optvalue>	}

	token optname {
		<-[\=\-]>+
	}

	token optvalue {
		.+
	}
}

sub noteMessage(Str \str, Int \count = 0) {
    note("{' ' x count}=> {str}");
}
