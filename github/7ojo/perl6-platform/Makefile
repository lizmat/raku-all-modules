VERSION=$(shell egrep -o "([0-9]{1,}\.)+[0-9]{1,}" META6.json)

pause:
	git archive --prefix=App-Platform-$(VERSION)/ -o ../App-Platform-$(VERSION).tar.gz HEAD

test:
	prove -e perl6 t/
