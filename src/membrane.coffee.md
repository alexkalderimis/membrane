This file defines functions that produce encapsulated membranes of code.
=========================================================================

This file does I/O to read files in order to build the encapsulated bundle.
Accordingly it needs access to the file-system modules of the nodejs API, and
it uses Q to manage the asynchronous nature of this code. The coffee-script compiler
itself it imported to do. We import underscore for its utility functions.

    fs = require 'fs'
    Q  = require 'q'
    cs = require 'coffee-script'
    _  = require 'underscore'

Rather than using the raw `fs` functions, we will wrap these in `Q`'s asynchronous
goodness, and provide sugar for standard access.

    qread = Q.nfbind fs.readFile
    read = (filename, enc = 'utf8') -> qread filename, enc
    writeP = Q.nfbind fs.writeFile
    getWriter = (filename) -> (data, enc = 'utf8') -> writeP filename, data, enc

    compile = (filename, opts = {}) -> read(filename).then (text) ->
      if opts.isNative
        _.defaults opts, {bare: true}
        text = "-> (#{ text })" unless text.match(/^\s*using/)
      try
        cs.compile text, _.extend {filename, literate: cs.helpers.isLiterate filename}, opts
      catch e
        throw new Error("Could not compile #{ filename }: \n #{e} \n#{ text }")


In addition to these simple `fs` wrappers, we also need a function for reading
all the files in a directory, recursively.

    deepRead = (name) ->
      if fs.statSync(name).isDirectory()
        readdir(name).then (files) -> Q.all( deepRead "#{ name }/#{ f }" for f in files )
      else
        Q(name)

Where `readdir` is just the wrapped version of `fs.readdir`

    readdir = Q.nfbind fs.readdir

We need a simple string matcher for checking if the source file is javascript:

    IS_JS = /\.js$/

We wrap the code in a function to prevent leakage, and make sure that the finaliser
is called

    wrap = (code) -> """
      (function() {
        #{ code };
        __end_of_definitions__();
      }).call();
    """

We bundle up each section of the code in such a way that we can isolate its
definitions and re-export them into the library.

    bundle = (b) -> if b.isNative then nativeBundle b else foreignBundle b
    
    nativeBundle = (b) -> """
      (function() {
        var require = __our_require__;
        define('#{ b.name }', (function() { return #{ b.js }})());
      })();
    """

    foreignBundle = (b) -> """
      define('#{ b.name }', function() {
        var context = {}
          , exports = context
          , module = context
          , require = __our_require__;
        var ret = (function() { return #{ b.js };}).call(context);
        return ret || context['#{b.root }'] || module.exports || context;
      });
    """

We export the `envelop` function, which builds a bundle.

    exports.envelop = envelop = (organelles) ->

It does this by first compiling all code to javascript, if it isn't that already.

      promises = for o in organelles then do (o) ->
        f = if IS_JS.test o.src then read else (fn) -> compile fn, o
        f(o.src).then (js) -> _.extend {js, root: o.root or o.name}, o

The prelude is the module code from this library.

      prelude = __dirname + '/../src/module.coffee.md'

When we have read everything, then we need to concatenate it up into a bundle, which involves
a bit of text transformation on each part, followed by concatenation and wrapping.

      Q.all(promises)
       .then((bundles) -> bundles.map bundle)
       .then((sections) -> compile(prelude, bare: true).then (pre) -> [pre, sections...,])
       .then((sections) -> wrap sections.join('\n'))
       

The other function exported is the `reproduce` function, which takes a set of
organelles and a source directory, and builds writes the resulting enveloped bundle
to a file.

    exports.reproduce = reproduce = (organelles, srcdir, filename) ->

We say that we will write to the filename.

      write = getWriter filename

And now we find all the files in the source directory, and add them to the
list of organelles, build a bundle and write it to the destination.

      stripSrcDir = (name) -> name.replace(srcdir + '/', '').replace(/\.[^\/]+$/, '')
      isNative = true

      deepRead(srcdir)
        .then((srcs) -> ( {src, isNative, name: stripSrcDir(src)} for src in srcs ) )
        .then((newElems) -> organelles.concat newElems)
        .then(envelop)
        .then(write)







