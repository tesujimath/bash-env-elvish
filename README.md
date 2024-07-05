# bash-env-elvish

This is a Bash script and Elvish module for importing Bash environment into Elvish.

Source files may be arbitrarily complex Bash, including conditionals, etc.

# Usage

```
> echo 'export A=1; export B=2; export Z=101' | bash-env
> echo $E:A $E:B $E:Z
1 2 101

> cat abc.env
export A=101
export B=102
export C="fooled ya!"

> bash-env abc.env
> echo $E:A $E:B $E:C
101 102 fooled ya!

> ssh-agent | bash-env
Agent pid 921717
> echo $E:SSH_AUTH_SOCK
/tmp/ssh-XXXXXXI4IoXr/agent.921715
```

# Installation

1. Install `bash-env-elvish` script somewhere on the PATH (or install the Nix flake).

2. Use the Elvish module `bash-env`

```
epm:install &silent-if-installed=$true github.com/tesujimath/bash-env-elvish
use github.com/tesujimath/bash-env-elvish/bash-env
```

3. (Recommended) Define a function in `rc.elv` to unwrap `bash-env` from its namespace

```
fn bash-env { |@args| bash-env:bash-env $@args }
```
