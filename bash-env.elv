# Bash Environment import for Elvish
use str

fn bash-env { |&shellvars=[] @args|
  var env = ""
  var n_args = (count $args)
  var comma_shellvars = (str:join , $shellvars)
  if (== $n_args 0) {
    set env = (bash-env-elvish --shellvars $comma_shellvars | slurp)
  } elif (== $n_args 1) {
    set env = (bash-env-elvish --shellvars $comma_shellvars $args[0] | slurp)
  } else {
    fail "bash-env takes zero (for stdin) or one argument (for path) only"
  }
  var eval-ns = $nil
  eval &on-end={|ns| set eval-ns = $ns} $env

  # return shellvars as a map, if any
  if (> (count $shellvars) 0) {
    put (all $shellvars | each {|shellvar|
      if (has-key $eval-ns $shellvar) {
        put [$shellvar $eval-ns[$shellvar]]
      }
    } | make-map)
  }
}
