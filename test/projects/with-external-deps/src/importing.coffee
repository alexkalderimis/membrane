using 'foo', 'bar', 'quux', (Foo, Bar, Quux) ->
  
  expect = require('chai').expect

  describe 'a file inside the membrane, importing deps', ->

    it 'should have access to the things', ->

      expect(Foo).to.be.ok
      expect(Bar).to.be.ok
      expect(Quux).to.be.ok

      expect(new Foo().foo()).to.equal('FOO!')
      expect(new Bar().bar()).to.equal('BAR!')
      expect(Quux.quux()).to.equal('QUUX!')


