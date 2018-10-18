use Distribution::Common::Remote::Github;

class CompUnit::Repository::Github does CompUnit::Repository {

    # Lookup / Caching stuff
    has %!loaded; # cache compunit lookup for self.need(...)
    has %!seen;   # cache distribution lookup for self!matching-dist(...)
    has $!name;
    has %!resources;

    # Github stuff
    has $.user;
    has $.repo;
    has $.branch;

    has @!dists;
    my $dists-lock = Lock.new;

    submethod TWEAK(:$!name = 'github-api') {
        CompUnit::RepositoryRegistry.register-name($!name, self);
    }

    # For now this does the obvious thing and always returns a single dist. But it is wired up
    # to handle multiple distributions (hence installed(), etc) for things like submodules.

    my role CURID {
        has $.id;
    }
    method installed(--> Seq) {
        $dists-lock.protect: {
            @!dists = @!dists.elems ?? @!dists !! do {
                my $gh-dist  = Distribution::Common::Remote::Github.new(:$!user, :$!repo, :$!branch);
                my $cur-dist = CompUnit::Repository::Distribution.new($gh-dist);
                $gh-dist does CURID($cur-dist.id);
                $gh-dist;
            }
            return @!dists.Seq;
        }
    }

    proto method files(|) {*}
    multi method files($file, Str:D :$name!, :$auth, :$ver, :$api) {
        my $spec = CompUnit::DependencySpecification.new(
            short-name      => $name,
            auth-matcher    => $auth // True,
            version-matcher => $ver  // True,
            api-matcher     => $api  // True,
        );

        with self.candidates($spec) {
            my $matches := $_.grep: { .meta<files>{$file}:exists }

            my $absolutified-metas := $matches.map: {
                my $meta      = $_.meta;
                $meta<source> = $meta<files>{$file}.IO; # todo: point at something githubish?
                $meta;
            }

            return $absolutified-metas;
        }
    }
    multi method files($file, :$auth, :$ver, :$api) {
        my $spec = CompUnit::DependencySpecification.new(
            short-name      => $file,
            auth-matcher    => $auth // True,
            version-matcher => $ver  // True,
            api-matcher     => $api  // True,
        );

        with self.candidates($spec) {
            my $absolutified-metas := $_.map: {
                my $meta      = $_.meta;
                $meta<source> = $meta<files>{$file}.IO; # todo: point at something githubish?
                $meta;
            }

            return $absolutified-metas;
        }
    }

