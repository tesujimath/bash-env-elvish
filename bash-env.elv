# Bash Environment import for Elvish
# TODO support for --export
fn bash-env { |@args|
  var env = ""
  var n_args = (count $args)
  if (== $n_args 0) {
    set env = (bash-env-elvish | slurp)
  } elif (== $n_args 1) {
    set env = (bash-env-elvish $args[0] | slurp)
  } else {
    fail "bash-env takes zero (for stdin) or one argument (for path) only"
  }
  eval $env
}
