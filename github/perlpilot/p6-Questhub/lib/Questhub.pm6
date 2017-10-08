use v6;
use HTTP::UserAgent;
use JSON::Tiny;
use Questhub::Quest;

class Questhub {
    has $.server is readonly = "http://questhub.io";
    has HTTP::UserAgent $.ua is readonly handles 'get' = HTTP::UserAgent.new;

    method get_quests(*%opts) {
        my $extra = '?';
        $extra ~= "&user=%opts<user>" if %opts<user>;
        $extra ~= "&status=%opts<status>" if %opts<status>;
        my $json = self.get(self.server ~ '/api/quest' ~ $extra).content.decode;
        my $data = from-json($json);
        my @quests;
        for @($data) -> $elem {
            $elem<id> //= $elem<_id> // '';
            $elem<owners> //= $elem<team>;
            push @quests, Questhub::Quest.new(|$elem);
        }
        return @quests;
    }
}

