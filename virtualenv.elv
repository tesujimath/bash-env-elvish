# Virtualenv activation for Elvish
use path
use github.com/tesujimath/bash-env-elvish/bash-env

fn activate { |env-path|
  var activation-path = (path:join $env-path bin activate)
  bash-env:bash-env $activation-path

  set edit:prompt = { print $E:PS1 }
}
