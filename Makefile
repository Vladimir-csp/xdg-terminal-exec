.PHONY: all clean install-man install-bin install-conf install uninstall test

SHELL = /bin/sh
prefix ?= /usr/local
exec_prefix ?= $(prefix)
bindir ?= $(exec_prefix)/bin
datarootdir ?= $(prefix)/share
mandir ?= $(datarootdir)/man
man1dir ?= $(mandir)/man1

%.1: %.1.scd
	@type scdoc >/dev/null 2>&1 || { echo "scdoc not found in PATH" >&2; exit 127; }
	scdoc < $< > $@

all: xdg-terminal-exec.1

clean:
	rm -f xdg-terminal-exec.1

install-man: xdg-terminal-exec.1
	install -Dpm644 xdg-terminal-exec.1 -t $(DESTDIR)$(man1dir)

install-bin: xdg-terminal-exec
	install -Dpm755 xdg-terminal-exec -t $(DESTDIR)$(bindir)

install-conf: xdg-terminals.list
	install -Dpm644 xdg-terminals.list -t $(DESTDIR)$(datarootdir)/xdg-terminal-exec

install: install-man install-bin install-conf

uninstall:
	-rm -f $(DESTDIR)$(bindir)/xdg-terminal-exec
	-rm -f $(DESTDIR)$(man1dir)/xdg-terminal-exec.1
	-rm -f $(DESTDIR)$(datarootdir)/xdg-terminal-exec/xdg-terminals.list
	-rm -fr $(DESTDIR)$(datarootdir)/xdg-terminal-exec

test:
	@type bats >/dev/null 2>&1 || { echo "bats not found in PATH" >&2; exit 127; }
	test/tests.bats
