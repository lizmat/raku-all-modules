use v6;
use HTTP::Tinyish;
use Test;
use File::Temp;

subtest {
    my $url = "http://doc.perl6.org/images/camelia.png";
    my %res = HTTP::Tinyish.new.get($url, :bin);
    is %res<status>, 200;
    my $buf = %res<content>;
    does-ok $buf, Buf;
    my $file-type = $buf.subbuf(1, 3).decode;
    is $file-type, "PNG";
};

subtest {
    my $url = "http://blogs.yahoo.co.jp/"; # euc-jp
    my %res = HTTP::Tinyish.new.get($url, :bin);
    is %res<status>, 200;
    does-ok %res<content>, Buf;
    like %res<headers><content-type>, rx:i/euc\-jp/;
    # note %res<headers>.perl;
};

subtest {
    my $url = "http://httpbin.org/put";
    my %res = HTTP::Tinyish.new.put: $url,
        headers => { 'Content-Type' => 'text/plain; charset=utf-8' },
        content => "あいうえお".encode,
    ;
    is %res<status>, 200;
    is-deeply from-json(%res<content>)<data>, "あいうえお";
};

subtest {
    my ($file, $fh) = tempfile;
    $fh.print("あいうえお\n");
    $fh.close;
    my $url = "http://httpbin.org/put";
    my %res = HTTP::Tinyish.new.put: $url,
        headers => { 'Content-Type' => 'text/plain; charset=utf-8' },
        content => $file.IO.slurp(:bin),
        bin     => True,
    ;
    is %res<status>, 200;
    does-ok %res<content>, Buf;
    is-deeply from-json(%res<content>.decode)<data>, "あいうえお\n";
};

subtest {
    my $url = "http://foo.bar.example.com/does-not-exists";
    my %res = HTTP::Tinyish.new.get($url, :bin);
    is %res<status>, 599;
    does-ok %res<content>, Buf;
};

subtest {
    my ($file, $) = tempfile;
    my $url = "http://blogs.yahoo.co.jp/"; # euc-jp
    my %res = HTTP::Tinyish.new.mirror($url, $file);
    is %res<status>, 200;
    like %res<headers><content-type>, rx:i/euc\-jp/;
    ok $file.IO.s > 0;
};

done-testing;
