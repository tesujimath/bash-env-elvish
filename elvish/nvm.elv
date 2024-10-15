# NVM support. Add the following to rc.elv:
#
# ```elvish
# use github.com/tesujimath/bash-env-elvish/nvm
# nvm:init
# var nvm~ = $nvm:nvm~
# ```
#
# And use the `nvm` command as you would with other shells!

use str
use path

var bash-env-elvish = (path:dir (src)[name])/bash-env-elvish

fn quote-sh {|s| put "'"(str:replace "'" "'\\''" $s)"'" }

fn load-nvm-sh-and-run {|code|
  echo ". ~/.nvm/nvm.sh\n"$code | $bash-env-elvish | eval (slurp)
}

# Initializes nvm.
fn init { load-nvm-sh-and-run '' }

# Simulates running "nvm $@args" in bash.
fn nvm {|@args|
  load-nvm-sh-and-run 'nvm '(each $quote-sh~ $args | str:join ' ')
}
