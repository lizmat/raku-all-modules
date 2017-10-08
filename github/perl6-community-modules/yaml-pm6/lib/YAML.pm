use v6;

unit module YAML;

use YAML::Dumper;

our $*VERSION = '0.01';

our sub dump($object) is export {
    CATCH {
        default {
            say "Error: $!";
        }
    }
    YAML::Dumper.new.dump($object);
}

our sub load($yaml) is export {
    die "YAML.load is not yet implemented";
}
