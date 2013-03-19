using 'foo', 'bar', (Foo, Bar) ->

  expect = require('chai').expect


  describe 'A file which imported its modules', ->
    it "should have access to the modules", ->
      expect(Foo).to.be.ok
      expect(Bar).to.be.ok

      foo = new Foo

      expect(foo.foo()).to.equal('Foo!')
