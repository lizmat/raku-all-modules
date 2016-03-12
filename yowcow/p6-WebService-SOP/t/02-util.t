use v6;
use lib 'lib';
use Test;
use WebService::SOP::V1_1::Util;

subtest {

    is WebService::SOP::V1_1::Util::stringify-params({
        "zzz" => "zzz",
        "yyy" => "yyy",
        "xxx" => "xxx",
    }), 'xxx=xxx&yyy=yyy&zzz=zzz';

    is WebService::SOP::V1_1::Util::stringify-params({
        "sop_hoge" => "hoge",
        "zzz" => "zzz",
        "yyy" => "yyy",
        "xxx" => "xxx",
    }), 'xxx=xxx&yyy=yyy&zzz=zzz';

    dies-ok {
        WebService::SOP::V1_1::Util::stringify-params({
            "xxx" => {
                "yyy" => "yyy",
            },
        })
    }, 'Structured data dies';

}, 'Test stringify-params';

subtest {

    subtest {
        is create-signature(
            {   "ccc" => "ccc",
                "bbb" => "bbb",
                "aaa" => "aaa",
            },
            "hogehoge"
        ), '2fbfe87e54cc53036463633ef29beeaa4d740e435af586798917826d9e525112';

        is create-signature(
            {   "ccc"      => "ccc",
                "bbb"      => "bbb",
                "aaa"      => "aaa",
                "sop_hoge" => "hoge",
            },
            "hogehoge"
        ), '2fbfe87e54cc53036463633ef29beeaa4d740e435af586798917826d9e525112';

    }, '1st param isa Hash';

    subtest {
        is create-signature(
            '{"hoge":"fuga"}',
            "hogehoge"
        ), 'dc76e675e2bcabc31182e33506f5b01ea7966a9c0640d335cc6cc551f0bb1bba';

    }, '1st param isa Str';

}, 'Test create-signature';

subtest {

    subtest {
        my %params = "hoge" => "hoge";
        my Str $sig = create-signature(%params, "hogehoge");

        ok !is-signature-valid($sig, %params, "hogehoge");

    }, 'No `time` in params';

    subtest {
        my $time   = time;
        my %params = "hoge" => "hoge",
                     "time" => $time - 601;
        my Str $sig = create-signature(%params, "hogehoge");

        ok !is-signature-valid($sig, %params, "hogehoge", $time);

    }, '`time` is too old';

    subtest {
        my $time   = time;
        my %params = "hoge" => "hoge",
                     "time" => $time - 600;
        my Str $sig = create-signature(%params, "hogehoge");

        ok is-signature-valid($sig, %params, "hogehoge", $time);

    }, 'Valid';

    subtest {
        my $time   = time;
        my %params = "hoge" => "hoge",
                     "time" => $time + 600;
        my Str $sig = create-signature(%params, "hogehoge");

        ok is-signature-valid($sig, %params, "hogehoge", $time);

    }, 'Valid';

    subtest {
        my $time   = time;
        my %params = "hoge" => "hoge",
                     "time" => $time + 601;
        my Str $sig = create-signature(%params, "hogehoge");

        ok !is-signature-valid($sig, %params, "hogehoge", $time);

    }, '`time` is too new';

}, 'Test is-signature-valid on Hash';

subtest {

    subtest {
        my Str $json = to-json({ hoge => 'fuga' });
        my Str $sig  = create-signature($json, "hogehoge");

        ok !is-signature-valid($sig, $json, "hogehoge");

    }, 'No `time` in JSON';

    subtest {
        my Int $time = time;
        my Str $json = to-json({
            hoge => 'hoge',
            time => $time - 601
        });
        my Str $sig = create-signature($json, "hogehoge");

        ok !is-signature-valid($sig, $json, 'hogehoge', $time);

    }, '`time` is too old';

    subtest {
        my Int $time = time;
        my Str $json = to-json({
            hoge => 'hoge',
            time => $time - 600
        });
        my Str $sig = create-signature($json, "hogehoge");

        ok is-signature-valid($sig, $json, 'hogehoge', $time);

    }, '`time` is valid';

    subtest {
        my Int $time = time;
        my Str $json = to-json({
            hoge => 'hoge',
            time => $time + 600
        });
        my Str $sig = create-signature($json, "hogehoge");

        ok is-signature-valid($sig, $json, 'hogehoge', $time);

    }, '`time` is valid';

    subtest {
        my Int $time = time;
        my Str $json = to-json({
            hoge => 'hoge',
            time => $time + 601
        });
        my Str $sig = create-signature($json, "hogehoge");

        ok !is-signature-valid($sig, $json, 'hogehoge', $time);

    }, '`time` is too new';

}, 'Test is-signature-valid on JSON';

subtest {

    subtest {
        my Str $q = build-query-string({ hoge => 'fuga', fuga => 'hoge' });

        is $q, 'hoge=fuga&fuga=hoge';

    }, 'Simple key-value';

    subtest {
        my Str $q = build-query-string({ hoge => ['ho', 'ge'] });

        is $q, 'hoge=ho&hoge=ge';

    }, 'Array in value';

    subtest {

        dies-ok { build-query-string({ hoge => { foo => 'bar' } }) };

    }, 'Dies when value isa Hash';

}, 'Test build-query-string';

done-testing;
