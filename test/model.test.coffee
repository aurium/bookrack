should = require 'should'
sinon = require 'sinon'
bookrackBuilder = require '..'
knexBuilder = require 'knex'

{ stubArg, memoryDBConf } = require './helper'

describe 'Model class', ->
  knex = db = null

  beforeEach (done)->
    @timeout 10e3
    knex ||= knexBuilder memoryDBConf
    knex.schema.dropTableIfExists('tableA').then ->
      knex.schema.createTable 'tableA', (table)->
        table.increments('id').primary()
        table.string 'foo'
        table.string 'unknown-column'
      .then ->
        do buildORM
        do done

  buildORM = ->
    db = bookrackBuilder connection: knex
    db.defineModel ->
      model: 'ModelA',
      tableName: 'tableA',
      foo: @string
      things: @hasMany 'table-of-things'

  it 'build the described model interface on its intances', (done)->
    knex('tableA').insert(foo: 'bar').asCallback (err)->
      return done err if err
      db.ModelA.find foo: 'bar', (err, obj)->
        return done err if err
        obj.$attrs.should.have.property('foo').which.is.equal 'column'
        obj.$attrs.should.have.property('things').which.is.equal 'hasMany'
        obj.foo.should.be.equal 'bar'
        do done

  it 'not crash when finding in empty table', (done)->
    db.ModelA.find foo: 'bar', (err, obj)->
      should.not.exist err
      should.not.exist obj
      do done

  it 'extends the model instance interface with columns found in the db table', (done)->
    knex('tableA').insert(foo: 'bar').asCallback (err)->
      return done err if err
      db.ModelA.find foo: 'bar', (err, obj)->
        return done err if err
        obj.$attrs.should.have.property('unknown-column').which.is.equal 'column'
        obj.should.have.property 'unknown-column'
        do done

  it 'instance object access value from column not defined by model config', (done)->
    knex('tableA').insert(foo: 'bar', 'unknown-column': 'yeah').asCallback (err)->
      return done err if err
      db.ModelA.find foo: 'bar', (err, obj)->
        return done err if err
        obj['unknown-column'].should.be.equal 'yeah'
        do done

  it 'load columnInfo', (done)->
    db.ModelA.columnInfo().then (columns)->
      Object.keys(columns).should.be.deepEqual ['id', 'foo', 'unknown-column']
      do done

