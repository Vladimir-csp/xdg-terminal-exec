prefix ?= /usr/local
exec_prefix ?= $(prefix)
bindir ?= $(exec_prefix)/bin
datarootdir ?= $(prefix)/share
mandir ?= $(datarootdir)/man
man1dir ?= $(mandir)/man1

xdg-terminal-exec.1:
	@command -v scdoc >/dev/null || $(error Could not find scdoc in PATH, please install it) 
	@command -v gzip >/dev/null || $(error Could not find gzip in PATH, please install it)
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
	install -D xdg-terminal-exec -t $(bindir)

.PHONY: install
install: install-man install-bin

.PHONY: uninstall
uninstall:
	rm -f $(bindir)/xdg-terminal-exec
	rm -f $(man1dir)/xdg-terminal-exec.1.gz
