use v6;
use Test;
use DB::Rscs;

our $addr;
our $rscs-program;
our $proc;

BEGIN {
    $addr = 'http://localhost:9999';
    unless %*ENV{'TRAVIS'}.defined && %*ENV{'CI'}.defined {
        say 'This library depends on a Go program:';
        say 'https://github.com/bradclawsie/rscs';
        say 'These tests are intended to be run primarily on Travis:';
        say 'https://travis-ci.org/bradclawsie/DB-Rscs';
        done-testing;
        exit(0);
    }
    say 'pre-test tasks';
    die "no GOPATH set" unless %*ENV{'GOPATH'}.defined && %*ENV{'GOPATH'}.IO.d;
    $rscs-program = %*ENV{'GOPATH'} ~ '/bin/rscs';
    die "cannot execute $rscs-program" unless $rscs-program.IO.x;

    $proc = Proc::Async.new($rscs-program, '--memory','--port=9999');
    $proc.stdout.tap(-> $v { print "Stdout: $v" }, quit => { say 'caught exception ' ~ .^name });
    $proc.stderr.tap(-> $v { print "Stderr: $v" });
    my $promise = $proc.start;
    sleep 1;
}

END {
    say 'post-test tasks';
    $proc.kill("SIGINT");
}

subtest {
    lives-ok {
        my $rscs = DB::Rscs.new(addr=>$addr);
    }, 'basic';
    dies-ok {
        my $rscs = DB::Rscs.new('junk');
    }, 'bad addr'
}, 'construct';

subtest {
    lives-ok {
        my $rscs = DB::Rscs.new(addr=>$addr);
        my %status = $rscs.status;
        is (%status<Alive>:exists), True, 'Alive';
        is (%status<DBFile>:exists), True, 'DBFile';
        is (%status<Uptime>:exists), True, 'Uptime';
    }, 'status';
}, 'status';

subtest {
    lives-ok {
        my $rscs = DB::Rscs.new(addr=>$addr);
        my $v-in = 'val1';
        $rscs.insert('key1',$v-in);
        my %v-out-struct = $rscs.get('key1');
        is (%v-out-struct{$VALUE_KEY}:exists), True, 'output value';
        is (%v-out-struct{$VALUE_KEY} eq $v-in), True, 'round trip';
    }, 'insert';

    dies-ok {
        my $rscs = DB::Rscs.new(addr=>$addr);
        $rscs.insert('','val1');
    }, 'insert no key';
}, 'insert';

subtest {
    lives-ok {
        my $rscs = DB::Rscs.new(addr=>$addr);
        my $v-in = 'val2';
        my $key = 'key2';
        $rscs.insert($key,$v-in);
        my %v-out-struct = $rscs.get($key);
        is (%v-out-struct{$VALUE_KEY}:exists), True, 'output value';
        is (%v-out-struct{$VALUE_KEY} eq $v-in), True, 'round trip';
        my $v-up = 'new-val1';
        $rscs.update($key,$v-up);
        my %v-up-struct = $rscs.get($key);
        is (%v-up-struct{$VALUE_KEY}:exists), True, 'output value';
        is (%v-up-struct{$VALUE_KEY} eq $v-up), True, 'round trip';
    }, 'update';

    dies-ok {
        my $rscs = DB::Rscs.new(addr=>$addr);
        $rscs.update('','val1');
    }, 'update no key';
}, 'update';


subtest {

    my $key = 'key3';
    
    lives-ok {
        my $rscs = DB::Rscs.new(addr=>$addr);
        my $v-in = 'val3';
        $rscs.insert($key,$v-in);
        my %v-out-struct = $rscs.get($key);
        is (%v-out-struct{$VALUE_KEY}:exists), True, 'output value';
        is (%v-out-struct{$VALUE_KEY} eq $v-in), True, 'round trip';
        my $v-up = 'new-val1';
        $rscs.delete($key);
    }, 'delete';

    dies-ok { # Get on deleted key throws exception.
        my $rscs = DB::Rscs.new(addr=>$addr);
        my %v-deleted-struct = $rscs.get($key);
    }, 'get deleted';
    
    dies-ok {
        my $rscs = DB::Rscs.new(addr=>$addr);
        $rscs.update('');
    }, 'delete no key';
}, 'delete';

done-testing;
