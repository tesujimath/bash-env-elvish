# Lmod Environment Module support
# https://lmod.readthedocs.io/en/latest/
#
# Add the following to rc.elv:
#
# ```elvish
# use github.com/tesujimath/bash-env-elvish/lmod
# var module~ = $lmod:module~
# ```
#
# And use the `module` command as you would with other shells.

use github.com/tesujimath/bash-env-elvish/bash-env
var bash-env~ = $bash-env:bash-env~

fn module {|@args|
  if (has-env LMOD_CMD) {
    fn is-env-changer {|cmd|
      has-key [&load &add &try-load &try-add &del &unload &swap &sw &switch &purge &refresh &update] $cmd
    }

    # find the actual command, i.e. skipping past options
    var cmd = (keep-if {|s| !=s $s[0] -} $args | take 1)

    if (is-env-changer $cmd) {
      $E:LMOD_CMD bash $@args | bash-env
    } else {
      $E:LMOD_CMD bash $@args | bash
    }
  } else {
    fail "Environment variable LMOD_CMD is unset, is lmod installed?"
  }
}
