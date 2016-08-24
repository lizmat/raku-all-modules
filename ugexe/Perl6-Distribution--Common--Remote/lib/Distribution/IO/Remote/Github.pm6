use Net::HTTP::GET;
use Distribution::IO;

role Distribution::IO::Remote::Github does Distribution::IO {
    method user    { ... }
    method repo    { ... }
    method branch  { ... }

    method !content-uri($name-path = '') { "https://raw.githubusercontent.com/{$.user}/{$.repo}/{$.branch}/{$name-path}"     }
    method !ls-files-uri                 { "https://api.github.com/repos/{$.user}/{$.repo}/git/trees/{$.branch}?recursive=1" }
    method !header {
        my %header;
        with self.?api-key { %header<Authorization> = "token {$_}" }
        %header;
    }
    method !https-request($url) {
        Net::HTTP::GET($url, header => self!header)
    }

    method slurp-rest($name-path, Bool :$bin) {
        my $response = self!https-request(self!content-uri($name-path));
        $bin ?? $response.body !! $response.content;
    }

    method ls-files {
        state @paths = do {
            my $request = self!https-request(self!ls-files-uri);
            my $json    = Rakudo::Internals::JSON.from-json($request.content)<tree>;
            $json.grep(*.<type>.?chars).grep({.<type>.lc eq 'blob'}).map(*.<path>)
        }
    }
}
