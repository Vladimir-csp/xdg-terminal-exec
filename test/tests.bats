#!/usr/bin/env bats

# TODO: Add following tests:
# Ensure that duplicates are removed

setup() {
	: "${XTE:=$BATS_TEST_DIRNAME/../xdg-terminal-exec}"
	unset XDG_CURRENT_DESKTOP
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/nothing"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/nothing"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/nothing"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/nothing"
	export PATH="$BATS_TEST_DIRNAME/bin:$PATH"
}

assert_success() {
	[ "$status" -eq 0 ] || {
		echo "status: $status" >&2
		echo "output: $output" >&2
		return 1
	}
}

assert_output() {
	expected="${*:-$(cat)}"
	[ "$output" = "$expected" ] || {
		echo "status: $status" >&2
		echo "output diff:" >&2
		diff -u <(echo "$expected") <(echo "$output") >&2
		return 1
	}
}

@test "uses xterm -e as the fallback" {
	run "$XTE" argument
	assert_success
	assert_output "xterm -e argument"
}

@test "uses globally configured entry" {
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	run "$XTE"
	assert_success
	assert_output "default terminal"
}

@test "ignores missing config directory" {
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/missing:$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	run "$XTE"
	assert_success
	assert_output "default terminal"
}

@test "ignores missing data directory" {
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/missing:$BATS_TEST_DIRNAME/data/default"
	run "$XTE"
	assert_success
	assert_output "default terminal"
}

@test "uses locally configured entry" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/default"
	run "$XTE"
	assert_success
	assert_output "default terminal"
}

@test "finds any global entry when there is no configuration" {
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	run "$XTE"
	assert_success
	assert_output "default terminal"
}

@test "uses configured exec arg" {
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/execarg"
	run "$XTE" argument
	assert_success
	assert_output "execarg terminal -- argument"
}

@test "adds default exec arg" {
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	run "$XTE" argument
	assert_success
	assert_output "default terminal -e argument"
}

@test "deals with large desktop entries" {
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/huge"
	run "$XTE"
	assert_success
	assert_output "huge terminal"
}

@test "finds any local entry when there is no configuration" {
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/default"
	run "$XTE"
	assert_success
	assert_output "default terminal"
}

@test "prefers earlier configured entry" {
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/preferred:$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/preferred:$BATS_TEST_DIRNAME/data/default"
	run "$XTE"
	assert_success
	assert_output "preferred terminal"
}

@test "prefers locally configured entry" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/preferred"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/preferred"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	run "$XTE"
	assert_success
	assert_output "preferred terminal"
}

@test "ignores hidden entry" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/hidden"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/hidden"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	run "$XTE"
	assert_success
	assert_output "default terminal"
}

@test "ignores entry when its TryExec fails" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/tryexec-fails"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/tryexec-fails"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	run "$XTE"
	assert_success
	assert_output "default terminal"
}

@test "uses desktop-specific configuration when available" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/desktop/lists"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/desktop/lists"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	export XDG_CURRENT_DESKTOP=desktop
	run "$XTE"
	assert_success
	assert_output "specific terminal"
}

@test "uses desktop-agnostic configuration when none is available" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/desktop/lists"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/desktop/lists"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	export XDG_CURRENT_DESKTOP=other
	run "$XTE"
	assert_success
	assert_output "generic terminal"
}

@test "considers entry when its OnlyShowIn matches" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/desktop/show"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/desktop/show"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	export XDG_CURRENT_DESKTOP=only
	run "$XTE"
	assert_success
	assert_output "only terminal"
}

@test "considers entry when its NotShowIn does not match" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/desktop/show"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/desktop/show"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	export XDG_CURRENT_DESKTOP=other
	run "$XTE"
	assert_success
	assert_output "not terminal"
}

@test "ignores entry when its NotShowIn matches or its OnlyShowIn does not match" {
	export XDG_CONFIG_HOME="$BATS_TEST_DIRNAME/config/desktop/show"
	export XDG_CONFIG_DIRS="$BATS_TEST_DIRNAME/config/default"
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/desktop/show"
	export XDG_DATA_DIRS="$BATS_TEST_DIRNAME/data/default"
	export XDG_CURRENT_DESKTOP=not
	run "$XTE"
	assert_success
	assert_output "generic terminal"
}

@test "quotes commands and arguments correctly" {
	export XDG_DATA_HOME="$BATS_TEST_DIRNAME/data/quoting"
	run "$XTE" and 'custom arguments' 'with
newline'
	assert_success
	assert_output <<-'EOF'
		|||quoting terminal|||
		|||with 'complex' arguments|||
		|||and \"back\\slashes\"|||
		|||-e|||
		|||and|||
		|||custom arguments|||
		|||with
		newline|||
	EOF
}
