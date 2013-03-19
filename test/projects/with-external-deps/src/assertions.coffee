expect = require('chai').expect

describe 'a file inside the membrane, but not importing', ->

  it 'should not have access to the things', ->

    expect(typeof Foo).to.equal('undefined')
    expect(typeof Bar).to.equal('undefined')
    expect(typeof Quux).to.equal('undefined')
