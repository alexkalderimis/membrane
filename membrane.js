require('coffee-script');

var membrane = require('./lib/membrane');

var project = process.argv[2];

/^\//.test(project) || (project = './' + project);
/\/$/.test(project) || (project += '/')

var config = require(project + 'membrane.json');

membrane.reproduce((config.organelles || []), (project + config.src), project + config.filename)
        .done(function() { console.log("Produced " + config.filename) })




