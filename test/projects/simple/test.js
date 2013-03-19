describe('files that live outside the membrane', function() {
  var expect = require('chai').expect;
  it('should have no access to the internals', function() {
    expect(typeof Foo).to.equal('undefined');
  });
});
