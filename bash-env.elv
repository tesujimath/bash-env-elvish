# Bash Environment import for Elvish
use str

fn bash-env { |&shellvars=$nil &fn=[] @args|
  var n_args = (count $args)
  var comma_shellfns = (str:join , $fn)
  var raw = (if (== $n_args 0) {
    put (bash-env.sh --shellfns $comma_shellfns | from-json)
  } elif (== $n_args 1) {
    put (bash-env.sh --shellfns $comma_shellfns $args[0] | from-json)
  } else {
    fail "bash-env takes zero (for stdin) or one argument (for path) only"
  })

  keys $raw[env] | each {|k|
    var v = $raw[env][$k]
    if (eq $v $nil) {
      unset-env $k
    } else {
      set-env $k $raw[env][$k]
    }
  }

  # output only if we have shellvars or fn
  if (or (not-eq $shellvars $nil) (not-eq $fn [])) {
    {
      if (not-eq $shellvars $nil) { put [shellvars $raw[shellvars]] }
      if (not-eq $fn []) { put [fn $raw[fn]] }
    } | make-map
  }
}
