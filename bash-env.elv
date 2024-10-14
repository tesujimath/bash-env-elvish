# Bash Environment import for Elvish
use str

fn bash-env { |&shellvars=$nil &fn=[] @path|
  if (> (count $path) 1) {
    fail "bash-env takes zero (for stdin) or one argument (for path) only"
  }

  var args = ({
    if (not-eq $fn []) {
      put --shellfns (str:join , $fn)
    }

    put (all $path)
  } | put [(all)])

  var raw = (bash-env.sh (all $args) | from-json)

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
