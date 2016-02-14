should = require 'should'
sinon = require 'sinon'
builder = require '..'

{ stubArg, memoryDBConf } = require './helper'

describe 'Bookrack class', ->

  it 'Start with a knex configuration', ->
    db = builder connection: memoryDBConf
    db.should.be.instanceof builder.Bookrack

  it 'Start with a knex object', ->
    knex = require('knex') memoryDBConf
    db = builder connection: knex
    db.should.be.instanceof builder.Bookrack

  it 'Builds models', ->
    db = builder connection: memoryDBConf
    db.defineModel -> model: 'Model01', tableName: 'table01', col1: @string
    db.defineModel -> model: 'Model02', tableName: 'table02', colA: @string
    db.Model01.should.be.instanceof builder.Bookrack.Model
    db.Model02.should.be.instanceof builder.Bookrack.Model

  it 'Allows to list built models', ->
    db = builder connection: memoryDBConf
    db.defineModel -> model: 'Model01', tableName: 'table01', col1: @string
    db.defineModel -> model: 'Model02', tableName: 'table02', colA: @string
    Object.keys(db).should.be.deepEqual ['Model01', 'Model02']

  it 'load model from file'

  it 'notify user when model file name unmatch the model name'

  it 'Auto load models from dir', ->
    fs = require 'fs'
    path = require 'path'
    stubArg(fs, 'readdirSync', ':somedir:').returns ['M1.js', 'M2.js']
    sinon.mock(builder.Bookrack.prototype).expects('loadModelFile').twice()
    db = builder connection: memoryDBConf, modelsDir: ':somedir:'

  it 'identify if has pending migrations'
