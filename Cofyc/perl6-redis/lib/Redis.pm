use v6;

=begin pod

=TITLE Redis

    A Perl6 binding for Redis.

=head1 Synopsis

    my $redis = Redis.new("127.0.0.1:6379");
    $redis.set("key", "value");
    say $redis.get("key");
    say $redis.info();
    $redis.quit();

=head1 Methods

=head2 new

    method new(Str $server?, Str :$encoding?, Bool :$decode_response?)

Returns the redis object.

=head2 exec_command

    method exec_command(Str $command, *@args) returns Any

Executes arbitrary command.
    
=end pod

unit class Redis;

has Str $.host = '127.0.0.1';
has Int $.port = 6379;
has Str $.sock; # if sock is defined, use sock
has Str $.encoding = "UTF-8"; # Use this encoding to decode Str
# If True, decode Buf response into Str, except following methods:
#   dump
# which, must return Buf
has Bool $.decode_response = False;
has $.conn is rw;

# Predefined callbacks
my &status_code_reply_cb = { $_ eq "OK" };
my &integer_reply_cb = { $_.Bool };
my &buf_to_float_cb = { $_.decode("ASCII").Real };

my %command_callbacks = Hash.new;
%command_callbacks{"PING"} = { $_ eq "PONG" };
for "CLIENT KILL,BGSAVE,BGREWRITEAOF,AUTH,QUIT,SET,MSET,PSETEX,SETEX,MIGRATE,RENAME,RENAMENX,RESTORE,HMSET,SELECT,LSET,LTRIM,FLUSHALL,FLUSHDB,DISCARD,MULTI,WATCH,UNWATCH,SCRIPT FLUSH,SCRIPT KILL".split(",") -> $c {
    %command_callbacks{$c} = &status_code_reply_cb;
}
for "EXISTS SETNX EXPIRE EXPIREAT MOVE PERSIST PEXPIRE PEXPIREAT HSET HEXISTS HSETNX SISMEMBER SMOVE".split(" ") -> $c {
    %command_callbacks{$c} = &integer_reply_cb;
}
for "INCRBYFLOAT HINCRBYFLOAT ZINCRBY ZSCORE".split(" ") -> $c {
    %command_callbacks{$c} = &buf_to_float_cb;
}
# TODO so ugly...
# @see hash key is Str in ISO-8859-1 encoding
%command_callbacks{"HGETALL"} = sub (@list) returns Hash {
    my %h = Hash.new;
    for @list.pairs -> $p {
        if $p.key % 2 eq 0 {
            %h{$p.value.decode("ISO-8859-1")} = @list[$p.key + 1];
        }
    }
    return %h;
};
%command_callbacks{"INFO"} = sub ($info) {
    my @lines = $info.decode.split("\r\n");
    my %info;
    for @lines -> $l {
        if $l.substr(0, 1) eq "#" {
            next;
        }
        my ($key, $value) = $l.split(":");
        %info{$key} = $value;
    }
    return %info;
};

has %!command_callbacks = %command_callbacks;

method new(Str $server?, Str :$encoding?, Bool :$decode_response?) {
    my %config := {}
    if $server.defined {
        if $server ~~ m/^([\d+]+ %\.) [':' (\d+)]?$/ {
            %config<host> = $0.Str;
            if $1 {
                %config<port> = $1.Str.Int;
            }
        } else {
            %config<sock> = $server;
        }
    }
    if $encoding.defined {
        %config<encoding> = $encoding;
    }
    if $decode_response.defined {
        %config<decode_response> = $decode_response;
    }
    my $obj = self.bless(*, |%config);
    $obj.reconnect;
    return $obj;
}

method reconnect {
    if $.sock.defined {
        die "Sorry, connecting via unix sock is currently unsupported!";
    } else {
        $.conn = IO::Socket::INET.new(host => $.host, port => $.port, input-line-separator => "\r\n");
    }
}

multi method encode(Str:D $value) returns Buf {
    return Buf.new($value.encode(self.encoding));
}

multi method encode(Buf:D $value) returns Buf {
    return $value;
}

# convert to Str, then to Buf
multi method encode($value) returns Buf {
    return self.encode($value.Str);
}

