# xdg-terminal-exec

Proposal for XDG Default Terminal Execution Specification and reference
shell-based implementation.

# Default Terminal Execution Specification

This configuration spec is crafted in image of
[mime-apps-spec](https://specifications.freedesktop.org/mime-apps-spec/latest/ar01s02.html)
and fully relies on
[basedir-spec](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html).

Terminal emulators (with their exec arguments) are described by stock Desktop
Entries located in `applications` subdirs of XDG data hierarchy and marked by
`TerminalEmulator` category.

Preferred terminals are configured by listing their
[entry IDs](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s02.html#desktop-file-id)
in config files named `${desktop}-xdg-terminals.list` or `xdg-terminals.list`
placed in XDG config hierarchy. The format is a simple newline-separated list.

Optionally an entry ID can be suffixed with
[action ID](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s11.html),
delimited by `:` (`entry-id.desktop:action-id`).

Empty lines and lines starting with `#` are ignored, dangling whitespaces are
trimmed.

Special directives for modifying behavior of implementations may be present in
config files. Directives that are not listed by this spec and are not understood
by a particular implementation should be discarded.

Directives should not contain `.desktop` substring in them. And it is
recommended to start directives with a symbol that is not valid for entry ID,
i.e. `/`.

Default paths for configuration and data are resolved into (in order of
decreasing priority):

- config files (in `${XDG_CONFIG_HOME}:${XDG_CONFIG_DIRS}`):
  - `${HOME}/.config/${desktop}-xdg-terminals.list`
  - `${HOME}/.config/xdg-terminals.list`
  - `/etc/xdg/${desktop}-xdg-terminals.list`
  - `/etc/xdg/xdg-terminals.list`
- desktop entries (in `${XDG_DATA_HOME}:${XDG_DATA_DIRS}`):
  - `${HOME}/.local/share/applications/`
  - `/usr/local/share/applications/`
  - `/usr/share/applications/`

Where `${desktop}` is a lowercased string that can be matched
(case-insensitively) against items of `$XDG_CURRENT_DESKTOP` (a colon-separated
list of names for the current DE) in order of decreasing priority.

## Priority of selecting an entry

- A list of explicitly preferred entry IDs is composed by taking previously
  unseen IDs:
  - from each dir of XDG config hierarchy in the order of decreasing priority:
    - from `${desktop}-xdg-terminals.list` files in the order of
      `$XDG_CURRENT_DESKTOP` items
    - from `xdg-terminals.list`
- Each entry from the resulting list is checked for applicability:
  - presense of `TerminalEmulator` category if using stock `applications` data
    subdirs
  - validation by the same rules as in Desktop Entry Spec, except `*ShowIn`
    conditions
  - entry is discarded if it does not pass the checks
  - the first applicable entry is used
- If no applicable entry is found, each entry from XDG data hierarchy (except
  those discarded earlier) is checked for applicability:
  - presense of `TerminalEmulator` category if using stock `applications` data
    subdirs
  - validation by the same rules as in Desktop Entry Spec, now including
    `*ShowIn` conditions
  - the first applicable entry is used
    - the order in which found entries under the same base directory are checked
      in is undefined
- If no applicable entry is found, an error is returned.

## Desktop entry for a terminal

Stock desktop entry for terminal emulator may be used. Command execution
argument defaults to `-e`. Key `X-ExecArg=` can be used to override it or omit
by explicitly setting to an empty value.

Whether launched terminal process waits for command to finish or exits
immediately (i.e. after sending IPC request to a master process) is not defined
by the this spec. Some IPC-using terminals provide separate entries or
[actions](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s11.html)
for launching separate processes without IPC.

## Syntax

```
xdg-terminal-exec [command [arguments]]
```

If run without any arguments, only the terminal itself (value of `Exec=`) is
executed.

If a command (with or witout its arguments) is given, then values of both
`Exec=` and `X-ExecArg=` (if not explicitly empty) are used, along with provided
command and arguments that are transmitted as is.

If `-e` or matching execution argument is given explicitly as the first argument
on the command line, it should be discarded for backwards compatibility with
software that hardcodes these arguments.

The resulting command is executed without forking.

## Limitations and compliance of terminals

There is no mechanism for handling special quoting and arguments/strings that
may be required for some terminals.

The expected behavior is modelled after xterm and is arguably common for a
majority of terminals. This example:

```
xdg-terminal-exec nano "some file with spaces"\ and\ unquoted\ spaces second\ file
```

is expected to launch `nano` editing two files named
`some file with spaces and unquoted spaces` and `second file`.

# Notes

## Arguments

IMHO `xterm -e` handling of arguments is the golden standard, any terminal that
fails to do so should be bugreported.

Some examples of compliant terminals: xterm, alacritty, kitty, foot, qterminal

Terminals that use `-e` but mangle arguments: sakura

## This shell-based implementation and performance

Setting `DEBUG` env to a truthy value will output verbose messages to stderr.

The shell code itself is quite optimized and fast, especially when using a slick
`sh` implementation like `dash`.

The most taxing part of the algorithm is reading all the desktop entry files for
parsing in search of an applicable terminal among them.

Having a valid entry specified in `*xdg-terminals.list` speeds up the process
significantly, shifting the bottleneck to `find` calls for composing the list of
desktop entries.

### Cache

This implementation can also cache selected terminal for fast read at a cost of
reading one file (`${XDG_CACHE_HOME:-$HOME/.cache}/xdg-terminal-exec`) and
feeding `md5sum` the value of `$XDG_CURRENT_DESKTOP` and output of `ls -LRl` for
all possible config file and data dir paths in one go. Valid cache bypasses
reading of any other file.

Currentry this feature is disabled by default and can be controlled by first
encountered `/enable_cache`|`/disable_cache` direcive in the configs or
`XTE_CACHE_ENABLED` env var (truthy or falsy value, has priority).

Unless `XTE_CACHE_ENABLED` is false, an attempt at reading the cache file is
always performed though. Its existence translates into initial assumption about
cache feature state. If cache is invalid (which it should be if a config was
edited to disable the cache), usual process of reading configs and entries will
occur. The cache file is always removed when the script knows for sure that the
cache feature is disabled.

Caveat: If the cache was enabled solely via truthy `XTE_CACHE_ENABLED` value,
and the var was later removed, the script will not know that the cache is
disabled until one of three things happens: cache file is removed, something
invalidates it (like touching/editing a config/entry), or a run with falsy
`XTE_CACHE_ENABLED` is performed.

The plan is to eventually enable it by default for unattended fastness.
