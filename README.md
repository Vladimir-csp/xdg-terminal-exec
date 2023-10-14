# xdg-terminal-exec
Proposal for XDG terminal execution utility and default terminal specification.

The configuration spec is crafted in image of [mime-apps-spec](https://specifications.freedesktop.org/mime-apps-spec/latest/ar01s02.html) using different names in similar structure, governed by [basedir-spec](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html).

Terminal emulators with their exec arguments are described by desktop entries placed in directories named `xdg-terminals` provided via XDG_DATA hierarchy.

Preferred terminals are configured in config files named `xdg-terminals.list` provided via XDG_CONFIG hierarchy.
Format for config file is a a simple newline-separated list of desktop entries. #Comments and dangling whitespaces are trimmed.

Default paths are resolved into:

- configs
  - `$HOME/.config/$desktop-xdg-terminals.list`
  - `$HOME/.config/xdg-terminals.list`
  - `/etc/xdg/$desktop-xdg-terminals.list`
  - `/etc/xdg/xdg-terminals.list`
  - `/usr/etc/xdg/$desktop-xdg-terminals.list`
  - `/usr/etc/xdg/xdg-terminals.list`
- data
  - `$HOME/.local/share/xdg-terminals/`
  - `/usr/local/share/xdg-terminals`
  - `/usr/share/xdg-terminals`

Where `$desktop` is a lowercased string derived from `$XDG_CURRENT_DESKTOP`.
If `$XDG_CURRENT_DESKTOP` is set then it contains a colon-separated list of names for the current DE.

Alternative experimental mode enabled by setting `XTE_STOCK_TERMINALS=true` will use standard entries in `applications` subdirs
and filter terminals by `TerminalEmulator` category.

## Priority of selecting entry:
  - Read configs throughout XDG_CONFIG hierarchy.
    - in each tier `$desktop-xdg-terminals.list` gets first priority, `xdg-terminals.list` gets second priority
    - each entry found in configs is checked for applicability (same rules as in Desktop Entry Spec) and is skipped on failure.
  - If no valid entries were found among those marked in configs, every entry found in XDG_DATA hierarchy is checked in a row. First applicable will be used.
  - If all of the above fails, `xterm` and `-e` are used.

## Desktop entry for terminal
When defining terminals usual desktop entries may be used. The only addition is the key `X-ExecArg` which defines the execution argument for the terminal emulator.
It defaults to `-e` if unset, but may be specifically set to an empty string.
With this behavior stock entries for terminals that use `-e` as execution argument may be used unaltered.

## syntax
```
xdg-terminal-exec [command [arguments]]
```
If run without any arguments, only the terminal itself (value of `Exec=`) will be launched.
If command and its arguments are given, then values of both `Exec=` and `X-ExecArg=` will be used.
Run with `DEBUG=1` to see verbose messages to stderr.

## limitations
There is no mechanism for handling special quoting and arguments/strings that may be required for some terminals.
Argument array is transmitted as is.

At least when using xterm, command:
```
xdg-terminal-exec nano "some file with spaces"\ and\ unquoted\ spaces second\ file
```
launches nano editing two files named `some file with spaces and unquoted spaces` and `second file`.
And IMHO that is the golden standard, any terminal that fails to do so should be bugreported.
