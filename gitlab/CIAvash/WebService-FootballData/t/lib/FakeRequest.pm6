use WebService::FootballData::Role::Request;

unit class FakeRequest does WebService::FootballData::Role::Request;

has Str $!data_dir = $?FILE.IO.dirname ~ '/data/';

method get (Str $url is copy, :%params) {
    $url ~= "-{.key}({.value})" for %params.sort;
    my $response = self!from_json(self!file_content($url));
    return if $response<error>:exists;
    $response;
}

method !file_content (Str $file_name) {
    my $path = $!data_dir ~ $file_name ~ '.json';
    $path = $!data_dir ~ 'error.json' unless $path.IO.f;
    $path.IO.slurp;
}