# Virtualenv activation for Elvish
use path

use github.com/tesujimath/bash-env-elvish/bash-env
var bash-env~ = $bash-env:bash-env~

# activate a virtualenv and return the deactivation function
fn activate {|env-path|
  var activation-path = (path:join $env-path bin activate)
  var env = (bash-env &fn=[deactivate] $activation-path)

  put $env[fn][deactivate]
}
