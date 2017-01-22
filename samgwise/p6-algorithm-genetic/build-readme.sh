#! /bin/bash
# using Pod::To::Markdown::Fenced
cat res/readme-header.md > readme.md
perl6 -Ilib --doc=Markdown::Fenced lib/Algorithm/Genetic.pm6 >> readme.md
perl6 -Ilib --doc=Markdown::Fenced lib/Algorithm/Genetic/Selection.pm6 >> readme.md
perl6 -Ilib --doc=Markdown::Fenced lib/Algorithm/Genetic/Selection/Roulette.pm6 >> readme.md

perl6 -Ilib --doc=Markdown::Fenced lib/Algorithm/Genetic/Genotype.pm6 >> readme.md
perl6 -Ilib --doc=Markdown::Fenced lib/Algorithm/Genetic/Crossoverable.pm6 >> readme.md
