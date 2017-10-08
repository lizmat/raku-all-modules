use Test;
use RPG::Base::Container;


plan 32;


{
    my $backpack = RPG::Base::Container.new(:name('backpack'));
    my $flask    = RPG::Base::Container.new(:name('flask'));
    my $bag      = RPG::Base::Container.new(:name('bag'));
    my @all      = $backpack, $flask, $bag;

    isa-ok $_,  RPG::Base::Container      for @all;
    isa-ok $_,  RPG::Base::Thing          for @all;
    does-ok $_, RPG::Base::ThingContainer for @all;

    $backpack.add-thing($flask);
    $backpack.add-thing($bag);
    my @contents = $flask, $bag;

    ok .container === $backpack, "backpack is {$_}.container" for @contents;
    ok $_ ∈ $backpack.contents,  "$_ is in backpack contents" for @contents;
    nok .contents,               "$_ has no contents"         for @contents;

    ok .Str.contains(.name),           "$_ mentions its name in default .Str"  for @all;
    nok .Str.contains('('),            "$_ has no parentheses in default .Str" for @contents;
    ok .gist.contains(.name),          "$_ mentions its name in default .gist" for @all;
    ok .gist.contains(.^name),         "$_ mentions its type in default .gist" for @all;
    ok .gist.contains('backpack'),     "$_ mentions backpack in default .gist" for @contents;
    ok $backpack.gist.contains(.name), "backpack mentions $_ in default .gist" for @contents;
    ok $backpack.Str.contains(.name),  "backpack mentions $_ in default .Str"  for @contents;
}


done-testing;
