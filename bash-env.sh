#!/usr/bin/env bash
#
# Copyright 2024 Simon Guest
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the “Software”), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, subl# icense, and/or sell copies of the
# Software, and to permit persons to whom the Software is furnished to
# do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

shopt -s extglob

function capture() {
    local -n _capture_env="$1"
    local -n _capture_shellvars="$2"
    local _name _value
    local -A _omit_shellvars=([_value]=X [BASH_LINENO]=X)

    # environment variables
    while IFS='=' read -r -d '' _name _value; do
        _capture_env["$_name"]="${_value}"
    done < <(env -0)

    # shellvars
    for _name in $(
        set -o posix
        set | sed -n -e '/^[a-zA-Z_][a-zA-Z_0-9]*=/s/=.*$//p'
        set +o posix
    ); do
        if test -v "$_name" -a ! "${_capture_env[$_name]+EXISTS}" -a ! "${_omit_shellvars[$_name]+EXISTS}"; then
            _capture_shellvars["$_name"]="${!_name}"
        fi
    done
}

function emit_error() {
    local _msg
    _msg="$1"
    jq -c <<EOF
{
  "error": "$_msg"
}
EOF
}

function emit_error_exit() {
    emit_error "$1"
    exit 1
}

function emit_value() {
    # jq -R produces nothing on empty input, but we want ""
    if test -n "$1"; then
        echo -n "$1" | jq -R
    else
        echo -n '""'
    fi
}

function emit() {
    local _name
    local -a _names
    local _comma=""
    local _sep="$1"
    local _tag="$2"
    local -n _emit_previous="$3"
    local -n _emit_current="$4"

    echo -n "$_sep\"$_tag\":{"

    # changes
    _names=("${!_emit_current[@]}")
    for _name in "${_names[@]}"; do
        if test "${_emit_current[$_name]}" != "${_emit_previous[$_name]}"; then
            if [[ "$_name" != BASH_FUNC_* ]]; then
                echo -n "${_comma}\"$_name\":"
                emit_value "${_emit_current[$_name]}"
                _comma=","
            fi
        fi
    done

    # unset
    for _name in "${!_emit_previous[@]}"; do
        if test ! -v "$_name"; then
            if [[ "$_name" != BASH_FUNC_* ]]; then
                echo -n "${_comma}\"$_name\":null"
                _comma=","
            fi
        fi
    done

    echo -n "}"
}

function eval_or_source() {
    local _source _path
    _path="$1"

    if test -n "$_path"; then
        # source from file if specified

        if test ! -r "$_path"; then
            emit_error_exit "no such file '$_path'"
        fi

        # ShellCheck can't cope with sourcing from an unknown path
        # shellcheck disable=SC1090
        if ! source "$_path" >&2; then
            emit_error_exit "failed to load environment from '$_path'"
        fi
    else
        # otherwise eval from stdin
        _source=$(</dev/stdin)
        if ! eval "$_source" >&2; then
            emit_error_exit "failed to load environment from stdin"
        fi
    fi
}

function get_args() {
    local -n _opt_path="$1"
    local -n _opt_shellfn_names="$2"
    shift 2

    # process args
    while test -n "$1"; do
        case "$1" in
        --shellfns)
            test -z "$2" && {
                bad_usage "--shellfns requires comma-separated list of function names"
                exit 1
            }
            mapfile -td, _opt_shellfn_names <<<"$2,"
            unset '_opt_shellfn_names[-1]'
            shift
            ;;
        -*)
            bad_usage "unexpected option: $1"
            exit 1
            ;;
        *)
            test -n "$_opt_path" && {
                bad_usage "repeated path $_opt_path"
                exit 1
            }
            _opt_path="$1"
            ;;
        esac
        shift
    done
}

function main() {
    local _path _fn
    declare -a _shellfn_names

    get_args _path _shellfn_names "$@"

    declare -A _env_previous
    declare -A _env_current
    declare -A _shellvars_previous
    declare -A _shellvars_current

    capture _env_previous _shellvars_previous
    eval_or_source "$_path"
    capture _env_current _shellvars_current

    emit "{" env _env_previous _env_current
    emit "," shellvars _shellvars_previous _shellvars_current

    test "${#_shellfn_names[@]}" -gt 0 && {
        echo ",\"fn\":{"
    }

    local _fn_comma=""
    for _fn in "${_shellfn_names[@]}"; do
        capture _env_previous _shellvars_previous
        # execute the function
        "$_fn"
        capture _env_current _shellvars_current

        echo "$_fn_comma\"$_fn\":"
        emit "{" env _env_previous _env_current
        emit "," shellvars _shellvars_previous _shellvars_current
        echo "}"
        _fn_comma=","
    done

    test "${#_shellfn_names[@]}" -gt 0 && {
        echo "}"
    }

    echo "}"
}

function bad_usage() {
    test -n "$1" && echo >&2 "bash-env.sh: $1"
    echo >&2 "usage: bash-env.sh [--shellfns <comma-separated-function-names>] [source]"
}

main "$@"
