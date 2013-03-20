using 'foo', 'bar', 'quux', (Foo, Bar, Quux) ->

  expect = require('chai').expect


  describe 'A file which imported its modules', ->
    it "should have access to the modules", ->
      expect(Foo).to.be.ok
      expect(Bar).to.be.ok
      expect(Quux).to.be.ok
 
    it 'should have access to a foo that foos', ->
      foo = new Foo

      expect(foo.foo()).to.equal('Foo!')

    it 'should have access to a quux that quuxes and foos', ->
      quux = new Quux

      expect(quux.foo()).to.equal('Foo!')
      expect(quux.quux()).to.equal('Foo!!!!')
