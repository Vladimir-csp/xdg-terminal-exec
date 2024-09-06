SHELL = /bin/sh
prefix ?= /usr/local
exec_prefix ?= $(prefix)
bindir ?= $(exec_prefix)/bin
datarootdir ?= $(prefix)/share
mandir ?= $(datarootdir)/man
man1dir ?= $(mandir)/man1

xdg-terminal-exec.1:
	@type scdoc >/dev/null || { echo "scdoc not found in PATH" >&2; exit 127; }
	@type gzip >/dev/null || { echo "gzip not found in PATH" >&2; exit 127; }
	scdoc < xdg-terminal-exec.1.scd | gzip -c > xdg-terminal-exec.1.gz

.PHONY: all
all: xdg-terminal-exec.1

.PHONY: clean
clean:
	rm -f xdg-terminal-exec.1.gz

.PHONY: install-man
install-man: xdg-terminal-exec.1
	install -Dm644 xdg-terminal-exec.1.gz -t $(man1dir)

.PHONY: install-bin
install-bin:
	install -Dm755 xdg-terminal-exec -t $(bindir)

.PHONY: install-conf
install-conf:
	install -Dm644 xdg-terminals.list -t $(datarootdir)/xdg-terminal-exec

.PHONY: install
install: install-man install-bin install-conf

.PHONY: uninstall
uninstall:
	rm -f $(bindir)/xdg-terminal-exec
	rm -f $(man1dir)/xdg-terminal-exec.1.gz
	rm -f $(datarootdir)/xdg-terminal-exec/xdg-terminals.list
	rmdir $(datarootdir)/xdg-terminal-exec/
