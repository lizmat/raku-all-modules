#!/usr/bin/perl6

use v6;

use Test;
use Test::Path::Router;
use IO::String;
use Path::Router;

my $router  = Path::Router.new;

# Do the things that Test::Builder would do in Perl manually since the
# equivalent tools in Perl6 aren't quite there yet.

sub init-io {
    my $output = IO::String.new;
    my $error  = IO::String.new;
 
    Test::output()         = $output;
    Test::failure_output() = $error;
    Test::todo_output()    = $output;

    return ($output, $error);
}

$router.add-route('blog' => (
    defaults => { controller => 'Blog' }
));

$router.add-route('feed' => (
    defaults => { controller => 'Feed' }
));

my %tests = (
    mapping-not-ok => {
        pass => {
            desc => 'mapping-not-ok passes when mapping not found',
            args => [{controller => 'Wiki'}],
        },
        fail => {
            desc => 'mapping-not-ok fails when mapping found',
            args => [{controller => 'Blog'}],
        },
        coderef => &mapping-not-ok,
    },
    mapping-ok => {
        pass => {
            desc => 'mapping-ok passes when mapping found',
            args => [{controller => 'Blog'}],
        },
        fail => {
            desc => 'mapping-ok fails when mapping not found',
            args => [{controller => 'Wiki'}],
        },
        coderef => &mapping-ok,
    },
   mapping-is => {
        pass => {
            desc => 'mapping-is passes when mapping matches path',
            args => [{controller => 'Blog'}, 'blog'],
        },
        fail => {
            desc => 'mapping-is fails when mapping does not match path',
            args => [{controller => 'Wiki'}, 'blog'],
        },
        coderef => &mapping-is,
    },
    path-not-ok => {
        pass => {
            desc => 'path-not-ok passes when path not found',
            args => ['wiki'],
        },
        fail => {
            desc => 'path-not-ok fails when path found',
            args => ['blog'],
        },
        coderef => &path-not-ok,
    },
    path-ok => {
        pass => {
            desc => 'path-ok passes when path found',
            args => ['blog'],
        },
        fail => {
            desc => 'path-ok fails when path not found',
            args => ['wiki'],
        },
        coderef => &path-ok,
    },
    path-is => {
        pass => {
            desc => 'path-is passes when path matches mapping',
            args => ['blog', {controller => 'Blog'}],
        },
        fail => {
            desc => 'path-is fails when path does not match mapping',
            args => ['blog', {controller => 'Wiki'}],
        },
        coderef => &path-is,
    },
    routes-ok => {
        pass => {
            desc => 'routes-ok passes when all paths and mappings match',
            args => [{
                blog => {controller => 'Blog'},
                feed => {controller => 'Feed'},
            }],
        },
        fail => {
            desc => 'routes-ok fails when all paths and mappings do not match',
            args => [{
                blog => {controller => 'Blog'},
                feed => {controller => 'Wiki'},
            }],
        },
        coderef => &routes-ok,
    },
);

my $i = 0;
for %tests.keys.sort -> $function {

    my &coderef = %tests{$function}<coderef>;

    for <pass fail> -> $state {
        
        my ($output, $error) = init-io;

        my @arguments   = @(%tests{$function}{$state}<args>);
        my $description = %tests{$function}{$state}<desc>;

        # This is a trick to prevent Test.pm from blowing up the exit status
        # which isn't yet easy to control.
        todo 'Test.pm blows up the exit code unless this is a TODO', 1
            if $state eq 'fail';

        coderef($router, |@arguments, $description);

        $i++;
        my $expect = $state eq 'pass' ?? "ok" !! "not ok";
        $expect ~= " " ~ $i;

        if ~$output ~~ /^^$expect/ {
            say "ok $i - $description";
        }
        else {
            say "not ok $i - $description";
            note "# Got test like:      $output";
            note "# Expected test like: $expect";
            note ~$error if ~$error;
        }
    }
}

say "1..$i";
