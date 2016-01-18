should = require 'should'
sinon = require 'sinon'
builder = require '..'
knexBuilder = require 'knex'

{ stubArg, memoryDBConf } = require './helper'

describe 'Model class', ->

  it 'build the described model interface on its intances', (done)->
    @timeout 10e3
    knex = knexBuilder memoryDBConf
    knex.schema.createTable 'tableA', (table)->
      table.increments('id').primary()
      table.string('foo')
    .then ->
      knex('tableA').insert(foo: 'bar').asCallback (err)->
        return done err if err
        db = builder connection: knex
        db.defineModel ->
          model: 'ModelA',
          tableName: 'tableA',
          foo: @string
          things: @hasMany 'table-of-things'
        db.ModelA.find foo: 'bar', (err, obj)->
          return done err if err
          should.not.exist err
          obj.$attrs.should.be.deepEqual foo: 'column', things: 'hasMany'
          obj.foo.should.be.equal 'bar'
          do done
    .catch (err)-> done err

  it 'extends the model instance interface with columns found in the db table'


