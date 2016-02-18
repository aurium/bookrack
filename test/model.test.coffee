should = require 'should'
sinon = require 'sinon'
bookrackBuilder = require '..'
knexBuilder = require 'knex'

{ stubArg, memoryDBConf } = require './helper'

describe 'Model class', ->
  knex = null

  beforeEach (done)->
    @timeout 10e3
    knex ||= knexBuilder memoryDBConf
    knex.schema.dropTableIfExists('tableA').then ->
      knex.schema.createTable 'tableA', (table)->
        table.increments('id').primary()
        table.string('foo')
      .then -> do done

  buildORM = ->
    db = bookrackBuilder connection: knex
    db.defineModel ->
      model: 'ModelA',
      tableName: 'tableA',
      foo: @string
      things: @hasMany 'table-of-things'
    db

  it 'build the described model interface on its intances', (done)->
    knex('tableA').insert(foo: 'bar').asCallback (err)->
      return done err if err
      db = do buildORM
      db.ModelA.find foo: 'bar', (err, obj)->
        return done err if err
        obj.$attrs.should.be.deepEqual foo: 'column', things: 'hasMany'
        obj.foo.should.be.equal 'bar'
        do done

  it 'not crash when finding in empty table', (done)->
    db = do buildORM
    db.ModelA.find foo: 'bar', (err, obj)->
      console.error err
      do done

  it 'extends the model instance interface with columns found in the db table'


