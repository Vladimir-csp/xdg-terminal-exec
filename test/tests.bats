#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/globalconfig"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/globaldata"
	export PATH="$BATS_TEST_DIRNAME/bin:$PATH"
	NOCONFIG="$BATS_TEST_DIRNAME/no-config"
	NODATA="$BATS_TEST_DIRNAME/no-data"
	XDG_TERMINAL_EXEC="$BATS_TEST_DIRNAME/../xdg-terminal-exec"
}

@test "notshowin" {
	XDG_CURRENT_DESKTOP=NODE run -0 $XDG_TERMINAL_EXEC
	[ "$output" = "notshowin" ]
}

@test "myde-term" {
	XDG_CURRENT_DESKTOP=MYDE run -0 $XDG_TERMINAL_EXEC
	[ "$output" = "myde-term" ]
}

@test "onlyshowin" {
	XDG_CURRENT_DESKTOP=MYDE2 run -0 $XDG_TERMINAL_EXEC
	[ "$output" = "onlyshowin" ]
}

@test "global-term" {
	XDG_CURRENT_DESKTOP=MYDE3 run -0 $XDG_TERMINAL_EXEC
	[ "$output" = "global-term" ]
}

@test "global-term no-config" {
	XDG_CONFIG_HOME="$NOCONFIG" run -0 $XDG_TERMINAL_EXEC
	[ "$output" = "global-term" ]
}

@test "non-listed-term" {
	XDG_CURRENT_DESKTOP=MYDE4 XDG_CONFIG_HOME="$NOCONFIG" XDG_CONFIG_DIRS="$NOCONFIG" run -0 $XDG_TERMINAL_EXEC
	[ "$output" = "non-listed-term" ]
}

@test "global-term myde4 no-config" {
	XDG_CURRENT_DESKTOP=MYDE4 XDG_CONFIG_HOME="$NOCONFIG" XDG_CONFIG_DIRS="$NOCONFIG" XDG_DATA_HOME="$NODATA" run -0 $XDG_TERMINAL_EXEC
	[ "$output" = "global-term" ]
}
