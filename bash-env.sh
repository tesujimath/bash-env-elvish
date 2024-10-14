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

function send_error() {
    echo >&2 "ERROR: $1"
}

function capture() {
    local -n _capture_env="$1"
    local -n _capture_shellvar_names="$2"
    local -n _capture_shellvars="$3"
    local _name _value

    # environment variables
    while IFS='=' read -r -d '' _name _value; do
        _capture_env["$_name"]="${_value}"
    done < <(env -0)

    # shellvars
    for _name in "${_capture_shellvar_names[@]}"; do
        if test -v "$_name" -a ! "${_capture_env[$_name]+EXISTS}"; then
            _capture_shellvars["$_name"]="${!_name}"
        fi
    done
}

function emit() {
    local _name
    local _emit_tag="$1"
    local -n _emit_previous="$2"
    local -n _emit_current="$3"

    # changes
    for _name in "${!_emit_current[@]}"; do
        if test "${_emit_current[$_name]}" != "${_emit_previous[$_name]}"; then
            if [[ "$_name" != BASH_FUNC_* ]]; then
                # ShellCheck is confused here I think
                # shellcheck disable=SC2004
                echo "$_emit_tag $_name '${_emit_current[$_name]//\'/\'\'}'"
            fi
        fi
    done

    # unset
    for _name in "${!_emit_previous[@]}"; do
        if test ! -v "$_name"; then
            if [[ "$_name" != BASH_FUNC_* ]]; then
                echo "un$_emit_tag  $_name"
            fi
        fi
    done
}

function eval_or_source() {
    local _source _path
    _path="$1"

    if test -n "$_path"; then
        # source from file if specified

        if test ! -r "$_path"; then
            send_error "no such file '$_path'"
            return
        fi

        # ShellCheck can't cope with sourcing from an unknown path
        # shellcheck disable=SC1090
        if ! source "$_path" >&2; then
            send_error "failed to load environment from '$_path'"
            return 1
        fi
    else
        # otherwise eval from stdin
        _source=$(</dev/stdin)
        if ! eval "$_source" >&2; then
            send_error "failed to load environment from stdin"
            return 1
        fi
    fi
}

function get_args() {
    local -n _opt_path="$1"
    local -n _opt_shellvar_names="$2"
    local -n _opt_shellfn_names="$3"
    shift 3

    # process args
    while test -n "$1"; do
        case "$1" in
        --shellvars)
            test -n "$2" && {
                mapfile -td, _opt_shellvar_names <<<"$2,"
                unset '_opt_shellvar_names[-1]'
            }
            shift
            ;;
        --shellfns)
            test -n "$2" && {
                mapfile -td, _opt_shellfn_names <<<"$2,"
                unset '_opt_shellfn_names[-1]'
            }
            shift
            ;;
        -*)
            bad_usage "unexpected option: $1"
            exit 1
            ;;
        *)
            test -n "$_opt_path" && {
                bad_usage
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
    declare -a _shellvar_names
    declare -a _shellfn_names

    get_args _path _shellvar_names _shellfn_names "$@"

    declare -A _env_previous
    declare -A _env_current
    declare -A _shellvars_previous
    declare -A _shellvars_current

    capture _env_previous _shellvar_names _shellvars_previous
    eval_or_source "$_path"
    capture _env_current _shellvar_names _shellvars_current

    emit set-env _env_previous _env_current
    emit set _shellvars_previous _shellvars_current

    for _fn in "${_shellfn_names[@]}"; do
        capture _env_previous _shellvar_names _shellvars_previous
        # execute the function
        "$_fn"
        capture _env_current _shellvar_names _shellvars_current

        echo "fn $_fn {"
        emit set-env _env_previous _env_current
        emit set _shellvars_previous _shellvars_current
        echo "}"
    done
}

function bad_usage() {
    echo >&2 "usage: bash-env.sh [--shellvars <comma-separated-variables>] [--shellfns <comma-separated-function-names>] [source]"
}

main "$@"
