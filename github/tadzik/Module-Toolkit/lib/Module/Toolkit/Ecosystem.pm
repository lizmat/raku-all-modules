unit class Module::Toolkit::Ecosystem;
use Module::Toolkit::Distribution;
use JSON::Fast;

has $.projects-json;
has %!projects;

method project-list {
    self.init-projects();
    return %!projects.values;
}

method add-project(Distribution $dist) {
    %!projects{$dist.Str} = $dist
}

method init-projects { once {
    my $contents = self.fetch-projects;
    my $list = try from-json $contents;
    if $! {
        die "Cannot parse the projects database as JSON: $!";
    }
    unless defined $list {
        die "An unknown error occured while reading the projects file";
    }
    for $list.list -> $dist {
        my @dep  = |($dist<depends>:delete);
        my @bdep = |($dist<build-depends>:delete);
        my @tdep = |($dist<test-depends>:delete);
        self.add-project: Module::Toolkit::Distribution.new(
            |$dist, 
            depends       => @dep,
            build-depends => @bdep,
            test-depends  => @tdep,
        );
    }
}}

method fetch-projects {
    my $url = 'http://ecosystem-api.p6c.org/projects.json';
    my $s;
    my $has-http-ua = try require HTTP::UserAgent;
    if $has-http-ua {
        my $ua = ::('HTTP::UserAgent').new;
        my $response = $ua.get($.projects-json-url);
        return $response.decoded-content;
    } else {
        # Makeshift HTTP::Tiny
        $s = IO::Socket::INET.new(:host<ecosystem-api.p6c.org>, :port(80));
        $s.print("GET /projects.json HTTP/1.0\r\nHost: ecosystem-api.p6c.org\r\n\r\n");
        my ($buf, $g) = '';

        my $http-header = $s.get;

        if $http-header !~~ /'HTTP/1.'<[01]>' 200 OK'/ {
            die "can't download projects file: $http-header";
        }

        # for the time being we're going to throw this away
        my Str $head-stuff;

        while $g = $s.get {
           $head-stuff ~= $g;
        }


        # unconditionally get the gap
        $buf ~= $s.get;

        # get all the lines remaining
        while $g = $s.get {
           $buf ~= $g;
        }

        die "Got an empty metadata file." unless $buf.chars;
        return $buf;
    }

    #TODO: Fix so it doesn't have to use a file
    #CATCH {
    #    default {
    #        note "Could not download module metadata: {$_.message}.";
    #        note "Falling back to the curl command.";
    #        run 'curl', $url, '-#', '-o', $!projectsfile;
    #        die "Got an empty metadata file." unless $!projectsfile.IO.s;
    #        CATCH {
    #            default {
    #                note "curl failed: {$_.message}.";
    #                note "Falling back to the wget command.";
    #                run 'wget', '-nv', '--unlink', $url, '-O', $!projectsfile;
    #                die "Got an empty metadata file." unless $!projectsfile.IO.s;
    #                CATCH {
    #                    default {
    #                        die "wget failed as well: {$_.message}. Sorry, have to give up."
    #                    }
    #                }
    #            }
    #        }
    #    }
    #}
}

method get-project(Str() $p) {
    self.init-projects();
    my @cands;
    for self.project-list {
        if .name eq $p {
            @cands.push: $_
        }
    }
    if +@cands {
        return @cands.sort(*.version).reverse[0];
    }
    for self.project-list -> $cand {
        if $cand.provides.keys.grep($p) {
            return $cand;
        }
    }
}

sub topo-sort(@modules, %dependencies) is export {
    my @order;
    my %color_of = flat @modules X=> 'not yet visited';
    sub dfs-visit($module) {
        %color_of{$module} = 'visited';
        for %dependencies{$module}.list -> $used {
            if (%color_of{$used} // '') eq 'not yet visited' {
                dfs-visit($used);
            }
        }
        push @order, $module;
    }

    for @modules -> $module {
        if %color_of{$module} eq 'not yet visited' {
            dfs-visit($module);
        }
    }
    @order;
}

method get-dependencies(Module::Toolkit::Distribution $dist) {
    self.init-projects();
    my @queue = $dist;
    my @modules;
    my %dependencies{Distribution};
    my %seen;
    while @queue {
        my $d = @queue.shift;
        unless %seen{$d}++ {
            my @dep = |$d.depends, |$d.build-depends, |$d.test-depends;
            @dep.=grep({ $_ and $_ ~~ none(<nqp Test Pod::To::Text>) });
            @dep.map({
                my $d = self.get-project($_)
                    or die "Module '$_' not found in the ecosystem";
                $_ = $d;
            });
            @queue.append: @dep;
            @modules.push: $d;
            %dependencies{$d} = @dep;
        }
    }
    my @ordered = topo-sort @modules, %dependencies;
    @ordered.pop; # remove the original target; we want just its deps
    @ordered;
}

# vim: ft=perl6
