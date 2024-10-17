#!/usr/bin/env elvish

use github.com/tesujimath/elvish-tap/tap

use ./bash-env
var bash-env~ = $bash-env:bash-env~

fn check-env {|expected-env|
  var actual-env = [&]
  keys $expected-env | each {|k|
    var actual = (if (has-env $k) {
      get-env $k
    } else {
      put $nil
    })

    set actual-env = (assoc $actual-env $k $actual)
  }

  if (eq $actual-env $expected-env) {
    put [&ok=$true]
  } else {
    put [&ok=$false &doc=[&expected-env=$expected-env &actual-env=$actual-env]]
  }
}

fn check-shellvars {|actual expected|
  if (eq $actual $expected) {
    put [&ok=$true]
  } else {
    put [&ok=$false &doc=[&expected-shellvars=$expected &actual-shellvars=$actual]]
  }
}

var tests = [
  [&d=simple &f={
    unset-env A
    unset-env B
    set-env C 'unwanted'

    bash-env ./tests/simple.env

    check-env [
      &A=a
      &B=b
      &C=$nil
    ]
  }]

  [&d=shell-variables &f={
    unset-env A
    unset-env B
    unset-env C

    var env = (bash-env &shellvars ./tests/shell-variables.env)

    check-env [
      &B=exported
    ]

    check-shellvars $env[shellvars] [
      &A="not exported"
      &C="embedded=equals"
    ]
  }]
]

tap:run $tests | tap:status

