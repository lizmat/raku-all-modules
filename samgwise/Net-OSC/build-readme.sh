#! /bin/bash
# using Pod::To::Markdown::Fenced
cat res/readme-header.md > README.md
perl6 -Ilib --doc=Markdown::Fenced lib/Net/OSC.pm6 >> README.md
perl6 -Ilib --doc=Markdown::Fenced lib/Net/OSC/Message.pm6 >> README.md
perl6 -Ilib --doc=Markdown::Fenced lib/Net/OSC/Server.pm6 >> README.md
perl6 -Ilib --doc=Markdown::Fenced lib/Net/OSC/Server/UDP.pm6 >> README.md
