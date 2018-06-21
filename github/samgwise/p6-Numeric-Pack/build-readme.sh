#! /bin/bash
# using Pod::To::Markdown::Fenced
cat res/readme-header.md > README.md
echo $'\n' >> README.md
perl6 -Ilib --doc=Markdown lib/Numeric/Pack.pm6 >> README.md
