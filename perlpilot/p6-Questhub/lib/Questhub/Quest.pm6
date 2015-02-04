use Questhub::Quest::State;

class Questhub::Quest {
    has Str $.id = !!! 'id required';
    has Str $.name = !!! 'name required';
    has Str $.author = !!! 'author required';
    has Questhub::Quest::State $.status = !!! 'status required';
    has Str @.owners = !!! 'owners required';
    has Str @.tags;
    has Str @.likes;

    method Str() {
        return join "\n", map { my $n = $_.name.substr(2); "$n: " ~ self."$n"() }, self.^attributes;
    }
}
