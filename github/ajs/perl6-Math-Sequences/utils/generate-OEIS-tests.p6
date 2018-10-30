#!/usr/bin/env perl6
#
# Generate the OEIS sequences test

use HTTP::Client;

my $preamble = q:to<END_PREAMBLE>;
    # Test OEIS sequences
    #

    use Test;
    use Math::Sequences::Integer;

    our @core-sequences =
    END_PREAMBLE

my @core-sequences = <
    A000001 A000002 A000004 A000005 A000007 A000009 A000010 A000012 A000014
    A000019 A000027 A000029 A000031 A000032 A000035 A000040 A000041 A000043
    A000045 A000048 A000055 A000058 A000069 A000079 A000081 A000085 A000088
    A000105 A000108 A000109 A000110 A000111 A000112 A000120 A000123 A000124
    A000129 A000140 A000142 A000161 A000166 A000169 A000182 A000203 A000204
    A000217 A000219 A000225 A000244 A000262 A000272 A000273 A000290 A000292
    A000302 A000311 A000312 A000326 A000330 A000364 A000396 A000521 A000578
    A000583 A000593 A000594 A000602 A000609 A000670 A000688 A000720 A000793
    A000796 A000798 A000959 A000961 A000984 A001003 A001006 A001034 A001037
    A001045 A001055 A001065 A001057 A001097 A001113 A001147 A001157 A001190
    A001221 A001222 A001227 A001285 A001333 A001349 A001358 A001405 A001462
    A001477 A001478 A001481 A001489 A001511 A001615 A001699 A001700 A001519
    A001764 A001906 A001969 A002033 A002083 A002106 A002110 A002113 A002275
    A002322 A002378 A002426 A002487 A002530 A002531 A002572 A002620 A002654
    A002658 A002808 A003094 A003136 A003418 A003484 A004011 A004018 A004526
    A005036 A005100 A005101 A005117 A005130 A005230 A005408 A005470 A005588
    A005811 A005843 A006318 A006530 A006882 A006894 A006966 A007318 A008275
    A008277 A008279 A008292 A008683 A010060 A018252 A020639 A020652 A020653
    A027641 A027642 A035099 A038566 A038567 A038568 A038569 A049310 A055512
    A070939 A074206 A104725 A226898 A246655 >;

my $tests = q:to<END_TESTS>;
    plan +@core-sequences;

    for @core-sequences {
        my $name = .key;
        my $value = .value;

        if %Math::Sequences::Integer::BROKEN{$name}:exists {
            skip "$name: Known broken", 1;
            next;
        }

        for [$value.elems, $value.elems div 3] -> $len is copy {
            constant timeout = 5;
            my $timer = Promise.in(timeout);
            my $test = start {
                is @::($name)[^$len], $value[^$len], $name;
                "complete";
            }
            await Promise.anyof($test, $timer);

            if $timer.status !~~ PromiseStatus::Planned {
                if $len == $value.elems {
                    warn "Timeout in $name";
                } else {
                    flunk "$name: Timeout";
                }
            } else {
                $test.result;
                last;
            }
        }

        CATCH {
            when ~$_ ~~ rx:s/been defined/ {
                pass "Not yet implemented: $name";
            }
            default {
                flunk ~$_;
            }
        }
    }
    END_TESTS

my $footer = q:to<END_FOOTER>;
    # The OEIS data used here is reproduced under the following terms:
    #
    # ...
    # 2. The OEIS is made available under the Creative Commons Attribution
    # Non-Commercial 3.0 license.
    # 
    # 3. To satisfy the attribution requirements of that license (section 4(c)),
    # attributions should credit The Online Encyclopedia of Integer Sequences
    # and provide a URL to the main page https://oeis.org/ or to a specific
    # sequence (e.g. https://oeis.org/A000108).
    # 
    # 4. Commercial uses may be licensed by special arrangement with the OEIS
    # Foundation Inc..
    END_FOOTER

if not "t".IO ~~ :d {
    die "Cannot find test subdir 't'";
}
my $test-script = "t/OEIS.t";
my $test-script-temp = $test-script ~ ".tmp";
my $fh = open($test-script-temp, :w);
$fh.say($preamble);
for @core-sequences -> $s {
    $fh.say("    $s => [ {get-sequence($s)} ],");
    if (state $n = 0)++ %% 4 { sleep 0.5 }
}
$fh.say(";");
$fh.say($tests);
$fh.say($footer);
$fh.close;

sub get-sequence($name) {
    my $client = HTTP::Client.new;
    my $url = "http://oeis.org/$name/list";
    my $response = $client.get($url);
    if not $response.success {
        die "Cannot fetch OEIS $url: {$response.status}: {$response.message}";
    }
    if $response.content ~~ /\<pre\>\s*\[(<[\d\s\\,-]>+)\]/ {
        my $list = ~$0;
        $list .= subst(/<after \d>\s+<before \d>/, '', :g);
        $list .= subst(/\s*\\+\s*/, '', :g);
        return $list;
    } else {
        die "Cannot find sequence data for $name";
    }
}

# vim: sw=4 softtabstop=4 expandtab ai ft=perl6
