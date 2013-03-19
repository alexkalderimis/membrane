describe 'A file without importing modules', ->
  expect = require('chai').expect

  it 'should not have access to the modules', ->
    expect(typeof Bar).to.equal('undefined')

    expect(typeof Foo).to.equal('undefined')

