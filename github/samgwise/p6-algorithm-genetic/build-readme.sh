#! /bin/bash
# using Pod::To::Markdown
cat res/readme-header.md > readme.md
perl6 -Ilib --doc=Markdown lib/Algorithm/Genetic.pm6 >> readme.md
perl6 -Ilib --doc=Markdown lib/Algorithm/Genetic/Selection.pm6 >> readme.md
perl6 -Ilib --doc=Markdown lib/Algorithm/Genetic/Selection/Roulette.pm6 >> readme.md

perl6 -Ilib --doc=Markdown lib/Algorithm/Genetic/Genotype.pm6 >> readme.md
perl6 -Ilib --doc=Markdown lib/Algorithm/Genetic/Crossoverable.pm6 >> readme.md
