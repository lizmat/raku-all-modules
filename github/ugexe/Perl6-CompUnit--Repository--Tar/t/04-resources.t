use Test;
plan 1;

use CompUnit::Repository::Tar;

use lib "CompUnit::Repository::Tar#{$?FILE.IO.parent.child('data/zef.tar.gz')}";
use Zef::Config;


ok Zef::Config::guess-path.?ends-with("config.json"), '%?RESOURCES<config.json>';
