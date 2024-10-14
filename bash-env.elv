# Bash Environment import for Elvish
use str

fn bash-env { |&shellvars=[] @args|
  var n_args = (count $args)
  var comma_shellvars = (str:join , $shellvars)
  var result = (if (== $n_args 0) {
    put (bash-env.sh --shellvars $comma_shellvars | from-json)
  } elif (== $n_args 1) {
    put (bash-env.sh --shellvars $comma_shellvars $args[0] | from-json)
  } else {
    fail "bash-env takes zero (for stdin) or one argument (for path) only"
  })

  keys $result[env] | each {|k|
    var v = $result[env][$k]
    if (eq $v $nil) {
      unset-env $k
    } else {
      set-env $k $result[env][$k]
    }
  }

  put $result[shellvars]
}
