unit class App::Lang::French::VerbTrainer;

subset ValidFrenchVerb of Str:D is export where {
    .ends-with: <er re ir>.any or note "Verb must end with `er`, `re`, or `ir`" and exit
}

has ValidFrenchVerb $.verb is required;
has Str:D $!base = $!verb.substr: 0, *-2;
has Str:D $!type = $!verb.substr: *-2;

method présent {
    {
      :er{ :je<e>,  :tu<es>, :nous<ons>, :vous<ez>, "il/elle/on" => "e", "ils/elles" => "ent" },
      :re{ :je<s>,  :tu<s>,  :nous<ons>, :vous<ez>, "il/elle/on" => "",  "ils/elles" => "ent" },
      :ir{ :je<is>, :tu<is>, :nous<issons>, :vous<issez>,
        "il/elle/on" => "it", "ils/elles" => "issent" },
    }{$!type}.map({ .value [R~]= $!base; $_ }).Map
}

method future-proche {
    { :je<vais>, :tu<vas>, :nous<allons>, :vous<allez>, "il/elle/on" => "va", "ils/elles" => "vont",
    }.map({ .value ~= " $!verb"; $_ }).Map
}

method imparfait {
    {
      :erre{ :je<ais>,  :tu<ais>, :nous<ions>, :vous<iez>, "il/elle/on" => "ait",
        "ils/elles" => "aient" },
      :ir{ :je<issais>, :tu<issais>, :nous<issions>, :vous<issiez>,
        "il/elle/on" => "issait", "ils/elles" => "issaient" },
    }{$!type eq 'ir' ?? 'ir' !! 'erre'}.map({ .value [R~]= $!base; $_ }).Map
}

method passé-composé {
    Map.new: ("je/tu/il/elle/on/nous/vous/ils/elles" => $!base ~ "é")
}

method ask (Str:D $name, Map:D \stuff) {
    say "\n$name:";
    for stuff.sort {
        next if .value eq my \ans := trim fc (prompt "    {.key}: ")//'';
        if ans eq ''|'?' {
            say "    {.key}: {.value}";
            next;
        }
        say "Fautif!";
        redo;
    }
}
