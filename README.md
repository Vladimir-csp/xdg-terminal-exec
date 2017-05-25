# xdg-terminal-exec
Proposal for XDG terminal execution utility

Terminal emulators with their exec arguments are be described by desktop entries in directories named `xdg-terminals` placed in XDG_DATA hierarchy

Preferred terminal is configured in config files named `xdg-terminals.list` placed in XDG_CONFIG hierarchy.
Format for config file is a a simple newline-separated list of desktop entries, #comments, dangling whitespaces are trimmed.

- Priority of selecting entry:
  - Read configs throughout XDG_CONFIG hierarchy.
    - in each tier `${XDG_SESSION_DESKTOP}-xdg-terminals.list` gets first priority, `xdg-terminals.list` gets second priority
    - each entry found in configs is checked for applicability and skipped if check fails.
  - If no valid entries were found in configs, every entry found in XDG_DATA hierarchy is checked in a row. Firs applicable will be used.
  - If above fails, `xterm -e`
