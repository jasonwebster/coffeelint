path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('no_implicit_braces').addBatch({

    'Implicit braces' :

        topic : () ->
            '''
            a = 1:2
            y =
              'a':'b'
              3:4
            '''

        'are allowed by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {no_implicit_braces : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Implicit braces are forbidden')
            assert.equal(error.rule, 'no_implicit_braces')

    'Implicit braces strict' :
        topic: """
            foo =
              bar:
                baz: 1
                thing: 'a'
              baz: ['a', 'b', 'c']
        """

        "blocks all implicit braces by default": (source) ->
            config = {no_implicit_braces : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            assert.equal(rule, 'no_implicit_braces') for {rule} in errors

        "allows braces at the end of lines when strict is false": (source) ->
            config =
                no_implicit_braces :
                    level: 'error'
                    strict: false
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Implicit braces in class definitions' :

        topic : () ->
            '''
            class Animal
              walk: ->

            class Wolf extends Animal
              howl: ->

            class nested.Name
              constructor: (@options) ->

            class deeply.nested.Name
              constructor: (@options) ->

            x = class
              m : -> 123

            y = class extends x
              m : -> 456

            z = class

            r = class then 1:2
            '''

        'are always ignored' : (source) ->
            config = {no_implicit_braces : {level:'error'}}
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'Test that any implicit braces inside classes are caught':
        topic: () ->
            """
            class ABC
              @CONST = 'DEF'

              constructor: (abc) ->
                s =
                  t: 3

              getDef: ->
                u =
                  v: 'a'

            class A extends B
              @PI = 3

              constructor: ->
                @a = 3

            class Role extends Model
              @A = '1'
              @B = []
              @C = 3
              @D = {}

              constructor: (x) ->
                x = 5
                @E = 3

              eFunc: (f, g) ->
                g = @B * f
                return [@A, g]

            """

        'throws no errors for this when strict is false': (source) ->
            config =
                no_implicit_braces:
                    level: 'error'
                    strict: false
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 0)

        'throws 2 errors for this when strict is true': (source) ->
            config =
                no_implicit_braces:
                    level: 'error'
                    strict: true
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            assert.equal(errors[0].lineNumber, 6)
            assert.equal(errors[1].lineNumber, 10)

}).export(module)
