.PHONY: all build test install

all: build

build:
	echo "Build done"
test:
	shellcheck pkgstats.sh
	bats tests

install:
	install -D pkgstats.sh -m755 "$(DESTDIR)/usr/bin/pkgstats"
	install -Dt "$(DESTDIR)/usr/lib/systemd/system/" -m644 pkgstats.timer
	install -Dt "$(DESTDIR)/usr/lib/systemd/system/" -m644 pkgstats.service
	install -d "$(DESTDIR)/usr/lib/systemd/system/timers.target.wants"
	ln -st "$(DESTDIR)/usr/lib/systemd/system/timers.target.wants" ../pkgstats.timer
