use v6.c;

module TestServer {

    sub test-server(Promise $done-promise, Int :$port) is export returns Promise {
        my $server-promise = start {
            sub _index_buf(Blob $input, Blob $sub) {
                my $end-pos = 0;
                while $end-pos < $input.bytes {
                    if $sub eq $input.subbuf($end-pos, $sub.bytes) {
                        return $end-pos;
                    }
                    $end-pos++;
                }
                return -1;
            }
            react {
                whenever $done-promise {
                    die $_;
                    done;
                }
                whenever IO::Socket::Async.listen('localhost',$port) -> $conn {
                    my Buf $in-buf = Buf.new;
                    whenever $conn.Supply(:bin) -> $buf { 
                        if $in-buf.elems == 0 {
                            my $header-end = _index_buf($buf, Buf.new(13,10));
                            $in-buf ~= $buf.subbuf($header-end + 2);
                        }
                        else {
                            $in-buf ~= $buf;
                        }


                        if (my $header-end = _index_buf($in-buf, Buf.new(13,10,13,10))) > 0 {
                            my $header = $in-buf.subbuf(0, $header-end).decode('ascii');

                            if $header ~~ /Content\-Length\:\s+$<length>=[\d+]/ {
                                my $length = $<length>.Int; 
                                if $in-buf.subbuf($header-end + 4) == $length {
                                    await $conn.write: "HTTP/1.0 200 OK\r\n".encode ~ $in-buf ;
                                    $conn.close;
                                }
                            }
                        }
                    } 
                }
            }
        }
        $server-promise;
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
