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

  tap:assert-expected $actual-env $expected-env
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

  [&d=simple-stdin &f={
    unset-env A
    unset-env B
    set-env C 'unwanted'

    cat ./tests/simple.env | bash-env

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

    var actual = (bash-env &shellvars ./tests/shell-variables.env)

    check-env [
      &B=exported
    ]

    tap:assert-expected $actual[shellvars] [
      &A="not exported"
      &C="embedded=equals"
    ]
  }]

  [&d=shell-functions &f={
    unset-env A
    unset-env B
    unset-env C2
    unset-env C3

    var actual = (bash-env &fn=[f2 f3] ./tests/shell-functions.env)

    check-env [
      &A=1
      &B=1
    ]

    # check the result of invoking f2
    $actual[fn][f2]
    check-env [
      &A=2
      &B=2
    ]

    # check the result of invoking f3
    $actual[fn][f3]
    check-env [
      &A=3
      &B=3
    ]
  }]
]

tap:run $tests | tap:status

