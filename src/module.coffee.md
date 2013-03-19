This file defines the machinery for building an encapsulated bundle of code.
==============================================================================

It is meant to serve as the preamble that is prefixed to all bundles of code
wrapped into a membrane.

It exposes three functions to the code within its membrane:
* `define` is used for defining a section of code.
* `using` is used for declaring dependencies.
* `require` is made available for modules that need to call it.

    define = ->
    using = ->
    require = ->

One further function is exposed, but it is not part of the public api.

    __end_of_definitions__ = ->

These are initially defined as stubs, as they will need access to their
own encapsulated state. Their real definitions live with a function
which encapsulates the module caches.

    do ->

      pending_modules = {}
      defined_modules = {}

And an object used as a semaphore for the pending state.

      pending = {}

Require is the simplest. It just gets the named module, or throws an error if it
cannot be fetched.

      require = (name) -> defined_modules[name] or throw new Error "Cannot find required module #{ name }"

Then we define a function whose job it is to promote all pending definitions
to real definitions if their dependencies can be met. We determine whether
a function's dependencies are met by whether or not it returns `null`.

      sweep_pending = ->
        defined = 0
        for name, definition of pending_modules
          obj = definition()
          if obj isnt pending
              defined_modules[name] = obj
              delete pending_modules[name]
              defined++
        defined

We can then say that defining all pending modules that can be defined is the
same as sweeping the pending list until it cannot define any more modules.

      define_pending_modules = -> 1 while sweep_pending()

This now means we can describe `define`. `define` takes a name and a function that takes
no arguments, and either returns the pending semaphore or a newly defined object. This function
has no useful return value.

      define = (name, definition) ->
        if name of pending_modules or name of defined_modules
          throw new Error "Attempt to redefine #{ name }"
        pending_modules[name] = definition
        define_pending_modules()
        null

Modules that have dependencies should use the `using` function to manage this. This function
takes a variable length list of dependency names and a function that binds those names to
variables, and produces a function that takes no arguments and either returns the pending
semaphore if the requirements are not met, or the newly defined object.

      using = (names..., f) -> (eof = false) ->
        objs = (defined_modules[name] for name in names when name of defined_modules)
        if obj.length is names.length
          f objs...
        else if eof
          (name for name in names when name not of defined_modules)
        else
          pending

One final function is needed; `__end_of_definitions__`, which is wrapped around the
end of the bundled code so we can determine if any modules were defined but could not be
created due to missing dependencies.

      __end_of_definitions__ = ->
        still_pending = (name for name of pending_modules)
        if still_pending.length
          err = "The following modules have unmet dependencies"
          problems = ("#{ name } needs [#{ pending_modules[name] true }]" for name in still_pending)
          throw new Error "#{ err }: #{ problems.join ', ' }"
