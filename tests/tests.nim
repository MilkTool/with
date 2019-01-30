import unittest
import with

type

  Foo = object
    first: int
    second: string
    third: float

  Bar = ref object
    alpha: int
    beta: string
    fn: proc(v: int): int

  Sub = object
    foo: Foo

suite "with":

  test "basic object":
    var foo = Foo(first: 1, second: "two", third: 3.0)
    with foo:
      check first == 1
      check second == "two"
      check third == 3.0

  test "basic tuple":
    var foo = (first: 1, second: "two")
    with foo:
      check first == 1
      check second == "two"

  test "case insensitive":
    var foo = Foo(first: 1, second: "two", third: 3.0)
    with foo:
      check first == 1
      check fiRSt == 1
      check fi_rst == 1

  test "nested 'with'":
    var foo = Foo(first: 1, second: "two", third: 3.0)
    var bar = Bar(alpha: 10, beta: "twenty")
    with foo:
      check first == 1
      check second == "two"
      with bar:
        check third == 3.0
        check alpha == 10
        check beta == "twenty"

  test "multiple 'with'":
    var foo = Foo(first: 1, second: "two", third: 3.0)
    var bar = Bar(alpha: 10, beta: "twenty")
    with (foo,bar):
      check first == 1
      check second == "two"
      check third == 3.0
      check alpha == 10
      check beta == "twenty"

  test "dot expressions":
    var sub = Sub(foo: Foo(first: 1))
    with sub:
      check foo.first == 1

  test "more complex AST":
    var foo = Foo(first: 1, second: "two", third: 3.0)
    with foo:
      proc test() =
        check first == 1
        if true:
          check second == "two"
      test()
      for i in 1..10:
        check third == 3.0

  test "skip dot expressions":
    var foo = Foo(first: 1, second: "two", third: 3.0)
    with foo:
      first = 2
      foo.first = 3

  test "shadow by const":
    var foo = (first: 1, second: "two", third: 3.0)
    with foo:
      block:
        const first = "dragons"
        check first == "dragons"
        check foo.first == 1
      check first == 1
      check foo.first == 1

  test "shadow by let":
    var foo = (first: 1, second: "two", third: 3.0)
    with foo:
      block:
        let first = "dragons"
        check first == "dragons"
        check foo.first == 1
      check first == 1
      check foo.first == 1

  test "shadow by var":
    var foo = (first: 1, second: "two", third: 3.0)
    with foo:
      block:
        var first = "dragons"
        check first == "dragons"
        check foo.first == 1
      check first == 1
      check foo.first == 1

  test "shadow by var2":
    var foo = (first: 1, second: "two", third: 3.0)
    with foo:
      block:
        var first: string
        check first == ""
        check foo.first == 1
      check first == 1
      check foo.first == 1

  test "shadow by proc":
    var foo = (first: 1, second: "two", third: 3.0)
    with foo:
      block:
        proc first(): string = "dragons"
        check first() == "dragons"
        check foo.first == 1
      check first == 1
      check foo.first == 1

  test "proc member":
    proc fn1(v: int): int = v+1
    var bar = Bar(fn: fn1)
    with bar:
      block:
        check fn(1) == 2
        proc fn(v: int): int = v+2
        check fn(1) == 3
      check fn(1) == 2


