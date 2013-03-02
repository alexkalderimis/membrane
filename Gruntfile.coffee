module.exports = (grunt) ->

  grunt.initConfig
    simplemocha:
      options:
        globals: ['expect']
        timeout: 3000
        ignoreLeaks: false
        ui: 'bdd'
        reporter: 'spec'
      all:
        src: 'test/*.coffee'

  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-contrib-coffee'

  grunt.registerTask 'default', 'simplemocha'


