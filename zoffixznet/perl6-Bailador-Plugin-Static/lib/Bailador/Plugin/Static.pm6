unit class Bailador::Plugin::Static:ver<3.001001>;

use MIME::Types;
constant $MIME = MIME::Types.new: ~%?RESOURCES<mime.types>;

method install ($app) {
    $app.get: rx{ ^ '/assets/' (.+) } => sub ($asset) {
        my $file = $*SPEC.catdir: 'assets', $*SPEC.splitdir($asset)
            .grep({ $_ ~~ $*SPEC.curupdir });

        return $app.response.code: 404 unless $file.IO.f;
        $app.response.headers<Content-Type>
        = $MIME.type($file.IO.extension) // 'application/octet-stream';;
        $app.render: $file.IO.slurp: :bin;
    };
}