method !pack_command(*@args) returns Buf {
    my $cmd = self.encode('*' ~ @args.elems ~ "\r\n");
    for @args -> $arg {
        my $new = self.encode($arg);
        $cmd ~= '$'.encode;
        $cmd ~= self.encode($new.bytes);
        $cmd ~= "\r\n".encode;
        $cmd ~= $new;
        $cmd ~= "\r\n".encode;
    }
    return $cmd;
}

method exec_command(Str $command, *@args) returns Any {
    @args.unshift($command.split(" "));
    $.conn.write(self!pack_command(|@args));
    return self!parse_response(self!read_response(), $command);
}

# Returns Str/Int/Buf/Array
method !read_response returns Any {
    my $first-line = $.conn.get;
    my ($flag, $response) = $first-line.substr(0, 1), $first-line.substr(1);
    if $flag !eq any('+', '-', ':', '$', '*') {
        die "Unknown response from redis!\n";
    }
    if $flag eq '+' {
        # single line reply, pass
    } elsif $flag eq '-' {
        # on error, throw exception
        die $response;
    } elsif $flag eq ':' {
        # int value
        $response = $response.Int;
    } elsif $flag eq '$' {
        # bulk response
        my $length = $response.Int;
        if $length eq -1 {
            return Nil;
        }
        $response = $.conn.read($length + 2).subbuf(0, $length);
        if $response.bytes !eq $length {
            die "Invalid response.";
        }
    } elsif $flag eq '*' {
        # multi-bulk response
        my $length = $response.Int;
        if $length eq -1 {
            return Nil;
        }
        $response = [];
        for 1..$length {
            $response.push(self!read_response());
        }
    }
    return $response;
}

method !decode_response($response) {
    if $response.WHAT === Buf[uint8] {
        return $response.decode(self.encoding);
    } elsif $response.WHAT === Array {
        return $response.map( { self!decode_response($_) } ).Array;
    } elsif $response.WHAT === Hash {
        my %h = Hash.new;
        for $response.pairs {
            %h{.key} = self!decode_response(.value);
        }
        return %h;
    } else {
        return $response;
    }
}

method !parse_response($response is copy, Str $command) {
    if %!command_callbacks{$command}:exists {
        $response =  %!command_callbacks{$command}($response);
    }
    if self.decode_response and $command !eq any("DUMP") {
        $response = self!decode_response($response);
    }
    return $response;
}

####### Commands/Connection #######

method auth(Str $password) returns Bool {
    return self.exec_command("AUTH", $password);
}

method echo($message) returns Str {
    return self.exec_command("ECHO", $message);
}

# Ping the server.
method ping returns Bool {
    return self.exec_command("PING");
}

# Ask the server to close the connection. The connection is closed as soon as all pending replies have been written to the client.
method quit returns Bool {
    return self.exec_command("QUIT");
}

method select(Int $index) returns Bool {
    return self.exec_command("SELECT", $index);
}

####### ! Commands/Connection #######

####### Commands/Server #######

method bgrewriteaof() returns Bool {
    return self.exec_command("BGREWRITEAOF");
}

method bgsave() returns Bool {
    return self.exec_command("BGSAVE");
}

method client_kill(Str $ip, Int $port) returns Bool {
    return self.exec_command("CLIENT KILL", $ip, $port);
}

method flushall() returns Bool {
    return self.exec_command("FLUSHALL");
}

method flushdb() returns Bool {
    return self.exec_command("FLUSHDB");
}

method info() returns Hash {
    return self.exec_command("INFO");
}

####### ! Commands/Server #######

###### Commands/Keys #######

method del(*@keys) returns Int {
    return self.exec_command("DEL", |@keys);
}

method dump(Str $key) returns Buf {
    return self.exec_command("DUMP", $key);
}

method exists(Str $key) returns Bool {
    return self.exec_command("EXISTS", $key);
}

method expire(Str $key, Int $seconds) returns Bool {
    return self.exec_command("EXPIRE", $key, $seconds);
}

method expireat(Str $key, Int $timestamp) returns Bool {
    return self.exec_command("EXPIREAT", $key, $timestamp);
}

method ttl(Str $key) returns Int {
    return self.exec_command("TTL", $key);
}

method keys(Str $pattern) returns List {
    return self.exec_command("KEYS", $pattern);
}

