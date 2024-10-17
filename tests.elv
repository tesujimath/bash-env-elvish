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
    put $true
  } else {
    put $false [&doc=[&expected=$expected-env &actual=$actual-env]]
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
]

tap:run $tests | tap:status

