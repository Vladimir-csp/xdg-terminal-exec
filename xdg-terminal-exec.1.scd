XDG-TERMINAL-EXEC(1)
; scdoc manpage, build and compress:
; scdoc < xdg-terminal-exec.1.scd | gzip -c > xdg-terminal-exec.1.gz

# NAME

*xdg-terminal-exec* - Default Terminal Execution Utility

# SYNOPSIS

*xdg-terminal-exec* [_options_] [--] [_command_ [_arguments ..._]]

# DESCRIPTION

Shell-based implementation of the proposed Default Terminal Execution
Specification. Launches preferred terminal emulator, with or without optionally
supplied command.

Terminal emulators are selected among Desktop Entries that are installed on the
system, or added by user according to XDG Desktop Entry Spec. Only valid Entries
with *TerminalEmulator* category and *X-TerminalArgExec=* key set are
considered (*X-TerminalArgExec=* key is not required in compat mode).

Command execution argument is determined by Entry's *X-TerminalArgExec=* key,
(assumed to be *-e* by default in compat mode). If an actual *-e* or matching
execution argument is given on the command line, it will be silently discarded
along with any unsupported dashed option given before unambiguous command.

It is assumed that the emulator handles command line after the execution
argument *as is* (preserved separate arguments).

# OPTIONS

Monolithic options starting with "*--*" are used to modify behavior of terminal
(if supported by terminal and its entry):

- *--app-id=*_app\_id_: set app-id (Wayland) or class (X11).
- *--title=*_title_: set tile of terminal.
- *--dir=*_workdir_: set workdir of terminal.
- *--hold*: instruct terminal to hold after command ends.

Options for printing data instead of executing terminal:

- *--print-id*: print selected Desktop Entry ID. Action is appended delimited
  by "*:*".
- *--print-path*: print path to selected Desktop Entry. Action is appended
  delimited by "*:*".
- *--print-content*: print content of selected Desktop Entry. Conflicts with
  *--print-cmd*.
  executing.
- *--print-cmd*[*=*_printf_sequence_]: print resulting command line, delimited by
  given printf sequence, "*\\n*" by default. If sequence is "*\\n*", output is
  also terminated with newline. Conflicts with *--print-content*.

Selected data is printed in order:

- id
- path
- content or cmd

# CONFIGURATION

Preferred terminals are configured by listing them in config files
named _${desktop}_*-xdg-terminals.list* or *xdg-terminals.list*
placed in XDG Config hierarchy.

_${desktop}_ here is a lowercased string that is matched (case-insensitively)
against items of _${XDG_CURRENT_DESKTOP}_ (a colon-separated list of names for
the current DE) in order of decreasing priority.

The file is a simple newline-separated list. Empty lines and lines starting with
"*#*" are ignored, dangling whitespaces are trimmed.

Terminals are listed by their Desktop Entry ID:

	_terminal_*.desktop*

Optionally with Action ID suffixed via "*:*":

	_terminal_*.desktop*:_action_

Files are searched in XDG Config directories in the order of decreasing
priority. In each directory, prefixed files are parsed first, in the order
listed in _${XDG_CURRENT_DESKTOP}_. Unprefixed files parsed last in each dir.

The first listed, found, and valid Desktop Entry is used.

Otherwise fallback to the first found and valid Desktop Entry is performed.

Entries can be excluded from fallback by listing their ID prefixed with "*-*":

	*-*_terminal_*.desktop*

Prefixing entry with "*+*" will prevent it from later exclusion (first
encountered directive wins):

	*+*_terminal_*.desktop*

Special directives understood by this implementation (the first encountered
directive is used):

	*/enable_cache*, */disable_cache*

The cache feature allows storing selected terminal command line in
_${XDG_CACHE_HOME}_ to bypass reading and parsing of configuration and Desktop
Entries until changes are detected in the listing of Desktop Entry files
or config files (enabled by default).

	*/execarg_compat*, */execarg_strict*

Compat mode (currently enabled by default) allows support for legacy
*[X-]ExecArg* key and allows entries without execution argument, providing _-e_
default.

	*/execarg_default:*_entry.desktop_*:*_arg_

Customize defaults for execution arguments of specific terminal entries (only in
compat mode).

# FILES

Default paths for configuration files (in order of decreasing priority):

In _${XDG_CONFIG_HOME}_:
- _${HOME}_*/.config/*_${desktop}_*-xdg-terminals.list*
- _${HOME}_*/.config/xdg-terminals.list*

In _${XDG_CONFIG_DIRS}_:
- */etc/xdg/*_${desktop}_*-xdg-terminals.list*
- */etc/xdg/xdg-terminals.list*

In _${XDG_DATA_DIRS}_:
- */usr/share/xdg-terminal-exec/*_${desktop}_*-xdg-terminals.list*
- */usr/share/xdg-terminal-exec/xdg-terminals.list*

Default directories for Desktop Entries (in order of decreasing priority):

in _${XDG_DATA_HOME}_:
- _${HOME}_*/.local/share/applications/*

in _${XDG_DATA_DIRS}_:
- */usr/local/share/applications/*
- */usr/share/applications/*

Cache file:
- _${XDG_CACHE_HOME}_*/xdg-terminal-exec*

# ENVIRONMENT

*XTE_CACHE_ENABLED* (truthy or falsy value)
	Enable or disable cache feature.

*DEBUG* (truthy or falsy value)
	Print debug info to stderr.

# EXTERNAL LINKS

Proposal PR:

https://gitlab.freedesktop.org/terminal-wg/specifications/-/merge_requests/3/diffs

XDG Base Directory Spec:

https://specifications.freedesktop.org/basedir-spec/latest/

XDG Desktop Entry Spec:

https://specifications.freedesktop.org/desktop-entry-spec/latest/

Desktop Entry ID:

https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s02.html#desktop-file-id

Desktop Entry Action ID:

https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s11.html

# AUTHORS

Vladimir-csp (https://github.com/Vladimir-csp, https://gitlab.freedesktop.org/Vladimir-csp)

Thanks to Nathan Teodosio (https://github.com/nteodosio) for jump-starting the creation of this manpage.
