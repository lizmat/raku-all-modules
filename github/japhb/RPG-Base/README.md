[![Build Status](https://travis-ci.org/japhb/RPG-Base.svg?branch=master)](https://travis-ci.org/japhb/RPG-Base)

NAME
====

`RPG::Base` - Common base components for RPGs

SYNOPSIS
========

    use RPG::Base::Container;
    use RPG::Base::Creature;
    use RPG::Base::Location;
    use RPG::Base::Thing;

    # Using the base classes directly
    my $bob      = RPG::Base::Creature.new(:name('Bob the Magnificent'));
    my $backpack = RPG::Base::Container.new(:name('Cloth Backpack'));
    my $flint    = RPG::Base::Thing.new(:name('Flint and Steel'));
    my $wand     = RPG::Base::Thing.new(:name('Ironwood Wand'));

    my $clearing = RPG::Base::Location.new(:name('Grassy Clearing'));
    my $grove    = RPG::Base::Location.new(:name('Oak Grove'));
    my $cliff    = RPG::Base::Location.new(:name('Sheer Cliff'));

    $backpack.add-thing($flint);
    $bob.add-thing($_) for $backpack, $wand;

    $grove   .add-exit('north' => $clearing);
    $cliff   .add-exit('down'  => $clearing);
    $clearing.add-exit('south' => $grove);
    $clearing.add-exit('up'    => $cliff);
    $clearing.add-thing($bob);

    $clearing.say;  # "Grassy Clearing (exits: 2, things: 1)"
    $bob.say;       # "Bob the Magnificent (RPG::Base::Creature in
                    #  RPG::Base::Location 'Grassy Clearing' carrying
                    #  Cloth Backpack (contents: Flint and Steel),
                    #  Ironwood Wand)"

    $clearing.move-thing('south' => $bob);
    $clearing.say;       # "Grassy Clearing (exits: 2, things: 0)"
    $bob.container.say;  # "Oak Grove (exits: 1, things: 1)"

DESCRIPTION
===========

`RPG::Base` is a set of common base concepts and components on which more complex RPG rulesets can be based. It limits itself to those concepts that are near universal across RPGs (though some games use different terminology, `RPG::Base` simply chooses common terms knowing that game-specific subclasses can be named using that game's particular terminology).

The entire point of `RPG::Base` is to be subclassable, extensible, and generic. If it turns out that one of the design choices is making that difficult, **please let me know**.

STABILITY
---------

`RPG::Base` is not entirely stable, as befits the low version number (though already in use as the base of considerably more complete rulesystems). A first approximation of stability can be seen by looking at the tests for each module. Modules with lots of tests but specific `XXXX` markers still have a few slushy behaviors and might change a bit; those with very few tests or even just a `plan :skip-all` at the top of the test file represent conjectured designs and are probably very much still in flux.

CONTRIBUTING
============

Pull requests are very welcome! It will take the implementation of many rulesets based on `RPG::Base` to find all the common code and concepts that should be factored out, and I'm certainly not going to be implementing them all myself. That said, please be aware that if I believe the new code wouldn't work well with one of the other rulesets or will block off a useful direction for extension, I may alter the PR before merging, or ask you to consider a different approach to make sure it fits well into the ecosystem.

Please be *very* careful with copyrights and trademarks. Some of the companies that own game system intellectual property are famously litigious and it's important that any such questions stay well away from `RPG::Base` so that the "blast radius" of an IP disagreement won't include all modules depending on this one.

Stylistically, I generally keep with Larry Wall's classic Perl formatting rules (4 space indents, uncuddled elses, opening brace on same line as the control structure it goes with, and so on). I prefer to use the Unicode forms of operators such as `»` and `∈` rather than the pure ASCII forms. Due to quirks of my brain, I will tend to favor aligning similar parts of consecutive lines when I can get it. This tends to manifest most often in variable and class attribute definitions, where I align the type names, attribute names, and default values in columns. Finally, I treat overall readability as more important than strict adherence to 80 column width, which I see as a good default because it happens to be fairly readable and guides one towards limiting the complexity of each line, not a hard limit that should be enforced with an iron will.

AUTHOR
======

Geoffrey Broadwell <gjb@sonic.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2016-2018 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

