check: README.md
	git diff-index --check HEAD
	prove6

README.md: lib/epoll.pm6
	perl6 --doc=Markdown $< > $@
