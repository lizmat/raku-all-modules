use SSH::LibSSH::Raw;
use NativeCall :types;

# This streaming decoder will be replaced with some Perl 6 streaming encoding
# object once that exists.
my class StreamingDecoder is repr('Decoder') {
    use nqp;

    method new(str $encoding) {
        nqp::decoderconfigure(nqp::create(self), $encoding, nqp::hash())
    }

    method add-bytes(Blob:D $bytes --> Nil) {
        nqp::decoderaddbytes(self, nqp::decont($bytes));
    }

    method consume-available-chars() returns Str {
        nqp::decodertakeavailablechars(self)
    }

    method consume-all-chars() returns Str {
        nqp::decodertakeallchars(self)
    }
}

class X::SSH::LibSSH::Error is Exception {
    has Str $.message;
}

class SSH::LibSSH {
    multi sub error-check($what, $result) {
        if $result == -1 {
            die X::SSH::LibSSH::Error.new(message => "Failed to $what");
        }
        $result
    }
    multi sub error-check(SSHSession $s, $result) {
        if $result == -1 {
            die X::SSH::LibSSH::Error.new(message => ssh_get_error($s));
        }
        $result
    }

    # We use libssh exclusively in non-blocking mode. A single event loop
    # thread manages all interactions with libssh (that is, we only ever make
    # calls to the native API on the one thread spawned by the EventLoop
    # class). Operations are shipped to the event loop via. a channel, and
    # Promise/Supply are used for conveying results. This is the simplest
    # possible non-terrible event loop: it uses dopoll so it isn't in a busy
    # loop, but then it checks for completion of all outstanding operations.
    # This will be fine for a handful of connections, but will scale pretty
    # badly if there are dozens/hundreds. For some (the channel) events there
    # is a callback-based API, which would greatly reduce the number of things
    # we need to poll. However, it needs filling a struct up with callbacks to
    # use it; NativeCall couldn't do that at the time of writing, and the
    # use-case that prompted writing this module only required that it handle
    # a few concurrent connections. So, this approach was fine enough.
    my class EventLoop {
        has Channel $!todo;
        has Thread $!loop-thread;
        has SSHEvent $!loop;
        has int $!active-sessions;
        has @!pollers;
        has Hash %!session-forward-port-map{SSHSession};

        submethod BUILD() {
            $!todo = Channel.new;
            $!loop-thread = Thread.start: :app_lifetime, {
                $!loop = ssh_event_new();
                loop {
                    if $!active-sessions {
                        # We have active sessions, so we'll look for any new
                        # work, then poll the libssh event loop and run any
                        # active poll check callbacks.
                        while $!todo.poll -> &task {
                            task();
                        }
                        ssh_event_dopoll($!loop, 20);
                        @!pollers .= grep: -> &p {
                            my $remove = False;
                            p($remove);
                            !$remove
                        }
                    }
                    else {
                        my &task = $!todo.receive;
                        task();
                    }
                }
            }
        }

        method run-on-loop(&task --> Nil) {
            $!todo.send(&task);
        }

        method add-session(SSHSession $session --> Nil) {
            self!assert-loop-thread();
            error-check('add session to event loop',
                ssh_event_add_session($!loop, $session));
            $!active-sessions++;
        }

        method remove-session(SSHSession $session --> Nil) {
            self!assert-loop-thread();
            error-check('remove session from event loop',
                ssh_event_remove_session($!loop, $session));
            %!session-forward-port-map{$session}:delete;
            $!active-sessions--;
        }

        method add-poller(&poller --> Nil) {
            self!assert-loop-thread();
            @!pollers.push: &poller;
        }

        method add-forward-port-callback(SSHSession $session, Int $port, &callback --> Nil) {
            self!assert-loop-thread();
            unless %!session-forward-port-map{$session}:exists {
                # We aren't listening for incoming forward requests yet; add
                # a poller to do so. We only need one per session.
                self.add-poller: -> $remove is rw {
                    if %!session-forward-port-map{$session}:exists {
                        my $port-num = CArray[int32].new(0);
                        my $channel = ssh_channel_accept_forward($session, 0, $port-num);
                        with $channel {
                            with %!session-forward-port-map{$session}{$port-num[0]} {
                                .($channel);
                            }
                        }
                    }
                    else {
                        $remove = True;
                    }
                }
                %!session-forward-port-map{$session} = {};
            }
            %!session-forward-port-map{$session}{$port} = &callback;
        }

        method !assert-loop-thread() {
            die "Can only call this method on the SSH event loop thread"
                unless $*THREAD === $!loop-thread;
        }
    }

