
use v6.c;

use String::CRC32;

unit class Cache::Memcached:auth<cosimo>:ver<0.0.7>;

has Bool  $.debug is rw = False;
has Bool  $.no-rehash is rw;
has       %!stats;
has Bool  $.readonly is rw;
has       &.stat-callback is rw;
has Str   $.namespace = "";
has Int   $!namespace_len = 0;
has       @!servers = ();
has       $!active;
has Str   @.buckets = (); # is rw;
has Int   $!bucketcount = 0;
has       $!_single_sock = False;
has       $!_stime;
has Rat   $.connect-timeout is rw;
has       @!buck2sock;
has Version $!server-version;

submethod BUILD(:@!servers, Bool :$!debug = False, Str :$namespace) {

    $!namespace = ( $namespace // "" );
    # TODO understand why @!servers is empty here
    if ! @!servers {
        self.log-debug("setting default servers");
        @!servers = "127.0.0.1:11211";
    }

    self.log-debug("Setting servers: ", @!servers);
    self.set-servers(@!servers);
}

our $VERSION       = v0.0.5;


our $SOCK_TIMEOUT = 2.6; # default timeout in seconds

my %host_dead;   # host -> unixtime marked dead until
my %cache_sock;  # host -> socket
my $PROTO_TCP;


method set-servers (@servers) {

    @!servers = @servers;
    $!active = +@servers;

    @!buckets = ();
    $!bucketcount = 0;
    $.init-buckets();
    @!buck2sock = ();
    $!_single_sock = Mu;

    if +@servers == 1 {
        $!_single_sock = @servers[0];
    }
}


method forget-dead-hosts () {
    %host_dead = ();
    @!buck2sock = ();
}

my %sock_map;  # stringified-$sock -> "$ip:$port"


method !dead-sock ($sock, $ret, $dead_for) {
    if $sock.defined {
        if my $ipport = %sock_map{$sock} {
            %host_dead{$ipport} = now + $dead_for if $dead_for;
            %cache_sock.delete($ipport);
            %sock_map.delete($sock);
        }
    }
    @!buck2sock = ();
    return $ret;
}


method !close-sock ($sock) {
    if my $ipport = %sock_map{$sock} {
        $sock.close();
        %cache_sock.delete($ipport);
        %sock_map.delete($sock);
    }
    @!buck2sock = ();
}


sub connect-sock ($sock, $sin, $timeout = 0.25) returns IO::Socket {

    # make the socket non-blocking from now on,
    # except if someone wants 0 timeout, meaning
    # a blocking connect, but even then turn it
    # non-blocking at the end of this function
    
    # TODO FIXME
    my $host = $sock;
    my $port = $sin;

    my $ret;

    try {
        my $sock_obj = IO::Socket::INET.new(host => $host, port => $port);

        if $sock {
            $ret = $sock_obj;
        }
        CATCH {
           default {
              say $_.message;
           }
        }
    }

    return $ret;
}


# Why is this public? I wouldn't have to worry about undef $self if it weren't.
method sock-to-host (Str $host) {

    $.log-debug("sock-to-host");
    if %cache_sock{$host} {
        $.log-debug("cache_sock hit");
        return %cache_sock{$host};
    }
    
    my $now = time;
    my $ip;
    my $port;

    if $host ~~ m/ (.*) \: (\d+) / {
        $ip = $0.Str;
        $port = $1.Int;
        # Get rid of optional IPv6 brackets
        $ip ~~ s:g [ \[ | \] ] = '' if $ip.defined;
    }

    if %host_dead{$host} && %host_dead{$host} > $now {
        return;
    }

    my $timeout = $!connect-timeout //= 0.25;
    my $sock = connect-sock($ip, $port, $timeout);

    if ! $sock {
        $.log-debug("sock not defined");
        return self!dead-sock($sock, Nil, 20 + 10.rand.Int);
    }

    %sock_map{$sock} = $host;
    %cache_sock{$host} = $sock;

    return $sock;
}


method get-sock ($key) {

    if $!_single_sock {
        return $.sock-to-host($!_single_sock);
    }

    return unless $!active;

    # TODO $key array
    my $hv = hashfunc($key);
    my $tries = 0;

    while $tries++ < 20 {
        my $host = @!buckets[ $hv % $!bucketcount ];
        my $sock = $.sock-to-host($host);
        return $sock if $sock;
        return if $!no-rehash;
        $hv += hashfunc($tries ~ $key); # stupid, but works
    }

    return;
}


method init-buckets () {

    $.log-debug("init-buckets with ", @!buckets);

    if not @!buckets.elems {
        $.log-debug("setting buckets");

        for @!servers -> $v {
            $.log-debug("adding server to buckets $v");
            # TODO support weighted servers
            # [ ['127.0.0.1:11211', 2],
            #   ['127.0.0.1:11212', 1], ]
            @!buckets.push($v);
        }

    }
    else {
        self.log-debug("already got buckets : ", @!buckets);
    }
    $!bucketcount = +@!buckets;

    return $!bucketcount;
}


method disconnect-all () {
    for %cache_sock.values -> $sock {
        $sock.close() if $sock;
    }
    %cache_sock = ();
    @!buck2sock = ();
}


# writes a line, then reads result.  by default stops reading after a
# single line, but caller can override the $check_complete subref,
# which gets passed a scalarref of buffer read thus far.
method write-and-read (IO::Socket $sock, Str $command, Mu $check_complete?) {

    my $res;
    my $ret = Mu; 
    my $offset = 0;
    my $line = $command;

    #$check_complete //= sub ($ret) {
    #    return ($ret.rindex("\x0D\x0A") + 2) == $ret.chars;
    #};

    # state: 0 - writing, 1 - reading, 2 - done
    my $state = 0;
    my $copy_state = -1;
  
    loop {

        if $copy_state != $state {
            last if $state == 2;
            $copy_state = $state;
        }

        my $to_send = $line.chars;

        $.log-debug("Chars to send: $to_send");


        if $to_send > 0 {
            my $sent = $sock.print($line);
            if $sent == 0 {
                self!close-sock($sock);
                return;
            }
            $to_send -= $sent;
            if $to_send == 0 {
                $state = 1;
            }
            else {
                $line = $line.substr($sent);
            }
        }

        $.log-debug("Receiving from socket");

        $ret = $sock.recv();
        #$ret = "";
        #while (my $c = $sock.recv(1)) {
        #    $ret ~= $c;
        #}

        $.log-debug("Got from socket (recv=" ~ $ret.perl ~ ")");

        if $ret ~~ m/\r\n$/ {
            $.log-debug("Got a terminator (\\r\\n)");
            $state = 2;
            last;
        }

    }

    # Improperly finished
    unless $state == 2 {
        self!dead-sock($sock);
        return;
    }

    return $ret;
}


method delete ($key, $time = "") {

    return 0 if ! $!active || $!readonly;

    my $stime;
    my $etime;

    $stime = now if &!stat-callback;

    my $sock = $.get-sock($key);
    return 0 unless $sock;

    %!stats<delete>++;

    # TODO support array keys
    my $cmd = "delete " ~ $!namespace ~ $key ~ $time ~ "\r\n";
    my $res = self.write-and-read($sock, $cmd);

    if &!stat-callback {
        my $etime = now;
        &!stat-callback.($stime, $etime, $sock, 'delete');        
    }

    return $res.defined && $res eq "DELETED\r\n";
}


method add ($key, $value) {
    self!_set('add', $key, $value);
}

method replace ($key, $value) {
    self!_set('replace', $key, $value);
}

method set ($key, $value) {
    self!_set('set', $key, $value);
}

method append ($key, $value) {
    self!_set('append', $key, $value);
}

method prepend ($key, $value) {
    self!_set('prepend', $key, $value);
}

method !_set ($cmdname, $key, $val, Int $exptime = 0) {
    return 0 if ! $!active || $!readonly;
    my $stime;
    my $etime;

    $stime = now if &!stat-callback;
    my $sock = $.get-sock($key);
    return 0 unless $sock;

    my $app_or_prep = ($cmdname eq 'append' or $cmdname eq 'prepend') ?? 1 !! 0;
    %!stats{$cmdname}++;

    my $flags = 0;
    my $len = $val.chars;

    # TODO COMPRESS THRESHOLD support
    #$exptime //= 0;
    #$exptime = $exptime.Int;
    my $line = "$cmdname " ~ $!namespace ~ "$key $flags $exptime $len\r\n$val\r\n";
    my $res  = self.write-and-read($sock, $line);

    if $!debug && $line {
        $line.chop.chop;
        warn "Cache::Memcache: {$cmdname} {$!namespace}{$key} = {$val} ({$line})\n";
    }

    if &!stat-callback {
        my $etime = Time::HiRes::time();
        &!stat-callback.($stime, $etime, $sock, $cmdname);
    }
    
    return $res.defined && $res eq "STORED\r\n";

}

method incr ($key, $offset) {
    self!incrdecr("incr", $key, $offset);
}

method decr ($key, $offset) {
    self!incrdecr("decr", $key, $offset);
}

method !incrdecr ($cmdname, $key, $value) {
    return if ! $!active || $!readonly;

    my $stime;

    $stime = now if &!stat-callback;
    my $sock = $.get-sock($key);
    return unless $sock;

    %!stats{$cmdname}++;
    $value = 1 unless defined $value;

    my $line = "$cmdname " ~ $!namespace ~ "$key $value\r\n";
    my $res = self.write-and-read($sock, $line);

    if &!stat-callback {
        my $etime = now;
        &!stat-callback.($stime, $etime, $sock, $cmdname);
    }

    return defined $res && $res eq "STORED\r\n";
}


method get ($key) {

    my @res;
    my $hv = hashfunc($key);
    $.log-debug("get(): hash value '$hv'");

    my $sock = $.get-sock($key);
    if $sock.defined {
        $.log-debug("get(): socket '$sock'");

        my $namespace = $!namespace // "";
        my $full_key = $namespace ~ $key;
        $.log-debug("get(): full key '$full_key'");
   
        my $get_cmd = "get $full_key\r\n";
        $.log-debug("get(): command '$get_cmd'");

        @res = self.run-command($sock, $get_cmd);

        %!stats<get>++;

        $.log-debug("memcache: got " ~ @res.perl);
    }
    else {
       $.log-debug("No socket ...");
    }

    return @res[1].defined ?? @res[1] !! Nil;
}

sub hashfunc(Str $key) {
    my $crc = String::CRC32::crc32($key);
    $crc +>= 16;
    $crc +&= 0x7FFF;
    return $crc;
}


method flush-all () {
    my $success = 1;
    my @hosts = @!buckets;

    for @hosts -> $host {
        my $sock = $.sock-to-host($host);
        my @res = $.run-command($sock, "flush-all\r\n");
        $success = 0 unless @res == 1 && @res[0] eq "OK\r\n";
    }

    return $success;
}



# Returns array of lines, or () on failure.
method run-command ($sock, $cmd) {

    return unless $sock;

    my $ret = "";
    my $line = $cmd;

    while (my $res = self.write-and-read($sock, $line)) {
        $line = "";
        $ret ~= $res;
        $.log-debug("Received [$res] total [$ret]");
        last if $ret ~~ /[ OK | END | ERROR ]\r\n$/;
    }

    $ret .= chop;
    $ret .= chop;

    #$ret.split("\r\n") ==> map { "$_\r\n" } ==> my @lines;
    my @lines = $ret.split(/\r\n/);

    return @lines;
}

method stats(*@types) {

    my %stats_hr = ();

    if $!active {
        if not @types.elems {
            @types = <misc malloc self>;
        }

        # The "self" stat type is special, it only applies to this very
        # object.
        if @types ~~ /^self$/ {
            %stats_hr<self> = %!stats.clone;
        }

        my %misc_keys = <bytes bytes_read bytes_written
            cmd_get cmd_set connection_structures curr_items
            get_hits get_misses
            total_connections total_items>.map({ $_ => 1 });

        # Now handle the other types, passing each type to each host server.
        my @hosts = @!buckets;

        HOST: 
        for @hosts -> $host {
            my $sock = $.sock-to-host($host);
            next HOST unless $sock;
            TYPE: 
            for @types.grep({ $_ !~~ /^self$/ }) -> $typename {
                my $type = $typename eq 'misc' ?? "" !! " $typename";
                my $lines = self.write-and-read($sock, "stats$type\r\n", -> $bref {
                    return $bref ~~ /:m^[END|ERROR]\r?\n/;
                });
                unless ($lines) {
                    self!dead-sock($sock);
                    next HOST;
                }

                $lines ~~ s:g/\0//;  # 'stats sizes' starts with NULL?

                # And, most lines end in \r\n but 'stats maps' (as of
                # July 2003 at least) ends in \n. ??
                my @lines = $lines.split(/\r?\n/);

                # Some stats are key-value, some are not.  malloc,
                # sizes, and the empty string are key-value.
                # ("self" was handled separately above.)
                if $typename ~~ any(<malloc sizes misc>) {
                    # This stat is key-value.
                    for @lines -> $line {
                        if $line ~~ /^STAT\s+(\w+)\s(.*)/ {
                            my $key = $0;
                            my $value = $1;
                            if ($key) {
                                %stats_hr<hosts>{$host}{$typename}{$key} = $value;
                            }
                            %stats_hr<total>{$key} += $value
                                if $typename eq 'misc' && $key && %misc_keys{$key};
                            %stats_hr<total>{"malloc_$key"} += $value
                            if $typename eq 'malloc' && $key;
                        }
                    }
                } 
                else {
                    # This stat is not key-value so just pull it
                    # all out in one blob.
                    $lines ~~ s:m/^END\r?\n//;
                    %stats_hr<hosts>{$host}{$typename} ||= "";
                    %stats_hr<hosts>{$host}{$typename} ~= "$lines";
                }
            }
        }
    }

    return %stats_hr;
}

method stats-reset ($types) returns Bool {

    my Bool $rc = False;

    if $!active {
        for @!buckets -> $host {
            my $sock = self.sock-to-host($host);
            next unless $sock;
            my $ok = self.write-and-read($sock, "stats reset");
            unless (defined $ok && $ok eq "RESET\r\n") {
                self!dead-sock($sock);
            }
        }
        $rc = True;
    }
    return $rc;
}

method log-debug(*@message ) {
    if $!debug {
        say @message;
    }
}



=begin pod

=head1 NAME

Cache::Memcached - client library for memcached (memory cache daemon)

=head1 SYNOPSIS

=begin code 

  use Cache::Memcached;

  my $memd = Cache::Memcached.new;

  $memd->set("my_key", "Some value");

  $memd->incr("key");
  $memd->decr("key");
  $memd->incr("key", 2);

=end code

=head1 DESCRIPTION

This is the Perl 6 API for memcached, a distributed memory cache daemon.
More information is available at:

  http://www.danga.com/memcached/

=head1 METHODS


=head2 method new

Takes named parameters.  The most important key is
C<servers>, but that can also be set later with the C<set-servers>
method.  The servers must be an arrayref of hosts, each of which is
either a scalar of the form C<10.0.0.10:11211> or an arrayref of the
former and an integer weight value.  (The default weight if
unspecified is 1.)  It's recommended that weight values be kept as low
as possible, as this module currently allocates memory for bucket
distribution proportional to the total host weights.

Use C<no-rehash> to disable finding a new memcached server when one
goes down.  Your application may or may not need this, depending on
your expirations and key usage.

Use C<readonly> to disable writes to backend memcached servers.  Only
get and get_multi will work.  This is useful in bizarre debug and
profiling cases only.

Use C<namespace> to prefix all keys with the provided namespace value.
That is, if you set namespace to "app1:" and later do a set of "foo"
to "bar", memcached is actually seeing you set "app1:foo" to "bar".

The other useful key is C<debug>, which when set to true will produce
diagnostics on STDERR.

=head2 method set-servers

Sets the server list this module distributes key gets and sets between.
The format is an arrayref of identical form as described in the C<new>
constructor.

=head2 method get

    my $val $memd.get($key);

Retrieves a key from the memcache.  Returns the value (automatically
thawed with Storable, if necessary) or undef.

The $key can optionally be an arrayref, with the first element being the
hash value, if you want to avoid making this module calculate a hash
value.  You may prefer, for example, to keep all of a given user's
objects on the same memcache server, so you could use the user's
unique id as the hash value.

=head2 method get_multi

    my $hashref = $memd.get_multi(@keys);

Retrieves multiple keys from the memcache doing just one query.
Returns a hashref of key/value pairs that were available.

This method is recommended over regular 'get' as it lowers the number
of total packets flying around your network, reducing total latency,
since your app doesn't have to wait for each round-trip of 'get'
before sending the next one.

=head2 method set

    $memd.set($key, $value[, $exptime]);

Unconditionally sets a key to a given value in the memcache.  Returns true
if it was stored successfully.

The $key can optionally be an arrayref, with the first element being the
hash value, as described above.

The $exptime (expiration time) defaults to "never" if unspecified.  If
you want the key to expire in memcached, pass an integer $exptime.  If
value is less than 60*60*24*30 (30 days), time is assumed to be relative
from the present.  If larger, it's considered an absolute Unix time.

=head2 method add

    $memd.add($key, $value[, $exptime]);

Like C<set>, but only stores in memcache if the key doesn't already exist.

=head2 method replace

    $memd.replace($key, $value[, $exptime]);

Like C<set>, but only stores in memcache if the key already exists.  The
opposite of C<add>.

=head2 method delete

    $memd.delete($key[, $time]);

Deletes a key.  You may optionally provide an integer time value (in
seconds) to tell the memcached server to block new writes to this key for
that many seconds.  (Sometimes useful as a hacky means to prevent races.)
Returns true if key was found and deleted, and false otherwise.

=head2 method incr

    $memd.incr($key[, $value]);

Sends a command to the server to atomically increment the value for
$key by $value, or by 1 if $value is undefined.  Returns undef if $key
doesn't exist on server, otherwise it returns the new value after
incrementing.  Value should be zero or greater.  Overflow on server
is not checked.  Be aware of values approaching 2**32.  See decr.

=head2 method decr

    $memd.decr($key[, $value]);

Like incr, but decrements.  Unlike incr, underflow is checked and new
values are capped at 0.  If server value is 1, a decrement of 2
returns 0, not -1.

=head2 method stats

    $memd.stats(@keys);

Returns a L<Hash> of statistical data regarding the memcache server(s),
the $memd object, or both.  $keys can be a list  of keys wanted, a
single key wanted, or absent (in which case the default value is malloc,
sizes, self, and the empty string).  These keys are the values passed
to the 'stats' command issued to the memcached server(s), except for
'self' which is internal to the $memd object.  Allowed values are:

=head3 C<misc>

The stats returned by a 'stats' command:  pid, uptime, version,
bytes, get_hits, etc.

=head3 C<malloc>

The stats returned by a 'stats malloc':  total_alloc, arena_size, etc.

=head3 C<sizes>

The stats returned by a 'stats sizes'.

=head3 C<self>

The stats for the $memd object itself (a copy of $memd->{'stats'}).

=head3 C<maps>

The stats returned by a 'stats maps'.

=head3 C<cachedump>

The stats returned by a 'stats cachedump'.

=head3 C<slabs>

The stats returned by a 'stats slabs'.

=head3 C<items>

The stats returned by a 'stats items'.

=head2 method disconnect-all

    $memd.disconnect-all;

Closes all cached sockets to all memcached servers.  You must do this
if your program forks and the parent has used this module at all.
Otherwise the children will try to use cached sockets and they'll fight
(as children do) and garble the client/server protocol.

=head2 method flush-all

    $memd.flush-all;

Runs the memcached "flush-all" command on all configured hosts,
emptying all their caches.  (or rather, invalidating all items
in the caches in an O(1) operation...)  Running stats will still
show the item existing, they're just be non-existent and lazily
destroyed next time you try to detch any of them.


=head1 BUGS

When a server goes down, this module does detect it, and re-hashes the
request to the remaining servers, but the way it does it isn't very
clean.  The result may be that it gives up during its rehashing and
refuses to get/set something it could've, had it been done right.

=head1 COPYRIGHT

This module is Copyright (c) 2003 Brad Fitzpatrick.
All rights reserved.

You may distribute under the terms of either the GNU General Public
License or the Artistic License, as specified in the Perl README file.

=head1 WARRANTY

This is free software. IT COMES WITHOUT WARRANTY OF ANY KIND.

=head1 FAQ

See the memcached website:
   http://www.danga.com/memcached/

=head1 AUTHORS

Brad Fitzpatrick <brad@danga.com>

Anatoly Vorobey <mellon@pobox.com>

Brad Whitaker <whitaker@danga.com>

Jamie McCarthy <jamie@mccarthy.vg>

=end pod

# vim: ft=perl6 sw=4 ts=4 st=4 sts=4 et