method migrate(Str $host, Int $port, Str $key, Str $destination-db, Int $timeout) returns Bool {
    return self.exec_command("MIGRATE", $host, $port, $key, $destination-db, $timeout);
}

method move(Str $key, Str $db) returns Bool {
    return self.exec_command("MOVE", $key, $db);
}

method object(Str $subcommand, *@arguments) {
    return self.exec_command("OBJECT", $subcommand, |@arguments);
}

method persist(Str $key) returns Bool {
    return self.exec_command("PERSIST", $key);
}

method pexpire(Str $key, Int $milliseconds) returns Bool {
    return self.exec_command("PEXPIRE", $key, $milliseconds);
}

method pexpireat(Str $key, Int $milliseconds-timestamp) returns Bool {
    return self.exec_command("PEXPIREAT", $key, $milliseconds-timestamp);
}

method pttl(Str $key) returns Int {
    return self.exec_command("TTL", $key);
}

method randomkey() {
    return self.exec_command("RANDOMKEY");
}

method rename(Str $key, Str $newkey) returns Bool {
    return self.exec_command("RENAME", $key, $newkey);
}

method renamenx(Str $key, Str $newkey) returns Bool {
    return self.exec_command("RENAMENX", $key, $newkey);
}

method restore(Str $key, Int $milliseconds, Buf $serialized-value) returns Bool {
    return self.exec_command("RESTORE", $key, $milliseconds, $serialized-value);
}

method sort(Str $key, Str :$by?,
        Int :$offset?, Int :$count?,
        :@get?,
        Bool :$desc = False,
        Bool :$alpha = False,
        Str :$store?
    ) returns List {
    if ($offset.defined and !$count.defined) or (!$offset.defined and $count.defined) {
        die "`offset` and `count` must both be specified.";
    }
    say $desc;
    # TODO
    return []
}

# Returns the string representation of the type of the value stored at key. The
# different types that can be returned are: none, string, list, set, zset and hash.
method type(Str $key) {
    return self.exec_command("TYPE", $key);
}

###### ! Commands/Keys #######

###### Commands/Strings ######

method append(Str $key, $value) returns Int {
    return self.exec_command("APPEND", $key, $value);
}

method bitcount(Str $key, Int $start?, Int $end?) returns Int {
    my @args = [$key];
    if $start.defined and $end.defined {
        @args.push($start);
        @args.push($end);
    } elsif $start.defined or $end.defined {
        die "Both start and end must be specified.";
    }
    return self.exec_command("BITCOUNT", |@args);
}

method bitop(Str $op, Str $key, *@keys) {
    return self.exec_command("BITOP", $op, $key, |@keys);
}

method get(Str $key) {
    return self.exec_command("GET", $key);
}

method set(Str $key, $value) returns Bool {
    return self.exec_command("SET", $key, $value);
}

method setbit(Str $key, Int $offset, $value) returns Int {
    return self.exec_command("SETBIT", $key, $offset, $value);
}

method setex(Str $key, Int $seconds, $value) {
    return self.exec_command("SETEX", $key, $seconds, $value);
}

method setnx(Str $key, $value) returns Bool {
    return self.exec_command("SETNX", $key, $value);
}

method setrange(Str $key, Int $offset, $value) returns Int {
    return self.exec_command("SETRANGE", $key, $offset, $value);
}

method strlen(Str $key) returns Int {
    return self.exec_command("STRLEN", $key);
}

method getbit(Str $key, Int $offset) returns Int {
    return self.exec_command("GETBIT", $key, $offset);
}

method getrange(Str $key, Int $start, Int $end) returns Str {
    return self.exec_command("GETRANGE", $key, $start, $end);
}

method getset(Str $key, $value) {
    return self.exec_command("GETSET", $key, $value);
}

method incrbyfloat(Str $key, Real $increment) returns Real {
    return self.exec_command("INCRBYFLOAT", $key, $increment);
}

method mget(*@keys) {
    return self.exec_command("MGET", |@keys);
}

# Sets the given keys to their respective values.
# Arguments can be named or positional parameters.
method mset(*@args, *%named) {
    for %named {
        @args.push(.key);
        @args.push(.value);
    }
    return self.exec_command("MSET", |@args);
}

method msetnx(*@args, *%named) {
    for %named {
        @args.push(.key);
        @args.push(.value);
    }
    return self.exec_command("MSETNX", |@args);
}

