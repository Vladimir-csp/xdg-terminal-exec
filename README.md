# xdg-terminal-exec

Proposal for XDG Default Terminal Execution Specification and reference
shell-based implementation. The proposal PR can be found
[here](https://gitlab.freedesktop.org/terminal-wg/specifications/-/merge_requests/3/diffs).

(!) Please be advised that while this spec is in proposed state, backwards
compatibility is maintained as best effort and is not guaranteed.

Current major change pending in this implementation: discardable options.
(not implemented yet)

# Default Terminal Execution Specification

This configuration spec is crafted in image of
[mime-apps-spec](https://specifications.freedesktop.org/mime-apps-spec/latest)
and fully relies on
[basedir-spec](https://specifications.freedesktop.org/basedir-spec/latest).

Terminal emulators (with their exec arguments) are described by stock Desktop
Entries located in `applications` subdirs of XDG data hierarchy and marked by
`TerminalEmulator` category.

Preferred terminals are configured by listing their
[entry IDs](https://specifications.freedesktop.org/desktop-entry-spec/latest/file-naming.html#desktop-file-id)
in configuration files. Optionally an entry ID can be suffixed with
[action ID](https://specifications.freedesktop.org/desktop-entry-spec/latest/extra-actions.html),
delimited by `:` (`entry-id.desktop:action-id`).

## Configuration location

Configuration files are named `${desktop}-xdg-terminals.list` or `xdg-terminals.list`
and placed in XDG config hierarchy.

`${desktop}` here is a lowercased string that can be matched
(case-insensitively) against items of `$XDG_CURRENT_DESKTOP` (a colon-separated
list of names for the current DE) in order of decreasing priority.

Lower priority fallback config files (for upstream/distribution usage) are
paced in system part of XDG data hierarchy within `xdg-terminal-exec` subdirs.

Default paths for configuration and data are resolved into (in order of
decreasing priority):

- config files:
  - main config sequence (in `${XDG_CONFIG_HOME}:${XDG_CONFIG_DIRS}`):
    - `${HOME}/.config/${desktop}-xdg-terminals.list`
    - `${HOME}/.config/xdg-terminals.list`
    - `/etc/xdg/${desktop}-xdg-terminals.list`
    - `/etc/xdg/xdg-terminals.list`
  - upstream/distribution config fallbacks (subdirs in `${XDG_DATA_DIRS}`):
    - `/usr/local/share/xdg-terminal-exec/${desktop}-xdg-terminals.list`
    - `/usr/local/share/xdg-terminal-exec/xdg-terminals.list`
    - `/usr/share/xdg-terminal-exec/${desktop}-xdg-terminals.list`
    - `/usr/share/xdg-terminal-exec/xdg-terminals.list`
- desktop entries (in `${XDG_DATA_HOME}:${XDG_DATA_DIRS}`):
  - `${HOME}/.local/share/applications/`
  - `/usr/local/share/applications/`
  - `/usr/share/applications/`

## Configuration file format

The format is a simple newline-separated list with decreasing priority.

Empty lines and lines starting with `#` are ignored, dangling whitespaces are
trimmed.

Line format:

`terminal.desktop` or `terminal.desktop:action`: marks entry for explicit
selection.

`-terminal.desktop` excludes entry from fallback selection.

`+terminal.desktop` protects entry from fallback exclusion.

Special directives for modifying behavior of implementations may be present in
config files. Directives that are not listed by this spec and are not understood
by a particular implementation should be discarded.

Directives should not contain `.desktop` substring in them. And it is
recommended to start directives with a symbol that is not valid for entry ID,
i.e. `/`.

## Priority of selecting an entry

- A list of explicitly preferred entry IDs and fallback exclusions is composed
  by taking previously unseen IDs:
  - from each dir of XDG config hierarchy in the order of decreasing priority:
    - from `${desktop}-xdg-terminals.list` files in the order of
      `$XDG_CURRENT_DESKTOP` items
    - from `xdg-terminals.list`
  - from each dir of system XDG data hierarchy in the order of decreasing
    priority:
    - from `xdg-terminal-exec/${desktop}-xdg-terminals.list` files in the order
      of `$XDG_CURRENT_DESKTOP` items
    - from `xdg-terminal-exec/xdg-terminals.list`
- Each entry from the explicit selection list is checked for applicability:
  - presense of `TerminalEmulator` category
  - validation by the same rules as in Desktop Entry Spec, except `*ShowIn`
    conditions
  - entry is discarded if it does not pass the checks
  - the first applicable entry is used
- If no applicable entry is found, fallback selection is performed from entries
  in XDG data hierarchy (except those discarded and excluded earlier). Each is
  checked for applicability:
  - presense of `TerminalEmulator` category
  - validation by the same rules as in Desktop Entry Spec, now including
    `*ShowIn` conditions
  - the first applicable entry is used
    - the order in which found entries under the same base directory are checked
      in is undefined
- If no applicable entry is found, an error is returned.

## Desktop entry for a terminal

Stock Desktop Entry for terminal emulator may be used. Command execution
argument defaults to `-e`. Key `ExecArg=` (`X-ExecArg=` while the spec is in
proposed status) can be used to override it. If the terminal accepts commands
without special argument, this key can be explicitly set to an empty value
(execution argument will be omitted). Although in this case it is recommended to
use `--` if the terminal handles it correctly.

### Additional argument keys

Implementations should expect these keys prefixed with `X-` while the spec is
in proposed status.

If argument expects a value and is defined as ending with `=`, value should be
appended to the same argument without a whitespace.

- `AppIdArg=` - argument to set `app-id` (Wayland).
- `ClassArg=` - argument to set `WM_CLASS` (X11).
- `IdFallback=` - boolean, allow fallback between `AppIdArg` and `ClassArg` if
  requested one is not supported but other one is. Default: `false`
- `TitleArg=` - argument to set window title.
- `DirArg=` - argument to set working directory.
- `HoldArg=` - argument to hold terminal open after requested command exits.

Since terminal emulators have varying set of features, any option support is
considred best effort. Whether launched terminal process waits for command to
finish or exits immediately (i.e. after sending IPC request to a master process)
is not defined by the this spec. Some IPC-using terminals provide separate
entries or
[actions](https://specifications.freedesktop.org/desktop-entry-spec/latest/extra-actions.html)
for launching separate processes without IPC.

## Syntax

```
xdg-terminal-exec [-[-]options ...] [command [arguments ...]]
```

A set of arguments each starting with `-` and located at the beginning of the
input command line is considered to be options processed by the implementation
and should always be discarded from the resulting command line, inlcuding `-e`
or any matching execution argument. Option processing should end on `--`, `-e`,
or matching execution argument.

Each option should be monolithic: as a single argument, value (if applicable)
delimited by `=`. Recognized options:

- `--app-id=`
- `--class=`
- `--id-fallback`
- `--title=`
- `--dir=`
- `--hold`

Requested options then translated into arguments according to the keys existing
in the terminal's Desktop Entry (or discarded otherwise).

If a command (with or witout its arguments) is given, and `ExecArg=` key is
not explicitly empty, then the value `ExecArg=` (defaulting to `-e`) is
appended as the next argument.

Next the command and arguments are passed as is.

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

The most taxing part of the algorithm is reading all the Desktop Entry files for
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

This feature is enabled by default and can be controlled by first encountered
`/enable_cache`|`/disable_cache` direcive in the configs or `XTE_CACHE_ENABLED`
env var (truthy or falsy value, has priority).

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
