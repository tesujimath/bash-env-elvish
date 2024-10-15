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

  var raw = (var ok = ?(bash-env-json (all $args) | from-json))
  if $ok {
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

        if (not-eq $fn []) {
            # build a map of functions which set the environment accordingly
            var functions = (keys $raw[fn] | each {|name|
                var named_f = {
                  for k (keys $raw[fn][$name][env] | put [(all)]) {
                    var v = $raw[fn][$name][env][$k]
                    if (eq $v $nil) {
                      unset-env $k
                    } else {
                      set-env $k $v
                    }
                  }
                }
                put [$name $named_f]
            } | make-map)
            put [fn $functions]
        }
      } | make-map
    }
  } else {
    if (has-key $raw error) {
      fail $raw[error]
    } else {
      fail $ok
    }
  }
}
