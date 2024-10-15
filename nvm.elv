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

use github.com/tesujimath/bash-env-elvish/bash-env
var bash-env~ = $bash-env:bash-env~

fn quote-sh {|s| put "'"(str:replace "'" "'\\''" $s)"'" }

fn load-nvm-sh-and-run {|code|
  echo ". ~/.nvm/nvm.sh\n"$code | bash-env
}

# Initializes nvm.
fn init { load-nvm-sh-and-run '' }

# Simulates running "nvm $@args" in bash.
fn nvm {|@args|
  load-nvm-sh-and-run 'nvm '(each $quote-sh~ $args | str:join ' ')
}
