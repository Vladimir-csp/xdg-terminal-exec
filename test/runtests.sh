#!/bin/sh

CURRENT_DIR=$(dirname -- "$(readlink -f -- "$0")")
export XDG_CONFIG_HOME="$CURRENT_DIR/config"
export XDG_CONFIG_DIRS="$CURRENT_DIR/globalconfig"
export XDG_DATA_HOME="$CURRENT_DIR/data"
export XDG_DATA_DIRS="$CURRENT_DIR/globaldata"
export PATH="$CURRENT_DIR/bin:$PATH"

XDG_TERMINAL_EXEC="sh $CURRENT_DIR/../xdg-terminal-exec"
NOCONFIG="$CURRENT_DIR/no-config"
NODATA="$CURRENT_DIR/no-data"

compare_result()
{
	RESULT="$(cat)"
	EXPECTED="$1"
	
	if [ "$RESULT" != "$EXPECTED" ]
	then
		echo "Failed test \"$RESULT\" != \"$EXPECTED\""
	fi
}

XDG_CURRENT_DESKTOP=NODE $XDG_TERMINAL_EXEC |
compare_result "notshowin"

XDG_CURRENT_DESKTOP=MYDE $XDG_TERMINAL_EXEC |
compare_result "myde-term"

XDG_CURRENT_DESKTOP=MYDE2 $XDG_TERMINAL_EXEC |
compare_result "onlyshowin"

XDG_CURRENT_DESKTOP=MYDE3 $XDG_TERMINAL_EXEC |
compare_result "global-term"

XDG_CONFIG_HOME="$CURRENT_DIR/no-config" $XDG_TERMINAL_EXEC |
compare_result "global-term"

XDG_CURRENT_DESKTOP=MYDE4 XDG_CONFIG_HOME="$NOCONFIG" XDG_CONFIG_DIRS="$NOCONFIG" $XDG_TERMINAL_EXEC |
compare_result "non-listed-term"

XDG_CURRENT_DESKTOP=MYDE4 XDG_CONFIG_HOME="$NOCONFIG" XDG_CONFIG_DIRS="$NOCONFIG" XDG_DATA_HOME="$NODATA" $XDG_TERMINAL_EXEC |
compare_result "global-term"
