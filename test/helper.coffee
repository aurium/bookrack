sinon = require 'sinon'

module.exports =

  stubArg: (obj, method, args...)-> sinon.stub(obj, method).withArgs args...

  memoryDBConf: client: 'sqlite3', connection: filename: ":memory:"