    # The event loop involves creating a thread and a little setup work, so
    # we won't do it until we actually need it, to be cheaper in apps that may
    # use the module but never actually make an SSH connection.
    my Lock $setup-event-loop-lock .= new;
    my EventLoop $event-loop;
    sub get-event-loop() {
        $event-loop // $setup-event-loop-lock.protect: {
            $event-loop //= EventLoop.new;
        }
    }

    class Session { ... }
    class Channel { ... }
    class ForwardingChannel { ... }

    class HostAuthorizationAction {
        enum Outcome <Decline Accept AcceptAndSave>;

        has Session $.session is required;
        has Str $.hash is required;
        has Outcome $.outcome = Decline;

        method accept-this-time() {
            $!outcome = Accept;
        }

        method accept-and-save() {
            $!outcome = AcceptAndSave;
        }

        method decline() {
            $!outcome = Decline;
        }
    }

    enum LogLevel <None Warn Info Debug Trace>;

    class Session {
        my enum State <Fresh Connected Disconnected>;
        has $!state = Fresh;
        has Str $.host;
        has Int $.port;
        has Str $.user;
        has Str $!password;
        has Str $.private-key-file;
        has Int $.timeout;
        has LogLevel $!log-level;
        has &.on-server-unknown;
        has &.on-server-known-changed;
        has &.on-server-found-other;
        has SSHSession $.session-handle;

        submethod BUILD(Str :$!host!, Int :$!port = 22, Str :$!user = $*USER.Str,
                        Str :$!private-key-file = Str, Str :$!password = Str,
                        Int :$!timeout, LogLevel :$!log-level = None,
                        :&!on-server-unknown = &default-server-unknown,
                        :&!on-server-known-changed = &default-server-known-changed,
                        :&!on-server-found-other = &default-server-found-other) {}

        sub default-server-unknown($handler) {
            say "This server is unknown. It presented the public key hash:";
            say $handler.hash;
            given prompt("Do you want to accpet it (yes/once/NO)?") {
                when /:i ^ y[es] $/ { $handler.accept-and-save() }
                when /:i ^ n[o] $/ { $handler.accept-this-time() }
                default { $handler.decline() }
            }
        }

        sub default-server-known-changed($handler) {
            say "The host key for the server has changed, perhaps due to an attack.";
            say "Disconnecting from the server for security reasons.";
        }

        sub default-server-found-other($handler) {
            say "The host key for the server was not found, but a different type of key " ~
                "exists. This may be due to an attacker trying to confuse your client " ~
                "into thinking the key does not exist.";
            say "Disconnecting from the server for security reasons.";
        }

        method connect(:$scheduler = $*SCHEDULER --> Promise) {
            my $p = Promise.new;
            my $v = $p.vow;
            given get-event-loop() -> $loop {
                $loop.run-on-loop: {
                    with $!session-handle = ssh_new() -> $s {
                        ssh_set_blocking($s, 0);
                        error-check($s,
                            ssh_options_set_str($s, SSH_OPTIONS_HOST, $!host));
                        error-check($s,
                            ssh_options_set_int($s, SSH_OPTIONS_PORT, CArray[int32].new($!port)));
                        error-check($s,
                            ssh_options_set_str($s, SSH_OPTIONS_USER, $!user));
                        if $!log-level != None {
                            error-check($s,
                                ssh_options_set_int($s, SSH_OPTIONS_LOG_VERBOSITY,
                                    CArray[int32].new($!log-level)));
                        }
                        with $!timeout {
                            error-check($s,
                                ssh_options_set_int($s, SSH_OPTIONS_TIMEOUT,
                                    CArray[int32].new($!timeout)));
                        }

                        my $outcome = error-check($s, ssh_connect($s));
                        $loop.add-session($s);
                        if $outcome == 0 {
                            # Connected "immediately", more on to auth server.
                            self!connect-auth-server($v, $scheduler);
                        }
                        else {
                            # Will need to poll.
                            $loop.add-poller: -> $remove is rw {
                                if error-check($s, ssh_connect($s)) == 0 {
                                    $remove = True;
                                    self!connect-auth-server($v, $scheduler);
                                }
                                CATCH {
                                    default {
                                        $remove = True;
                                        $v.break($_);
                                    }
                                }
                            }
                        }
                    }
                    else {
                        die X::LibSSH::SSH.new(message => 'Could not allocate SSH session');
                    }
                    CATCH {
                        default {
                            $v.break($_);
                        }
                    }
                }
            }
            $p
        }

        # Performs the server authorization step of connecting.
        method !connect-auth-server($v, $scheduler) {
            given $!session-handle -> $s {
                given SSHServerKnown(error-check($s, ssh_is_server_known($s))) {
                    when SSH_SERVER_KNOWN_OK {
                        self!connect-auth-user($v, $scheduler);
                    }
                    when SSH_SERVER_NOT_KNOWN | SSH_SERVER_FILE_NOT_FOUND {
                        self!auth-server-problem($v, $scheduler, &!on-server-unknown)
                    }
                    when SSH_SERVER_KNOWN_CHANGED {
                        self!auth-server-problem($v, $scheduler, &!on-server-known-changed)
                    }
                    when SSH_SERVER_FOUND_OTHER {
                        self!auth-server-problem($v, $scheduler, &!on-server-found-other)
                    }
                    default {
                        die "Unknown response from ssh_is_server_known";
                    }
                }
                CATCH {
                    default {
                        self!teardown-session();
                        $v.break($_);
                    }
                }
            }
        }

        # Handles cases of server authorization that need intervention.
        method !auth-server-problem($v, $scheduler, &handler) {
            my $hash-buf = CArray[Pointer].new();
            $hash-buf[0] = Pointer;
            my $hash-len = error-check($!session-handle,
                ssh_get_pubkey_hash($!session-handle, $hash-buf));
            my $action = HostAuthorizationAction.new(
                session => self,
                hash => ssh_get_hexa($hash-buf[0], $hash-len)
            );
            ssh_clean_pubkey_hash($hash-buf);

            $scheduler.cue: {
                handler($action);
                get-event-loop().run-on-loop: {
                    given $action.outcome {
                        when HostAuthorizationAction::Accept {
                            self!connect-auth-user($v, $scheduler);
                        }
                        when HostAuthorizationAction::AcceptAndSave {
                            error-check($!session-handle,
                                ssh_write_knownhost($!session-handle));
                            self!connect-auth-user($v, $scheduler);
                        }
                        default {
                            self!teardown-session();
                            $v.break('Host authorization failed');
                        }
                    }
                    CATCH {
                        default {
                            self!teardown-session();
                            $v.break($_);
                        }
                    }
                }
                CATCH {
                    default {
                        self!teardown-session();
                        $v.break($_);
                    }
                }
            };
        }

        # Performs the user authorization step of connecting.
        method !connect-auth-user($v, $scheduler) {
            my $key;
            with $!private-key-file {
                my $key-out = CArray[SSHKey].new;
                $key-out[0] = SSHKey;
                error-check("read private key file $_",
                    ssh_pki_import_privkey_file($_, Str, Pointer, Pointer, $key-out));
                $key = $key-out[0];
            }

            given $!session-handle -> $s {
                my &auth-function = $key
                    ?? { ssh_userauth_publickey($s, Str, $key) }
                    !! { ssh_userauth_publickey_auto($s, Str, Str) };
                my $auth-outcome = SSHAuth(error-check($s, auth-function()));
                if $auth-outcome != SSH_AUTH_AGAIN {
                    ssh_key_free($key) with $key;
                    self!process-auth-outcome($auth-outcome, $v);
                }
                else {
                    # Poll until result available.
                    get-event-loop().add-poller: -> $remove is rw {
                        my $auth-outcome = SSHAuth(error-check($s, auth-function()));
                        if $auth-outcome != SSH_AUTH_AGAIN {
                            $remove = True;
                            ssh_key_free($key) with $key;
                            self!process-auth-outcome($auth-outcome, $v);
                        }
                        CATCH {
                            default {
                                $remove = True;
                                ssh_key_free($key) with $key;
                                self!teardown-session();
                                $v.break($_);
                            }
                        }
                    }
                }
            }
            CATCH {
                default {
                    ssh_key_free($key) with $key;
                    self!teardown-session();
                    $v.break($_);
                }
            }
        }

        method !process-auth-outcome($outcome, $v, :$method = "key") {
            if $outcome == SSH_AUTH_SUCCESS {
                $v.keep(self);
            }
            else {
                if $method eq "key" and defined $!password {
                    # Public Key authentication failed. We'll try using a password now.
                    self!connect-auth-user-password($v);
                } else {
                    self!teardown-session();
                    $v.break(X::SSH::LibSSH::Error.new(message => 'Authentication failed'));
                }
            }
        }

        method !connect-auth-user-password($v) {
            given $!session-handle -> $s {
                my &auth-function = { ssh_userauth_password($s, Str, $!password) }
                my $auth-outcome = SSHAuth(error-check($s, auth-function()));
                if $auth-outcome != SSH_AUTH_AGAIN {
                    self!process-auth-outcome($auth-outcome, $v, :method<password>);
                } else {
                    # Poll until result available.
                    get-event-loop().add-poller: -> $remove is rw {
                        my $auth-outcome = SSHAuth(error-check($s, auth-function()));
                        if $auth-outcome != SSH_AUTH_AGAIN {
                            $remove = True;
                            self!process-auth-outcome($auth-outcome, $v, :method<password>);
                        }
                        CATCH {
                            default {
                                $remove = True;
                                self!teardown-session();
                                $v.break($_);
                            }
                        }
                    }
                }
            }
            CATCH {
                default {
                    self!teardown-session();
                    $v.break($_);
                }
            }
        }

        method execute($command --> Promise) {
            my $p = Promise.new;
            my $v = $p.vow;
            given get-event-loop() -> $loop {
                $loop.run-on-loop: {
                    my $channel = ssh_channel_new($!session-handle);
                    with $channel {
                        my $open = error-check($!session-handle,
                            ssh_channel_open_session($channel));
                        if $open == 0 {
                            self!execute-on-channel($channel, $command, $v);
                        }
                        else {
                            $loop.add-poller: -> $remove is rw {
                                my $open = error-check($!session-handle,
                                    ssh_channel_open_session($channel));
                                if $open == 0 {
                                    $remove = True;
                                    self!execute-on-channel($channel, $command, $v);
                                }
                                CATCH {
                                    default {
                                        $remove = True;
                                        $v.break($_);
                                    }
                                }
                            }
                        }
                        CATCH {
                            default {
                                $v.break($_);
                            }
                        }
                    }
                    else {
                        $v.break(X::SSH::LibSSH::Error.new(message => 'Could not allocate channel'));
                    }
                }
            }
            $p
        }

        method !execute-on-channel(SSHChannel $channel, Str $command, $v) {
            my $exec = error-check($!session-handle,
                ssh_channel_request_exec($channel, $command));
            if $exec == 0 {
                $v.keep(Channel.from-raw-handle($channel, self));
            }
            else {
                get-event-loop().add-poller: -> $remove is rw {
                    my $exec = error-check($!session-handle,
                        ssh_channel_request_exec($channel, $command));
                    if $exec == 0 {
                        $remove = True;
                        $v.keep(Channel.from-raw-handle($channel, self));
                    }
                    CATCH {
                        default {
                            $remove = True;
                            $v.break($_);
                        }
                    }
                }
            }
            CATCH {
                default {
                    $v.break($_);
                }
            }
        }

        method forward(Str() $remote-host, Int() $remote-port, Str() $source-host,
                       Int() $local-port  --> Promise) {
            my $p = Promise.new;
            my $v = $p.vow;
            given get-event-loop() -> $loop {
                $loop.run-on-loop: {
                    my $channel = ssh_channel_new($!session-handle);
                    with $channel {
                        my $forward = error-check($!session-handle,
                            ssh_channel_open_forward($channel, $remote-host, $remote-port,
                                $source-host, $local-port));
                        if $forward == 0 {
                            $v.keep(self!make-forward-channel($channel));
                        }
                        else {
                            $loop.add-poller: -> $remove is rw {
                                my $forward = error-check($!session-handle,
                                    ssh_channel_open_forward($channel, $remote-host, $remote-port,
                                        $source-host, $local-port));
                                if $forward == 0 {
                                    $remove = True;
                                    $v.keep(self!make-forward-channel($channel));
                                }
                                CATCH {
                                    default {
                                        $remove = True;
                                        $v.break($_);
                                    }
                                }
                            }
                        }
                        CATCH {
                            default {
                                $v.break($_);
                            }
                        }
                    }
                    else {
                        $v.break(X::SSH::LibSSH::Error.new(message => 'Could not allocate channel'));
                    }
                }
            }
            $p
        }

        method reverse-forward(Int() $remote-port, Cool $address-to-bind? --> Supply) {
            my Supplier::Preserving $connections .= new;
            given get-event-loop() -> $loop {
                $loop.run-on-loop: {
                    my $bind = $address-to-bind.defined ?? $address-to-bind.Str !! Str;
                    my &callback = -> SSHChannel $channel {
                        $connections.emit(self!make-forward-channel($channel));
                    }
                    my $result = error-check($!session-handle,
                        ssh_channel_listen_forward($!session-handle, $bind, $remote-port,
                            CArray[int32]));
                    if $result == 0 {
                        $loop.add-forward-port-callback($!session-handle,
                            $remote-port, &callback);
                    }
                    else {
                        $loop.add-poller: -> $remove is rw {
                            my $result = error-check($!session-handle,
                                ssh_channel_listen_forward($!session-handle, $bind, $remote-port,
                                    CArray[int32]));
                            if $result == 0 {
                                $remove = True;
                                $loop.add-forward-port-callback($!session-handle,
                                    $remote-port, &callback);
                            }
                            CATCH {
                                default {
                                    $remove = True;
                                    $connections.quit($_);
                                }
                            }
                        }
                    }
                    CATCH {
                        default {
                            $connections.quit($_);
                        }
                    }
                }
            }
            $connections.Supply
        }

        method !make-forward-channel(SSHChannel $channel --> ForwardingChannel) {
            ForwardingChannel.new(channel => Channel.from-raw-handle($channel, self))
        }

        # For SCP, the libssh async interface unfortunately does not work.
        # Thankfully, SCP is a relatively easy protocol, so we can just do
        # what libssh does to implement it in terms of a reuqest channel.

        method scp-download(Str $remote-path, Str $local-path --> Promise) {
            start {
                my $channel = await self.execute("scp -f $remote-path");
                await $channel.write(Blob.new(0));
                react {
                    my enum State <ExpectHeader ExpectBody>;
                    my $state = ExpectHeader;
                    my $buffer;
                    my $bytes-remaining;
                    my $mode;

                    sub write-to-file(Blob $data) {
                        state $target-file //= open $local-path, :w, :bin;
                        $bytes-remaining -= $data.elems;
                        $target-file.write($bytes-remaining >= 0
                            ?? $data
                            !! $data.subbuf(0, $data.elems + $bytes-remaining));
                        unless $bytes-remaining > 0 {
                            $target-file.close;
                            chmod $mode, $local-path;
                            done;
                        }
                    }

                    whenever $channel.stdout(:bin) -> $data {
                        if $state == ExpectHeader {
                            my $header;
                            $buffer = $buffer ?? $buffer ~ $data !! $data;
                            loop (my int $i = 0; $i < $buffer.elems; $i++) {
                                if $buffer[$i] == ord("\n") {
                                    $header = $buffer.subbuf(0, $i);
                                    $buffer = $buffer.subbuf($i);
                                    last;
                                }
                            }
                            with $header {
                                if $header[0] == ord('C') {
                                    # It's the file.
                                    my @parts = $header.decode('latin-1').substr(1).split(' ', 3);
                                    die "Malformed SCP file header" unless @parts == 3;
                                    $mode = :8(@parts[0]);
                                    $bytes-remaining = @parts[1].Int;
                                    await $channel.write(Blob.new(0));
                                    $state = ExpectBody;
                                }
                                else {
                                    die "Unexpected SCP file header char '$header[0]'";
                                }
                            }
                        }
                        elsif $state == ExpectBody {
                            write-to-file($data);
                        }
                    }
                }
                $channel.close;
            }
        }

        method scp-upload($local-path, $remote-path --> Promise) {
            start {
                my $to-send = slurp $local-path, :bin;
                my $mode = ~$local-path.IO.mode;
                my $channel = await self.execute("scp -t $remote-path");
                react {
                    my enum State <Initial SentHeader SendingBody BodySent>;
                    my $state = Initial;

                    sub check-status-code($data) {
                        unless $data.elems == 1 && $data[0] == 0 {
                            die "Unexpected SCP status $data[0]: " ~
                                $data.subbuf(1).decode('latin-1');
                        }
                    }

                    whenever $channel.stdout(:bin) -> $data {
                        given $state {
                            when Initial {
                                check-status-code($data);
                                my $header = "C$mode $to-send.elems() \n";
                                $state = SentHeader;
                                whenever $channel.write($header.encode('utf8-c8')) {}
                            }
                            when SentHeader {
                                check-status-code($data);
                                $state = SendingBody;
                                whenever $channel.write($to-send) {
                                    $state = BodySent;
                                    whenever $channel.close-stdin() {}
                                }
                            }
                            when BodySent {
                                done;
                            }
                        }
                    }
                }
                $channel.close;
            }
        }

        method close() {
            my $p = Promise.new;
            given get-event-loop() -> $loop {
                $loop.run-on-loop: {
                    self!teardown-session();
                    $p.keep(True);
                    CATCH {
                        default {
                            $p.break($_);
                        }
                    }
                }
            }
            await $p;
        }

        method !teardown-session() {
            with $!session-handle {
                get-event-loop().remove-session($!session-handle);
                ssh_disconnect($_);
                ssh_free($_);
            }
            $!session-handle = SSHSession;
        }
    }

    class Channel {
        has Session $.session;
        has SSHChannel $.channel-handle;
        has Promise $!stdout-eof;
        has Promise $!stderr-eof;

        method new() {
            die X::SSH::LibSSH::Error.new(message =>
                'A channel cannot be created directly. Use a method on Session to make one.');
        }

        method from-raw-handle($channel-handle, $session) {
            self.bless(:$channel-handle, :$session)
        }

        submethod BUILD(SSHChannel :$!channel-handle!, Session :$!session) {}

        method stdout(*%options --> Supply) {
            self!std-reader(0, |%options)
        }

        method stderr(*%options --> Supply) {
            self!std-reader(1, |%options)
        }

        method !std-reader($is-stderr, :$bin, :$enc, :$scheduler = $*SCHEDULER) {
            my Supplier::Preserving $s .= new;
            given get-event-loop() -> $loop {
                $loop.run-on-loop: {
                    ($is-stderr ?? $!stderr-eof !! $!stdout-eof) //= Promise.new;
                    my $decoder = $bin
                        ?? Nil
                        !! StreamingDecoder.new(Rakudo::Internals.NORMALIZE_ENCODING(
                                $enc // 'utf-8'));
                    $loop.add-poller: -> $remove is rw {
                        my $buf = Buf.allocate(32768);
                        my $nread = ssh_channel_read_nonblocking($!channel-handle, $buf,
                            32768, $is-stderr);
                        if $nread > 0 {
                            $buf .= subbuf(0, $nread);
                            if $bin {
                                $s.emit($buf);
                            }
                            else {
                                $decoder.add-bytes($buf);
                                $s.emit($decoder.consume-available-chars());
                            }
                        }
                        elsif ssh_channel_is_eof($!channel-handle) {
                            $remove = True;
                            unless $bin {
                                $s.emit($decoder.consume-all-chars());
                            }
                            $s.done();
                        }
                        else {
                            error-check($!session.session-handle, $nread);
                        }
                        CATCH {
                            default {
                                $remove = True;
                                $s.quit($_);
                            }
                        }
                    }
                }
            }

            # Get observation off the worker thread.
            supply {
                whenever $s.Supply.Channel.Supply {
                    .emit;
                    LAST {
                        try ($is-stderr ?? $!stderr-eof !! $!stdout-eof).keep(True);
                    }
                }
            }
        }

        method write(Blob:D $data --> Promise) {
            my $p = Promise.new;
            my $v = $p.vow;
            given get-event-loop() -> $loop {
                $loop.run-on-loop: {
                    my int $left-to-send = $data.elems;
                    sub maybe-send-something-now() {
                        my uint $ws = ssh_channel_window_size($!channel-handle);
                        my $send = [min] $ws, 0xFFFFF, $left-to-send;
                        if $send {
                            my $send-buf = $data.subbuf($data.elems - $left-to-send, $send);
                            my $rv = error-check($!session.session-handle,
                                ssh_channel_write($!channel-handle, $send-buf, $send));
                            $left-to-send -= $send;
                            CATCH {
                                default {
                                    $v.break($_);
                                    return True;
                                }
                            }
                            if $left-to-send == 0 {
                                $v.keep(True);
                                return True;
                            }
                        }
                        return False;
                    }

                    unless maybe-send-something-now() {
                        $loop.add-poller: -> $remove is rw {
                            $remove = maybe-send-something-now();
                        }
                    }
                }
            }
            $p
        }

        method print(Str() $data) {
            self.write($data.encode('utf-8'));
        }

        method say(Str() $data) {
            self.print($data ~ "\n")
        }

        method close-stdin() {
            my $p = Promise.new;
            my $v = $p.vow;
            given get-event-loop() -> $loop {
                error-check($!session.session-handle, ssh_channel_send_eof($!channel-handle));
                $v.keep(True);
                CATCH {
                    default {
                        $v.break($_);
                    }
                }
            }
            await $p;
        }

        method exit() {
            my $p = Promise.new;
            my $v = $p.vow;
            given get-event-loop() -> $loop {
                $loop.run-on-loop: {
                    $loop.add-poller: -> $remove is rw {
                        if $!stdout-eof && $!stderr-eof {
                            my $exit = ssh_channel_get_exit_status($!channel-handle);
                            if $exit >= 0 {
                                $remove = True;
                                my @awaitees = ($!stdout-eof, $!stderr-eof).grep(*.defined);
                                if @awaitees {
                                    Promise.allof(@awaitees).then({ $v.keep($exit) });
                                }
                                else {
                                    $v.keep($exit);
                                }
                            }
                        }
                    }
                }
            }
            $p
        }

        method close() {
            my $p = Promise.new;
            my $v = $p.vow;
            get-event-loop().run-on-loop: {
                with $!channel-handle {
                    error-check('close a channel', ssh_channel_close($_));
                    ssh_channel_free($_);
                }
                $!channel-handle = SSHChannel;
                $v.keep(True);
                CATCH {
                    default {
                        $v.break($_);
                    }
                }
            }
            await $p;
        }
    }

    # Wraps around Channel and provides an API more relevant to forwarding.
    class ForwardingChannel {
        has Channel $.channel handles <write print say close>;

        method Supply(*%options) {
            $!channel.stdout(|%options)
        }
    }

    method connect(Str :$host!, *%options --> Promise) {
        Session.new(:$host, |%options).connect
    }

    class LogEntry {
        has LogLevel $.level;
        has Str $.function;
        has Str $.message;
    }

    my Supplier $logs;
    my Lock $logs-lock .= new;
    method logs(--> Supply) {
        $logs-lock.protect: {
            without $logs {
                $logs = Supplier.new;
                error-check('set logging callback', ssh_set_log_callback(
                    -> int32 $level-int, Str $function, Str $message, Pointer $ {
                        my $level = LogLevel($level-int);
                        $logs.emit(LogEntry.new(:$level, :$function, :$message));
                    }));
            }
            $logs.Supply
        }
    }
}
