[![Build Status](https://travis-ci.org/zoffixznet/perl6-App-Lang-French-VerbTrainer.svg)](https://travis-ci.org/zoffixznet/perl6-App-Lang-French-VerbTrainer)

# NAME

`App::Lang::French::VerbTrainer` - Training program for learning tenses and conjugations of French verbs

# SYNOPSIS

User input is shown within angle brackets `<...>`:

```bash
$ fr-verbtrainer.p6 accepter
Press Ctrl+C to exit. Type '?' as the answer if you don't know it

Présent:
    il/elle/on: accepte
    ils/elles: acceptent
    je: accepteiosiner
Fautif!
    je: accepte
    nous: acceptons
    tu: acceptes
    vous: acceptez

Future proche:
    il/elle/on: va accepter
    ils/elles: […]
    […]
```

# DESCRIPTION

You start the program giving a French verb as a command line argument and it asks you to conjugate
it in several tenses. All verbs are supported and the idea is this trainer program will train you
proper endings, etc.

Currently, only Présent, Future Proche, Imparfait, and Passé Composé tenses
are supported. Will add more, once I learn them.

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-App-Lang-French-VerbTrainer

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-App-Lang-French-VerbTrainer/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
