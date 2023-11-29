# xdg-terminal-exec

Proposal for XDG terminal execution utility and default terminal specification.

The configuration spec is crafted in image of [mime-apps-spec](https://specifications.freedesktop.org/mime-apps-spec/latest/ar01s02.html)
using different names in similar structure, governed by [basedir-spec](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html).

Terminal emulators (with their exec arguments) are described by Desktop Entries.
Either stock entries can be used (located in `applications` subdirs of XDG data hierarchy, marked by `TerminalEmulator` category),
or separate entries placed in `xdg-terminals` subdirs of XDG data hierarchy.
Selection mechanism is described below.

Preferred terminals are configured by listing their [entry IDs](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s02.html#desktop-file-id)
in config files named `${desktop}-xdg-terminals.list` or `xdg-terminals.list` placed in XDG config hierarchy.
The format is a simple newline-separated list.

Optionally an entry ID can be suffixed with [action ID](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s11.html), delimited by `:`.
`#Comments` and dangling whitespaces are trimmed.

Default paths are resolved into:

- config files (in `${XDG_CONFIG_HOME}:${XDG_CONFIG_DIRS}`):
  - `$HOME/.config/${desktop}-xdg-terminals.list`
  - `$HOME/.config/xdg-terminals.list`
  - `/etc/xdg/${desktop}-xdg-terminals.list`
  - `/etc/xdg/xdg-terminals.list`
  - `/usr/etc/xdg/${desktop}-xdg-terminals.list`
  - `/usr/etc/xdg/xdg-terminals.list`
- data (in `${XDG_DATA_HOME}:${XDG_DATA_DIRS}`):
  - stock applications:
    - `$HOME/.local/share/applications/`
    - `/usr/local/share/applications`
    - `/usr/share/applications`
  - separate xdg-terminals:
    - `$HOME/.local/share/xdg-terminals/`
    - `/usr/local/share/xdg-terminals`
    - `/usr/share/xdg-terminals`

Where `${desktop}` is a lowercased string that can be matched (case-insensitive) against items of `$XDG_CURRENT_DESKTOP`
(a colon-separated list of names for the current DE).

Selection of data subdirectory is determined by (ordered by decreasing priority):

- environment variable `XTE_STOCK_TERMINALS` (`true` or `false`)
- the first encountered directive `use_stock_applications` or `use_xdg_terminals` in `*xdg-terminals.list` configs.
- use stock entries by default.

## Priority of selecting an entry

- A list of explicitly preferred entry IDs is composed by taking previously unseen IDs:
  - from each dir of XDG config hierarchy in the order of decreasing priority
    - from `${desktop}-xdg-terminals.list` files in the order of `$XDG_CURRENT_DESKTOP` items
    - from `xdg-terminals.list`
- Each entry from the resulting list is checked for applicability:
  - presense of `TerminalEmulator` category if using stock `applications` data subdirs
  - validation by the same rules as in Desktop Entry Spec, except `*ShowIn` conditions
  - entry is discarded if it does not pass the checks
  - the first applicable entry is used
- If no applicable entry is found, each entry from XDG data hierarchy is checked for applicability:
  - presense of `TerminalEmulator` category if using stock `applications` data subdirs
  - validation by the same rules as in Desktop Entry Spec, now including `*ShowIn` conditions
  - the first applicable entry is used
- If no applicable entry is found, an error is returned.

## Desktop entry for terminal

Stock desktop entry for terminal emulator may be used. Command execution argument defaults to `-e`.
Key `X-ExecArg=` can be used to override it or omit by explicitly setting to an empty value.

Whether launched terminal process waits for command to finish or exits immediately (i.e. after sending IPC request to a master process)
is not defined by the this spec. Selected terminal emulator with requested arguments is executed as is.
Some IPC-using terminals provide separate entries or [actions](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s11.html)
for launching separate processes without IPC.

Specific action can be selected by appending colon-delimited action ID to entry ID in `*xdg-terminals.list` configs
(`entry-id.desktop:action-id`).

## Syntax

```
xdg-terminal-exec [command [arguments]]
```

If run without any arguments, only the terminal itself (value of `Exec=`) is launched.

If a command (with or witout its arguments) is given, then values of both `Exec=` and `X-ExecArg=` (if not explicitly empty) are used,
along with provided command and arguments.

Run with `DEBUG=1` to see verbose messages to stderr.

## Limitations

There is no mechanism for handling special quoting and arguments/strings that may be required for some terminals.
Argument array given on command line is transmitted as is.

At least when using xterm, this command:

```
xdg-terminal-exec nano "some file with spaces"\ and\ unquoted\ spaces second\ file
```

launches `nano` editing two files named `some file with spaces and unquoted spaces` and `second file`.
And IMHO that is the golden standard, any terminal that fails to do so should be bugreported.

Some examples of compliant terminals: xterm, alacritty, kitty, foot, qterminal

Terminals that use `-e` but mangle arguments: sakura

# Notes on this shell implementation and performance

The shell code itself is quite optimized and fast, especially when using a slick `sh` implementation like `dash`.

The most taxing part of the algorithm is reading all the desktop entry files for parsing to find a terminal among them.

Having a valid entry specified in `*xdg-terminals.list` speeds up the process significantly, shifting the bottleneck to
composing the list of desktop entries.

If storage sluggishness makes even this process too slow, swithcing to `xdg-terminals` data subdirs and populating them
with only select few entries should speed things up even more.
