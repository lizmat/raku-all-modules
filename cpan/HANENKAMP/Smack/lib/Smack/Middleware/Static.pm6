use v6;

use Smack::Middleware;

unit class Smack::Middleware::Static is Smack::Middleware;

use Smack::App::File;

has $.path;
has &.condition;
has IO::Path $.root = '.'.IO;
has Str $.encoding;
has Bool $.pass-through;
has $.content-type;

has $!_file;
method file(--> Smack::App::File) {
    $!_file //= Smack::App::File.new(:$!root, :$!encoding, :$!content-type);
}

method call(%env) {
    my &next = nextcallee;
    start {
        my $res = self!handle-static(%env);
        if $res && !($.pass-through && $res[0] == 404) {
            $res;
        }
        else {
            await self.&next(%env);
        }
    }
}

method !handle-static(%env) {
    # If no path or condition, this middleware is a no-op
    return without $.path | &.condition;

    # Allow the condition to modify %env, but only here
    temp %env;

    # Nothing to do unless either the path or condition match
    with $.path {
        return unless %env<PATH_INFO> ~~ $.path;
    }
    with &.condition {
        return unless .(%env);
    }

    # We want a static file, so let's get the static file
    await $.file.call(%env);
}