    proto method candidates(|) {*}
    multi method candidates(Str:D $name, :$auth, :$ver, :$api) {
        return samewith(CompUnit::DependencySpecification.new(
            short-name      => $name,
            auth-matcher    => $auth // True,
            version-matcher => $ver  // True,
            api-matcher     => $api  // True,
        ));
    }
    multi method candidates(CompUnit::DependencySpecification $spec) {
        return Empty unless $spec.from eq 'Perl6';

        my $version-matcher = ($spec.version-matcher ~~ Bool)
            ?? $spec.version-matcher
            !! Version.new($spec.version-matcher);
        my $api-matcher = ($spec.api-matcher ~~ Bool)
            ?? $spec.api-matcher
            !! Version.new($spec.api-matcher);

        my $matching-dists := self.installed.grep: {
            my $name-matcher = any(
                $_.meta<name>,
                |$_.meta<provides>.keys,
                |$_.meta<files>.keys,
            );

            so $spec.short-name ~~ $name-matcher
                and ($_.meta<auth> // '') ~~ $spec.auth-matcher
                and Version.new($_.meta<ver> // 0)  ~~ $version-matcher
                and Version.new($_.meta<api> // 0)  ~~ $api-matcher
        }

        return $matching-dists;
    }

    method !matching-dist(CompUnit::DependencySpecification $spec) {
        return %!seen{~$spec} if %!seen{~$spec}:exists;

        my $dist = self.candidates($spec).head;

        return %!seen{~$spec} //= $dist;
    }

    method loaded(--> Iterable:D)  { %!loaded.values }
    method name(--> Str:D)         { $!name }
    method short-id(--> Str:D)     { 'github' }
    method id(--> Str:D)           { '{$!name}#{$!user}#{$!repo}#{$!branch}' ~ join '#', self.installed.map(*.id) }
    method can-install(--> Bool:D) { False }
    method path-spec(--> Str:D)    { "CompUnit::Repository::Github#name({$!name})#user({$!user})#repo({$!repo})#branch({$!branch})#{$!branch}" }

    method !content-id($distribution, $name-path) { $name-path ~ '#' ~ $distribution.id }

    method need(
        CompUnit::DependencySpecification  $spec,
        CompUnit::PrecompilationRepository $precomp = self.precomp-repository(),
        --> CompUnit:D)
    {
        return %!loaded{~$spec} if %!loaded{~$spec}:exists;

        with self!matching-dist($spec) {
            my $id = self!content-id($_, $spec.short-name);
            return %!loaded{$id} if %!loaded{$id}:exists;

            my $bytes  = Blob.new( $_.content($_.meta<provides>{$spec.short-name}).open(:bin).slurp-rest(:bin) );
            my $handle = CompUnit::Loader.load-source( $bytes );

            my $compunit = CompUnit.new(
                handle       => $handle,
                short-name   => $spec.short-name,
                version      => Version.new($_.meta<ver> // 0),
                auth         => ($_.meta<auth> // Str),
                repo         => self,
                repo-id      => $id,
                precompiled  => False,
                distribution => $_,
            );

            return %!loaded{~$spec} //= $compunit;
        }

        return self.next-repo.need($spec, $precomp) if self.next-repo;
        X::CompUnit::UnsatisfiedDependency.new(:specification($spec)).throw;
    }

    method load(Str(Cool) $name-path) returns CompUnit:D {
        my sub parse-value($str-or-kv) {
            do given $str-or-kv {
                when Str  { $_ }
                when Hash { $_.keys[0] }
                when Pair { $_.key     }
            }
        }
        my sub path2name { state %path2name = self.installed.head.meta<provides>.map({ parse-value(.value) => .key }) }
        my sub name2path { state %name2path = self.installed.head.meta<provides>.map({ .key => parse-value(.value) }) }

        my $name = path2name{$name-path} // (name2path(){$name-path} ?? $name-path !! Nil);
        my $path = name2path{$name-path} // (path2name(){$name-path} ?? $name-path !! Nil);

        if $path {
            return %!loaded{~$name-path} if %!loaded{~$name-path}:exists;

            with self.installed.head {
                my $bytes  = Blob.new( $_.content($_.meta<provides>{$name}).open(:bin).slurp-rest(:bin) );
                my $handle = CompUnit::Loader.load-source( $bytes );

                my $compunit = CompUnit.new(
                    handle       => $handle,
                    short-name   => $name,
                    version      => Version.new($_.meta<ver> // 0),
                    auth         => ($_.meta<auth> // Str),
                    repo         => self,
                    repo-id      => self.id,
                    precompiled  => False,
                    distribution => $_,
                );

                return %!loaded{~$name-path} //= $compunit;
            }
        }

        return self.next-repo.load($name-path.IO) if self.next-repo;
        die("Could not find $name-path in:\n" ~ $*REPO.repo-chain.map(*.Str).join("\n").indent(4));
    }

    method resolve(CompUnit::DependencySpecification $spec --> CompUnit:D) {
        with self!matching-dist($spec) {
            return CompUnit.new(
                :handle(CompUnit::Handle),
                :short-name($spec.short-name),
                :version(Version.new($_.meta<ver> // 0)),
                :auth($_.meta<auth> // Str),
                :repo(self),
                :repo-id(self!content-id($_, $spec.short-name)),
                :distribution($_),
            );
        }

        return self.next-repo.resolve($spec) if self.next-repo;
        Nil
    }

    method resource($dist-id, $key) {
        %!resources{$key} //= do {
            my $dist = self.installed().head.content($key); # TODO: lookup dist-id
            my $temp-repo-dir = $*TMPDIR.child($*REPO.id);
            my $temp-dist-dir = $temp-repo-dir.child($dist.id);
            my $temp-file     = $temp-dist-dir.child($key);

            mkdir $temp-repo-dir    unless $temp-repo-dir.e;
            mkdir $temp-dist-dir    unless $temp-dist-dir.e;
            mkdir $temp-file.parent unless $temp-file.parent.e;

            my $resource-handle = $dist.content($key); # TODO: lookup dist-id
            my $resource-bytes  = Blob.new($resource-handle.open(:bin).slurp-rest(:bin));

            spurt $temp-file, $resource-bytes;
            IO::Path.new($temp-file);
        }
    }
}
