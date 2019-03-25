dist:
	mkdir -p pod-load-$(VERSION)/resources/examples \
	&& mkdir -p pod-load-$(VERSION)/t \
	&& mkdir -p pod-load-$(VERSION)/lib/Pod \
	&& cp META6.json Changes README.md LICENSE pod-load-$(VERSION) \
	&& cp lib/Pod/Load.pm6 pod-load-$(VERSION)/lib/Pod \
	&& cp t/*.t t/*.*6 pod-load-$(VERSION)/t \
	&& cp resources/examples/*.md resources/examples/*.*6 pod-load-$(VERSION)/resources/examples \
        && tar cvfz pod-load-$(VERSION).tgz pod-load-$(VERSION)/
