#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

setup() {
	: "${XTE:=$BATS_TEST_DIRNAME/../xdg-terminal-exec}"
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/nothing"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/nothing"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/nothing"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/nothing"
}

xte() {
	run -0 $XTE
}

assert_output() {
	[ "$output" = "$*" ]
}

@test "uses globally configured entry" {
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	xte
	assert_output "default terminal"
}

@test "uses locally configured entry" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/default"
	xte
	assert_output "default terminal"
}

@test "finds any global entry when there is no configuration" {
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	xte
	assert_output "default terminal"
}

@test "deals with large desktop entries" {
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/huge"
	xte
	assert_output "huge terminal"
}

@test "finds any local entry when there is no configuration" {
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/default"
	xte
	assert_output "default terminal"
}

@test "prefers earlier configured entry" {
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/preferred:$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/preferred:$BATS_TEST_DIRNAME/data/default"
	xte
	assert_output "preferred terminal"
}

@test "prefers locally configured entry" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/preferred"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/preferred"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	xte
	assert_output "preferred terminal"
}

@test "ignores hidden entry" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/hidden"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/hidden"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	xte
	assert_output "default terminal"
}

@test "ignores entry when its TryExec fails" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/tryexec-fails"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/tryexec-fails"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	xte
	assert_output "default terminal"
}

@test "uses desktop-specific configuration when available" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/desktop/lists"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/desktop/lists"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	export XDG_CURRENT_DESKTOP=desktop
	xte
	assert_output "specific terminal"
}

@test "uses desktop-agnostic configuration when none is available" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/desktop/lists"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/desktop/lists"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	export XDG_CURRENT_DESKTOP=other
	xte
	assert_output "generic terminal"
}

@test "considers entry when its OnlyShowIn matches" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/desktop/show"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/desktop/show"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	export XDG_CURRENT_DESKTOP=only
	xte
	assert_output "only terminal"
}

@test "considers entry when its NotShowIn does not match" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/desktop/show"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/desktop/show"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	export XDG_CURRENT_DESKTOP=other
	xte
	assert_output "not terminal"
}

@test "ignores entry when its NotShowIn matches or its OnlyShowIn does not match" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/desktop/show"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/desktop/show"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	export XDG_CURRENT_DESKTOP=not
	xte
	assert_output "generic terminal"
}
