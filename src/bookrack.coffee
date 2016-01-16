fs = require 'fs'

# Main class
# Bookrack instances stores the bookshelf+knex refferences and works as a
# model store to the application.
class Bookrack

  constructor: (options={})->
    unless options.connection?
      throw new Error "You must to define a DB connection for Bookrack!"
    knex = require('knex') options.connection
    bookshelf = require('bookshelf') knex
    bookshelf.plugin 'registry'
    bookshelf.plugin 'virtuals'
    bookshelf.plugin 'visibility'
    readOnly this, '_bookshelf', => bookshelf
    @loadModelsFromDir options.modelsDir if options.modelsDir?

  loadModelsFromDir: (dirPath)->
    for file in fs.readdirSync dirPath when moduleExtRE.test file
      filePath = joinPath dirPath, file
      try
        @loadModelFile filePath
      catch err
        err.message = "ERROR when loading #{filePath}: #{err.message}"
        throw err

  loadModelFile: (filePath, options={})->
    [dir..., fileName] = filePath.split pathSep
    dir.unshift '/' if pathSep is '/'
    dir = resolvePath dir...
    modName = fileName.replace moduleExtRE, ''
    klass = file2class modName
    model = new Bookrack.Model this, require joinPath dir, modName
    unless klass is model.name
      console.error "WARNING: It is expected that module #{filePath}
                     to define a model named #{klass},
                     however it defines #{model.name}."
    model


###
fs = require 'fs'
modelsDir = __dirname + '/../models/'

timeout .1, ->
  for file in fs.readdirSync modelsDir when /\.coffee$/.test file
    modName = file.replace /\.coffee$/, ''
    klass = modName.replace /^(.)|[-_](.)/g, (s,g1,g2)-> (g1||g2).toUpperCase()
    exports[klass] = require modelsDir + modName
  new exports.User(email: 'ze@example.com').fetch(withRelated: ['nucleus'])
    .then (usr)->
      console.log usr.constructor.toString()
      console.log 'User:', usr.get('email'), usr.get('fullName'), '!', exports.User.fullName
      console.log '------------------------------------------------------------'
      console.log 'Nucleus:', usr.related('nucleus').models[0].get 'name'
    .catch (err)->
      console.log 'WTF', err
###
