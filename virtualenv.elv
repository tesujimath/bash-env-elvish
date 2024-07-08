# Virtualenv activation for Elvish
use path
use github.com/tesujimath/bash-env-elvish/bash-env

# activate a virtualenv and return the deactivation function
fn activate { |env-path|
  var activation-path = (path:join $env-path bin activate)
  var env = (bash-env-elvish --shellfns deactivate $activation-path | slurp)
  var eval-ns = $nil
  eval &on-end={|ns| set eval-ns = $ns} $env

  var saved-prompt = $edit:prompt
  set edit:prompt = { print $E:PS1 }
  put { $eval-ns[deactivate~] ; set edit:prompt = $saved-prompt }
}
