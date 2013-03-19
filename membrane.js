require('coffee-script');
var _ = require('underscore');

var membrane = require('./lib/membrane');

var project = process.argv[2];

/^\//.test(project) || (project = './' + project);
/\/$/.test(project) || (project += '/')

var config = require(project + 'membrane.json');

var qualify = function (o) {
  return _.defaults({src: project + o.src}, o);
};

config.organelles = config.organelles ? config.organelles.map(qualify) : [];

membrane.reproduce(config.organelles, (project + config.src), project + config.filename)
        .done(function() { console.log("[SUCCESS] Produced " + project + config.filename) })




