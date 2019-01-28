use Config::Parser;

use JSON::Tiny;

class Config::Parser::json is Config::Parser {
    method read(Str $path --> Hash) {
        from-json(slurp($path));
    }
}
