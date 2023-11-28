# xdg-terminal-exec

Proposal for XDG terminal execution utility and default terminal specification.

The configuration spec is crafted in image of [mime-apps-spec](https://specifications.freedesktop.org/mime-apps-spec/latest/ar01s02.html) using different names in similar structure, governed by [basedir-spec](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html).

Terminal emulators with their exec arguments are described by desktop entries.
Either stock entries can be used (marked by `TerminalEmulator` category),
or separate entries placed in directories named `xdg-terminals` provided via XDG_DATA hierarchy. Selection mechanism is described below.

Preferred terminals are configured in config files named `xdg-terminals.list` provided via XDG_CONFIG hierarchy.
Format for config file is a a simple newline-separated list of desktop [entry IDs](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s02.html#desktop-file-id)
with optional [action ID](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s11.html) delimited by `:`.
`#Comments` and dangling whitespaces are trimmed.

Default paths are resolved into:

- configs
  - `$HOME/.config/$desktop-xdg-terminals.list`
  - `$HOME/.config/xdg-terminals.list`
  - `/etc/xdg/$desktop-xdg-terminals.list`
  - `/etc/xdg/xdg-terminals.list`
  - `/usr/etc/xdg/$desktop-xdg-terminals.list`
  - `/usr/etc/xdg/xdg-terminals.list`
- data (stock)
  - `$HOME/.local/share/applications/`
  - `/usr/local/share/applications`
  - `/usr/share/applications`
- data (separate)
  - `$HOME/.local/share/xdg-terminals/`
  - `/usr/local/share/xdg-terminals`
  - `/usr/share/xdg-terminals`

Where `$desktop` is a lowercased string derived from `$XDG_CURRENT_DESKTOP`.
If `$XDG_CURRENT_DESKTOP` is set then it contains a colon-separated list of names for the current DE.

Data source directory can be controlled with the `XTE_STOCK_TERMINALS` environment variable or by special lines in config files.
The first encountered `use_stock_applications` or `use_xdg_terminals` line in configs is equivalent to setting `XTE_STOCK_TERMINALS` to true or false respectively.
Setting the `XTE_STOCK_TERMINALS` variable takes priority over lines read from configs.
The default value of `XTE_STOCK_TERMINALS` is currently `false`, but will most likely be changed to `true` in the future.

## Priority of selecting entry

  - Read configs throughout XDG_CONFIG hierarchy.
    - in each tier `$desktop-xdg-terminals.list` gets first priority, `xdg-terminals.list` gets second priority
    - each entry found in configs is checked for applicability:
      - same rules as in Desktop Entry Spec except *ShowIn conditions
      - entry is discarded if it does not pass the tests
      - the first applicable entry is used
  - If no applicable entry is found, every entry in XDG_DATA hierarchy is checked in a row:
    - presense of `TerminalEmulator` category if using stock 'applications' data subdirs
    - same rules as in Desktop Entry Spec, now including *ShowIn conditions
    - the first applicable entry is used
  - If no applicable entry is found, error is returned.

## Desktop entry for terminal

Stock desktop entry for terminal emulator may be used. Command execution argument defaults to `-e`.
Key `X-ExecArg=` can be used to override it (or omit by explicitly setting empty) if terminal emulator uses a different argument.

Whether launched terminal process waits for command to finish or exits immediately (i.e. after sending IPC request to a master process)
is not defined by the this spec. Selected terminal emulator with requested arguments is executed as is.
Some IPC-using terminals provide separate entries or [actions](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s11.html) for launching separate processes without IPC.

Specific action can be selected by appending colon-delimited action ID to entry ID in `xdg-terminals.list` config
(`entry-id.desktop:action-id`).

## Syntax

```
xdg-terminal-exec [command [arguments]]
```
If run without any arguments, only the terminal itself (value of `Exec=`) will be launched.
If command and its arguments are given, then values of both `Exec=` and `X-ExecArg=` will be used.
Run with `DEBUG=1` to see verbose messages to stderr.

## Limitations

There is no mechanism for handling special quoting and arguments/strings that may be required for some terminals.
Argument array given on command line is transmitted as is.

At least when using xterm, command:
```
xdg-terminal-exec nano "some file with spaces"\ and\ unquoted\ spaces second\ file
```
launches nano editing two files named `some file with spaces and unquoted spaces` and `second file`.
And IMHO that is the golden standard, any terminal that fails to do so should be bugreported.

Some examples of compliant terminals: xterm, alacritty, kitty, foot, qterminal

Terminals that use `-e` but mangle arguments: sakura