method psetex(Str $key, Int $milliseconds, $value) {
    return self.exec_command("PSETEX", $key, $milliseconds, $value);
}

method incr(Str $key) {
    return self.exec_command("INCR", $key);
}

method incrby(Str $key, Int $increment) {
    return self.exec_command("INCRBY", $key, $increment);
}

method decr(Str $key) {
    return self.exec_command("DECR", $key);
}

method decrby(Str $key, Int $increment) {
    return self.exec_command("DECRBY", $key, $increment);
}

###### ! Commands/Strings ######

###### Commands/Hashes ######

method hdel(Str $key, *@fields) returns Int {
    return self.exec_command("HDEL", $key, |@fields);
}

method hexists(Str $key, $field) returns Bool {
    return self.exec_command("HEXISTS", $key, $field);
}

method hget(Str $key, $field) returns Any {
    return self.exec_command("HGET", $key, $field);
}

method hgetall(Str $key) returns Hash {
    return self.exec_command("HGETALL", $key);
}

method hincrby(Str $key, $field, Int $increment) returns Int {
    return self.exec_command("HINCRBY", $key, $field, $increment);
}

method hincrbyfloat(Str $key, $field, Real $increment) returns Real {
    return self.exec_command("HINCRBYFLOAT", $key, $field, $increment);
}

method hkeys(Str $key) returns List {
    return self.exec_command("HKEYS", $key);
}

method hlen(Str $key) returns Int {
    return self.exec_command("HLEN", $key);
}

method hmget(Str $key, *@fields) returns List {
    return self.exec_command("HMGET", $key, |@fields);
}

method hmset(Str $key, *@args, *%named) returns Bool {
    for %named {
        @args.push(.key);
        @args.push(.value);
    }
    return self.exec_command("HMSET", $key, |@args);
}

method hset(Str $key, $field, $value) returns Bool {
    return self.exec_command("HSET", $key, $field, $value);
}

method hsetnx(Str $key, $field, $value) returns Bool {
    return self.exec_command("HSETNX", $key, $field, $value);
}

method hvals(Str $key) returns List {
    return self.exec_command("HVALS", $key);
}

###### ! Commands/Hashes ######

###### Commands/Lists ######

method blpop(Int $timeout, *@keys) returns Any {
    return self.exec_command("BLPOP", |@keys, $timeout);
}

method brpop(Int $timeout, *@keys) returns Any {
    return self.exec_command("BRPOP", |@keys, $timeout);
}

method brpoplpush(Str $source, Str $destination, Int $timeout) returns Any {
    return self.exec_command("BRPOPLPUSH", $source, $destination, $timeout);
}

# Returns the element at index in the list, or nil when index is out of range.
method lindex(Str $key, Int $index) returns Any {
    return self.exec_command("LINDEX", $key, $index);
}

method linsert(Str $key, Str $where where { $where eq any("BEFORE", "AFTER") }, $pivot, $value) returns Int {
    return self.exec_command("LINSERT", $key, $where, $pivot, $value);
}

method llen(Str $key) returns Int {
    return self.exec_command("LLEN", $key);
}

method lpop(Str $key) returns Any {
    return self.exec_command("LPOP", $key);
}

method lpush(Str $key, *@values) returns Int {
    return self.exec_command("LPUSH", $key, |@values);
}

method lpushx(Str $key, $value) returns Int {
    return self.exec_command("LPUSHX", $key, $value);
}

method lrange(Str $key, Int $start, Int $stop) returns List {
    return self.exec_command("LRANGE", $key, $start, $stop);
}

method lrem(Str $key, Int $count, $value) returns Int {
    return self.exec_command("LREM", $key, $count, $value);
}

method lset(Str $key, Int $index, $value) {
    return self.exec_command("LSET", $key, $index, $value);
}

method ltrim(Str $key, Int $start, Int $stop) {
    return self.exec_command("LTRIM", $key, $start, $stop);
}

method rpop(Str $key) returns Any {
    return self.exec_command("RPOP", $key);
}

method rpoplpush(Str $source, Str $destination) returns Str {
    return self.exec_command("RPOPLPUSH", $source, $destination);
}

method rpush(Str $key, *@values) returns Int {
    return self.exec_command("RPUSH", $key, |@values);
}

