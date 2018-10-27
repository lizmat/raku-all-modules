module XXX;

our $*VERSION = '0.01';

use YAML;

sub WWW($o) is export {
    note YAML::dump($o);
    return $o;
}

sub XXX($o) is export {
    warn YAML::dump($o);
    exit 1;
}

sub YYY($o) is export {
    print YAML::dump($o);
    return $o;
}

sub ZZZ($o) is export {
    die YAML::dump($o);
}
