deps = ['foo']

using deps..., (Foo) ->

  class Quux extends Foo

    quux: -> @foo() + '!!!'
