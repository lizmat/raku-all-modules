use v6;

unit class HTTP::Server::Smack::HTTP1x does HTTP::Server::Smack::Protocol;

constant CR = 0x0d;
constant LF = 0x0a;
constant CRLF2 = Buf.new(CR, LF, CR, LF);

constant HTTP2-PREFACE-HEAD = Buf.new(
    # :16{505249202a20485454502f322e300d0a0d0a} - or whatever the final notation ends up being
    # PRI * HTTP/2.0\r\n
    0x50, 0x52, 0x49, 0x20, 0x2a, 0x20, 0x48, 0x54, 0x54, 0x50, 0x2f, 0x32, 0x2e, 0x30, 0x0d, 0x0a,
    # \r\n
    CR, LF,
);

constant HTTP2-PREFACE-PAYLOAD = Buf.new(
    # :16{534d0d0a0d0a} - or whatever the final notation ends up being
    # SM\r\n
    0x53, 0x4d, CR, LF,
    # \r\n
    CR, LF,
);

constant HTTP2-PREFACE = HTTP2-PREFACE-HEAD ~ HTTP2-PREFACE-PAYLOAD;


method run(:$conn, :%env, :%int, :&app, :$buf) {
    # TODO Implement HTTP/2
    ...
}

    # They appear to be talking HTTP/2, verify and switch protocols or die
    if $whole-buf.subbuf(0, HTTP2-PREFACE-HEAD.bytes) eq HTTP2-PREFACE-HEAD {

        # Let's make sure we have the next 4 bytes
        if $whole-buf.bytes < HTTP2-PREFACE.bytes {
            $whole-buf ~= $conn.recv(HTTP2-PREFACE.bytes - $whole-buf.bytes, :bin);
        }

        # verify the rest of the HTTP/2 connetion preface
        if $whole-buf.subbuf(0, HTTP2-PREFACE.bytes) eq HTTP2-PREFACE {

            # TODO We need a smarter way to pass control completely over to
            # the HTTP/2 protocol handler that breaks out of the outer .run
            # call which will manage HTTP/1.1 connection persistence
            return HTTP::Server::Smack::HTTP2.new.run(
                :$conn,
                :%env,
                :%int,
                :&app,

                # They need the buf so far, minus the preface
                :buf($whole-buf.subbuf(HTTP2-PREFACE.bytes))
            );
        }
        else {
            self.error-response('Incorrect HTTP/2 connection preface', :$conn, :%env);
            return;
        }
    }