method rpushx(Str $key, $value) {
    return self.exec_command("RPUSHX", $key, $value);
}

###### ! Commands/Lists ######

###### Commands/Sets #######

method sadd(Str $key, *@members) returns Int {
    return self.exec_command("SADD", $key, |@members);
}

method scard(Str $key) returns Int {
    return self.exec_command("SCARD", $key);
}

method sdiff(*@keys) returns List {
    return self.exec_command("SDIFF", |@keys);
}

method sdiffstore(Str $destination, *@keys) returns Int {
    return self.exec_command("SDIFFSTORE", $destination, |@keys);
}

method sinter(*@keys) returns List {
    return self.exec_command("SINTER", |@keys);
}

method sinterstore(Str $destination, *@keys) returns Int {
    return self.exec_command("SINTERSTORE", $destination, |@keys);
}

method sismember(Str $key, $member) {
    return self.exec_command("SISMEMBER", $key, $member);
}

method smembers(Str $key) returns List {
    return self.exec_command("SMEMBERS", $key);
}

method smove(Str $source, Str $destination, $member) returns Bool {
    return self.exec_command("SMOVE", $source, $destination, $member);
}

method spop(Str $key) returns Any {
    return self.exec_command("SPOP", $key);
}

method srandmember(Str $key) returns Any {
    return self.exec_command("SRANDMEMBER", $key);
}

method srem(Str $key, *@members) returns Int {
    return self.exec_command("SREM", |@members);
}

method sunion(*@keys) returns List {
    return self.exec_command("SUNION", |@keys);
}

method sunionstore(Str $destination, *@keys) returns Int {
    return self.exec_command("SUNIONSTORE", $destination, |@keys);
}

###### ! Commands/Sets #######

###### Commands/SortedSets #######

method zadd(Str $key, *@args, *%named) returns Int {
    my @newargs = Array.new;
    @args = @args.reverse;
    for @args {
        if $_.WHAT === Pair {
            @newargs.push(.value);
            @newargs.push(.key);
        } else {
            @newargs.push($_);
        }
    }
    for %named {
        @newargs.push(.value);
        @newargs.push(.key);
    }
    if @newargs.elems % 2 != 0 {
        die "ZADD requires an equal number of values and scores";
    }
    return self.exec_command("ZADD", $key, |@newargs);
}

method zcard(Str $key) returns Int {
    return self.exec_command("ZCARD", $key);
}

# TODO support (1, -inf, +inf syntax, http://redis.io/commands/zcount
method zcount(Str $key, Real $min, Real $max) returns Int {
    return self.exec_command("ZCOUNT", $key, $min, $max);
}

method zincrby(Str $key, Real $increment, $member) returns Real {
    return self.exec_command("ZINCRBY", $key, $increment, $member);
}

method zinterstore(Str $destination, *@keys, :WEIGHTS(@weights)?, :AGGREGATE(@aggregate)?) returns Int {
    my @args = Array.new;
    if @weights.elems > 0 {
        @args.push("WEIGHTS");
        for @weights {
            @args.push($_);
        }
    }
    if @aggregate.elems > 0 {
        @args.push("AGGREGATE");
        for @aggregate {
            @args.push($_);
        }
    }
    return self.exec_command("ZINTERSTORE", $destination, @keys.elems, |@keys, |@args);
}

# TODO return array of paires if WITHSCORES is set
method zrange(Str $key, Int $start, Int $stop, :WITHSCORES($withscores)?) {
    return self.exec_command("ZRANGE", $key, $start, $stop, $withscores.defined ?? "WITHSCORES" !! Nil);
}

# TODO return array of paires if WITHSCORES is set
method zrangebyscore(Str $key, Real $min, Real $max, :WITHSCORES($withscores), Int :OFFSET($offset)?, Int :COUNT($count)?) returns List {
    if ($offset.defined and !$count.defined) or (!$offset.defined and $count.defined) {
        die "`offset` and `count` must both be specified.";
    }
    return self.exec_command("ZRANGEBYSCORE", $key, $min, $max,
        $withscores.defined ?? "WITHSCORES" !! Nil,
        ($offset.defined and $count.defined) ?? "LIMIT" !! Nil,
        $offset.defined ?? $offset !! Nil,
        $count.defined ?? $count !! Nil
    );
}

