MinG
====

A small module for working with Stabler's Minimalist Grammars in Perl6.

[![Build Status](https://travis-ci.org/IanTayler/MinG.svg?branch=master)](https://travis-ci.org/IanTayler/MinG)

STRUCTURE
=========

As of now there are four (sub)modules: MinG, MinG::S13, MinG::S13::Logic and MinG::From::Text.

In MinG, you'll find the necessary classes and subroutines for creating descriptions of Minimalist Grammars. It's not of much use by itself unless you're planning to implement your own parser/etc. and want to save yourself the time of having to define classes and useful functions.

In MinG::S13, you'll find Stabler's (2013) "Two models of minimalist, incremental syntactic analysis" parser. Currently, this parser analyses all possibilities, while Stabler's parser discards low-probability derivations. There's a helper submodule called MinG::S13::Logic.

Finally, in MinG::From::Text you'll find a parser that creates MinG::Grammar-s out of text descriptions of MGs.

More documentation can be found in HTML files inside the doc/ directory.

INSTALLATION
============

If you have perl6 and panda or zef, the following should suffice:

        zef install MinG

If you don't, the easiest is probably to install rakudobrew <https://github.com/tadzik/rakudobrew> and then run:

        rakudobrew build moar --gen-moar --gen-nqp --backend=moar
        rakudobrew build zef

and you should be ready to install this module with zef.

The best option may be to install Rakudo Star <http://rakudo.org/how-to-get-rakudo/> which comes with zef and some common modules. There's lots of tutorials about how to get perl6. Follow one of them and make sure you install zef (or panda).

EXAMPLE USAGE
=============

As of now, someone who isn't interested in the inner workings of the module but wants to try out some minimalist grammars can easily create their grammar following this template:

    START=F
    word1 :: =F =F -F F
    word2 :: =F F
    :: =F =F F
    .
    .
    .
    word23 :: =F F ...

Without the dots, and changing _wordi_ for your phonetic word (and, of course, changing F for whatever features you want your grammars to have). For two example grammars, check the resources/ directory.

You can save that as a file named grammar.mg.

Then, a minimal script to use that grammar is:

    use MinG;
    use MinG::S13;
    use MinG::S13::Logic; # May not be necessary. Add it just in case, for forward-compatibility.
    use MinG::From::Text;

    my $g = grammar_from_file("./grammar.mg");
    my $p = MinG::S13::Parser.new();
    $p.init($g);

    for $*IN.lines() -> $line {
        $p.parse_str($line);
    }

You can copy-paste that, save it as parser.p6 (in the same directory as grammar.mg) and then simply run `perl6 parser.p6`. Each line you write of input will be parsed using your grammar. You can modify grammar.mg at any point and restart parser.p6 to have your new grammar working.

If you want to try out existing grammars, you can use one of two default grammars that can be accessed by passing the variables $ESPA0 (for "español") or $ENG0 (for "english") to the subroutine grammar_from_file() (instead of passing "./grammar.mg"). You can check the grammars out at resources/ in this repository.

When inputting lines, pay attention _not_ to put a final dot to your sentence. "dance." is a different word from "dance".

CURRENTLY
=========

  * Has classes that correctly describe MGs (MinG::Grammar), MG-LIs (MinG::LItem) and MG-style-features (MinG::Feature).

  * Has a subroutine (feature_from_str) that takes a string description of a feature (e.g. "=D") and returns a MinG::Feature.

  * Has lexical trees for Stabler's (2013) parsing method (MinG::Grammar.litem_tree).

  * Automatically generates LaTeX/qtree code for trees. (Node.qtree inside MinG)

  * Has a working parser for MGs! (MinG::S13::Parser or MinG::S13.parse_and_spit())

  * Has a parser that reads grammars from a file! (MinG::From::Text)

TODO
====

  * Allow some useful expansions of MGs.

  * Make the parser more efficient by adding probabilistic rule-following.

MAYDO
=====

  * Create a probabilistic trainer.

  * Use annotated corpora to build lexical entries.

  * Use a small subset of predefined lexical entries and a non-annotated corpus to "guess" the feature specification of unknown lexical items.

  * Create a Montague-style semantics for MG trees.

  * Create a world-model for a knowledgable AI using such semantics.

AUTHOR
======

Ian G Tayler, `<iangtayler@gmail.com> `

COPYRIGHT AND LICENSE
=====================

Copyright © 2017, Ian G Tayler <iangtayler@gmail.com>. All rights reserved. This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
