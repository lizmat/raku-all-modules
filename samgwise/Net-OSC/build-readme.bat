# using Pod::To::Markdown::Fenced
type res\readme-header.md > README.md
echo. >> README.md
call perl6 -Ilib --doc=Markdown::Fenced lib\Net\OSC.pm6 >> README.md
echo. >> README.md
call perl6 -Ilib --doc=Markdown::Fenced lib\Net\OSC\Message.pm6 >> README.md
echo. >> README.md
call perl6 -Ilib --doc=Markdown::Fenced lib\Net\OSC\Bundle.pm6 >> README.md
echo. >> README.md
call perl6 -Ilib --doc=Markdown::Fenced lib\Net\OSC\Server.pm6 >> README.md
echo. >> README.md
call perl6 -Ilib --doc=Markdown::Fenced lib\Net\OSC\Server\UDP.pm6 >> README.md
echo. >> README.md
call perl6 -Ilib --doc=Markdown::Fenced lib\Net\OSC\Transport\TCP.pm6 >> README.md