method zrank(Str $key, $member) returns Any {
    return self.exec_command("ZRANK", $key, $member);
}

method zrem(Str $key, *@members) returns Int {
    return self.exec_command("ZREM", $key, |@members);
}

method zremrangbyrank(Str $key, Int $start, Int $stop) returns Int {
    return self.exec_command("ZREMRANGEBYRANK", $key, $start, $stop);
}

method zremrangebyscore(Str $key, Real $min, Real $max) returns Int {
    return self.exec_command("ZREMRANGEBYSCORE", $key, $min, $max);
}

# TODO return array of paires if WITHSCORES is set
method zrevrange(Str $key, $start, $stop, :WITHSCORES($withscores)?) {
    return self.exec_command("ZREVRANGE", $key, $start, $stop, $withscores.defined ?? "WITHSCORES" !! Nil);
}

# TODO return array of paires if WITHSCORES is set
method zrevrangebyscore(Str $key, Real $min, Real $max, :WITHSCORES($withscores), Int :OFFSET($offset)?, Int :COUNT($count)?) returns List {
    if ($offset.defined and !$count.defined) or (!$offset.defined and $count.defined) {
        die "`offset` and `count` must both be specified.";
    }
    return self.exec_command("ZREVRANGEBYSCORE", $key, $min, $max,
        $withscores.defined ?? "WITHSCORES" !! Nil,
        ($offset.defined and $count.defined) ?? "LIMIT" !! Nil,
        $offset.defined ?? $offset !! Nil,
        $count.defined ?? $count !! Nil
    );
}

method zrevrank(Str $key, $member) returns Any {
    return self.exec_command("ZREVRANK", $key, $member);
}

method zscore(Str $key, $member) returns Real {
    return self.exec_command("ZSCORE", $key, $member);
}

method zunionstore(Str $destination, *@keys, :WEIGHTS(@weights)?, :AGGREGATE(@aggregate)?) returns Int {
    my @args = Array.new;
    if @weights.elems > 0 {
        @args.push("WEIGHTS");
        for @weights {
            @args.push($_);
        }
    }
    if @aggregate.elems > 0 {
        @args.push("AGGREGATE");
        for @aggregate {
            @args.push($_);
        }
    }
    return self.exec_command("ZUNIONSTORE", $destination, @keys.elems, |@keys, |@args);
}

###### ! Commands/SortedSets #######

###### Commands/Pub&Sub #######

method psubscribe(*@patterns) {
    return self.exec_command("PSUBSCRIBE", |@patterns);
}

method publish(Str $channel, $message) {
    return self.exec_command("PUBLISH", $channel, $message);
}

method punsubscribe(*@patterns) {
    return self.exec_command("PUNSUBSCRIBE", |@patterns);
}

method subscribe(*@channels) {
    return self.exec_command("SUBSCRIBE", |@channels);
}

method unsubscribe(*@channels) {
    return self.exec_command("UNSUBSCRIBE", |@channels);
}

###### ! Commands/Pub&Sub #######

###### Commands/Transactions #######

method discard() returns Bool {
    return self.exec_command("DISCARD");
}

# TODO format response according each command
method exec() returns List {
    return self.exec_command("EXEC");
}

method multi() returns Bool {
    return self.exec_command("MULTI");
}

method unwatch() returns Bool {
    return self.exec_command("UNWATCH");
}

method watch(*@keys) returns Bool {
    return self.exec_command("WATCH");
}

###### ! Commands/Transactions #######

###### Commands/Scripting #######

method eval(Str $script, Int $numkeys, *@keys_and_args) returns Any {
    return self.exec_command("EVAL", $script, $numkeys, |@keys_and_args);
}

method evalsha(Str $sha1, Int $numkeys, *@keys_and_args) returns Any {
    return self.exec_command("EVALSHA", $sha1, $numkeys, |@keys_and_args);
}

method script_exists(*@scripts) returns List {
    return self.exec_command("SCRIPT EXISTS", |@scripts);
}

method script_flush() returns Bool {
    return self.exec_command("SCRIPT FLUSH");
}

method script_kill() returns Bool {
    return self.exec_command("SCRIPT KILL");
}

method script_load(Str $script) returns Any {
    return self.exec_command("SCRIPT LOAD", $script);
}

###### ! Commands/Scripting #######

# vim: ft=perl6
