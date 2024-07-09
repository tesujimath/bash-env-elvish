# bash-env-elvish

This is a Bash script `bash-env-elvish` and Elvish modules `bash-env` and `virtualenv` for:

- importing Bash environment into Elvish
- extracting Bash style shell variables from source files like `/etc/os-release`
- activating/deactivating Python virtualenv

Source files may be arbitrarily complex Bash, including conditionals, etc.

# Usage

## bash-env
```
> echo 'export A=1; export B=2; export Z=101' | bash-env:bash-env
> echo $E:A $E:B $E:Z
1 2 101

> cat abc.env
export A=101
export B=102
export C="fooled ya!"

> bash-env:bash-env abc.env
> echo $E:A $E:B $E:C
101 102 fooled ya!

> ssh-agent | bash-env:bash_env
Agent pid 921717
> echo $E:SSH_AUTH_SOCK
/tmp/ssh-XXXXXXI4IoXr/agent.921715

> egrep '(ID|NAME)=' /etc/os-release
BUILD_ID="24.11.20240531.57610d2"
ID=nixos
IMAGE_ID=""
NAME=NixOS
PRETTY_NAME="NixOS 24.11 (Vicuña)"
VERSION_CODENAME="vicuña"
VERSION_ID="24.11"
> bash-env:bash-env &shellvars=[ID IMAGE_ID NAME SOMETHING_ELSE] /etc/os-release
▶ [&ID=nixos &IMAGE_ID='' &NAME=NixOS]
```

## virtualenv

```
> var deactivate~ = (virtualenv:activate ~/virtualenvs/beancount-python-lima)
(beancount-python-lima) pip list
Package               Version
--------------------- -------
beancount-parser-lima 0.6.0
pip                   24.0
setuptools            69.1.0
wheel                 0.42.0

(beancount-python-lima) deactivate
> pip list
Exception: exec: "pip": executable file not found in $PATH
  [tty 4]:1:1-8: pip list
```

# Installation

1. Install `bash-env-elvish` script somewhere on the PATH (or install the Nix flake).

2. Use the Elvish modules `bash-env` and/or `virtualenv`

```
epm:install &silent-if-installed=$true github.com/tesujimath/bash-env-elvish
use github.com/tesujimath/bash-env-elvish/bash-env
use github.com/tesujimath/bash-env-elvish/virtualenv
```

3. (Optional) Define a function in `rc.elv` to unwrap `bash-env` from its namespace

```
fn bash-env { |&shellvars=[] @args| bash-env:bash-env &shellvars=$shellvars $@args }
```

# Improvements

1. Virtualenv deactivation is not terribly ergonomic.  There may be a more Elven way to do this.

2. There may be a better way to import these functions into the REPL.

Any suggestions for improvements are gladly received as issues.
