# xdg-terminal-exec
Proposal for XDG terminal execution utility

Terminal emulators with their exec arguments are be described by desktop entries in directories named `xdg-terminals` placed in XDG_DATA hierarchy

Preferred terminal is configured in config files named `xdg-terminals.list` placed in XDG_CONFIG hierarchy.
Format for config file is a a simple newline-separated list of desktop entries. #Comments, dangling whitespaces are trimmed.

## Priority of selecting entry:
  - Read configs throughout XDG_CONFIG hierarchy.
    - in each tier `${XDG_SESSION_DESKTOP}-xdg-terminals.list` gets first priority, `xdg-terminals.list` gets second priority
    - each entry found in configs is checked for applicability (same rules as in Desktop Entry Spec) and is skipped on failure.
  - If no valid entries were found among those marked in configs, every entry found in XDG_DATA hierarchy is checked in a row. First applicable will be used.
  - If all of the above fails, `xterm -e`

## syntax
```
xdg-terminal-exec command arguments
```
Run with `DEBUG=1` to see verbose messages to stderr.

## limitations
There is no mechanism for handling special quoting and arguments/strings that may be required for some terminals. Argument array is transmitted in the most preservable way possible: `"$@"`

At least when using xterm, command `xdg-terminal-exec nano "some file with spaces"\ and\ unquoted\ spaces second\ file` launches nano editing two files named `some file with spaces and unquoted spaces` and `second file`. And IMHO that is the golden standard, any terminal that fails to do so should be bugreported.
