# bash-env

This is a Bash script `bash-env.sh` for export of Bash environment as JSON, suitable for consumption by modern shells such as Elvish and NuShell.

Adapters for [Elvish](elvish/README.md) and [NuShell](nushell/README.md) are provided for ease of use from those shells.

Source files may be arbitrarily complex Bash, including conditionals, etc.

Besides environment variables, shell variables and functions may also be exported, useful for supporting e.g. Python virtualenv activation/deactivation and Node version manager (nvm).

Any suggestions for improvements are gladly received as issues, especially pull requests for other modern shells.

## Rationale

Everyone needs Bash format environment support.  Being able to export this as JSON makes it readily available for import into any modern shell.

## Environment and Shell Variables

```
$ export C="bad value"

$ cat tests/simple.env
export A=a
export B=b
unset C
d="I am a shell variable"


$ ./bash-env.sh tests/simple.env | jq
{
  "env": {
    "B": "b",
    "A": "a",
    "C": null
  },
  "shellvars": {
    "d": "I am a shell variable"
  }
}
```

## Shell Functions

The shell function per se cannot be exported.  Rather what is exported is the *result* of invoking the shell function.

```
$ cat ./tests/shell-functions.env
export A=1
export B=1

function f2() {
        export A=2
        export B=2
        C2="I am shell variable C2"
}

function f3() {
        export A=3
        export B=3
        C3="I am shell variable C3"
}

$ ./bash-env.sh --shellfns f2,f3 ./tests/shell-functions.env | jq

{
  "env": {
    "B": "1",
    "A": "1"
  },
  "shellvars": {},
  "fn": {
    "f2": {
      "env": {
        "B": "2",
        "A": "2"
      },
      "shellvars": {
        "C2": "I am shell variable C2"
      }
    },
    "f3": {
      "env": {
        "B": "3",
        "A": "3"
      },
      "shellvars": {
        "C3": "I am shell variable C3"
      }
    }
  }
}```

## History

This started life as the [`nu_plugin_bash_env`](https://github.com/tesujimath/nu_plugin_bash_env) plugin for NuShell.  It was forked for Elvish, and then later unified.
