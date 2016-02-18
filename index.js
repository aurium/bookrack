// Generated by CoffeeScript 1.10.0
(function() {
  var Bookrack, Model, buildMetaData, buildModelInstanceProto, defineModelInstAttr, file2class, fs, joinPath, moduleExtRE, pathSep, readOnly, readOnlyEnum, ref, resolvePath, validModelNameER,
    slice = [].slice,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  fs = require('fs');

  Bookrack = (function() {
    function Bookrack(options) {
      var bookshelf, knex;
      if (options == null) {
        options = {};
      }
      if (options.connection == null) {
        throw new Error("You must to define a DB connection, or a knex object for Bookrack!");
      }
      if (options.connection.queryBuilder != null) {
        knex = options.connection;
      } else {
        knex = require('knex')(options.connection);
      }
      bookshelf = require('bookshelf')(knex);
      bookshelf.plugin('registry');
      bookshelf.plugin('virtuals');
      bookshelf.plugin('visibility');
      readOnly(this, '_bookshelf', (function(_this) {
        return function() {
          return bookshelf;
        };
      })(this));
      readOnly(this, 'migrate', (function(_this) {
        return function() {
          return _this._bookshelf.knex.migrate;
        };
      })(this));
      readOnly(this, 'seed', (function(_this) {
        return function() {
          return _this._bookshelf.knex.seed;
        };
      })(this));
      if (options.modelsDir != null) {
        this.loadModelsFromDir(options.modelsDir);
      }
    }

    Bookrack.prototype.loadModelsFromDir = function(dirPath) {
      var err, error, file, filePath, i, len, ref, results;
      ref = fs.readdirSync(dirPath);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        file = ref[i];
        if (!(moduleExtRE.test(file))) {
          continue;
        }
        filePath = joinPath(dirPath, file);
        try {
          results.push(this.loadModelFile(filePath));
        } catch (error) {
          err = error;
          err.message = "ERROR when loading " + filePath + ": " + err.message;
          throw err;
        }
      }
      return results;
    };

    Bookrack.prototype.loadModelFile = function(filePath) {
      var dir, fileName, i, klass, modName, model, ref;
      ref = filePath.split(pathSep), dir = 2 <= ref.length ? slice.call(ref, 0, i = ref.length - 1) : (i = 0, []), fileName = ref[i++];
      if (pathSep === '/') {
        dir.unshift('/');
      }
      dir = resolvePath.apply(null, dir);
      modName = fileName.replace(moduleExtRE, '');
      klass = file2class(modName);
      model = this.defineModel(require(joinPath(dir, modName)));
      if (klass !== model.name) {
        console.error("WARNING: It is expected that module " + filePath + " to define a model named " + klass + ", however it defines " + model.name + ".");
      }
      return model;
    };

    Bookrack.prototype.defineModel = function(confFunc) {
      return new Bookrack.Model(this, confFunc);
    };

    Bookrack.prototype.hasPendingMigration = function(callback) {
      var migrationDir;
      migrationDir = this.migrate.config.directory;
      if (migrationDir[0] !== '/' && migrationDir.slice(0, 2) !== 'C:') {
        console.error("WARNING: your `knexConfig.migrations.directory` is a relative path. This will be a problem! Use `path.resolve` on your config file.");
      }
      return this.migrate.currentVersion().then(function(version) {
        return fs.readdir(migrationDir, (function(_this) {
          return function(err, list) {
            var file, i, lastMigration, len, numPendingMigrations;
            if (err) {
              return callback(err);
            }
            numPendingMigrations = 0;
            for (i = 0, len = list.length; i < len; i++) {
              file = list[i];
              if (moduleExtRE.test(file)) {
                lastMigration = file.replace(/_.*$/, '');
                if ((version == null) || version === 'none' || version < lastMigration) {
                  numPendingMigrations++;
                }
              }
            }
            return callback(null, numPendingMigrations);
          };
        })(this));
      })["catch"](function(err) {
        return callback(err);
      });
    };

    return Bookrack;

  })();


  /*
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
   */

  module.exports = function(knexConfig, options) {
    return new Bookrack(knexConfig, options);
  };

  module.exports.Bookrack = Bookrack;

  moduleExtRE = /\.(coffee|js|co|eg|iced|litcoffee|ls)$/;

  validModelNameER = /^[A-Z][a-zA-Z0-9_]*$/;

  readOnly = function(obj, attr, func, enumerable) {
    if (enumerable == null) {
      enumerable = false;
    }
    return Object.defineProperty(obj, attr, {
      get: func,
      set: function() {
        return console.error("WARNING: " + this.constructor.name + "." + attr + " is a read only property.");
      },
      enumerable: !!enumerable
    });
  };

  readOnlyEnum = function(obj, attr, func) {
    return enumerable;
  };

  file2class = function(fileName) {
    return fileName.replace(/^(.)|[-_](.)/g, function(s, g1, g2) {
      return (g1 || g2).toUpperCase();
    });
  };

  ref = require('path'), joinPath = ref.join, pathSep = ref.sep, resolvePath = ref.resolve;

  buildModelInstanceProto = function(model) {
    var instanceProto;
    instanceProto = {
      save: function() {
        return console.log('TODO');
      },
      set: function(x) {
        return console.error("WARNING: you dont need to use `" + this.$model.name + "::set(" + x + ")`.");
      },
      get: function(x) {
        return console.error("WARNING: you dont need to use `" + this.$model.name + "::get(" + x + ")`.");
      },
      $attrs: {}
    };
    readOnly(instanceProto, '$model', (function(_this) {
      return function() {
        return model;
      };
    })(this));
    return instanceProto;
  };

  buildMetaData = function(model, confFunc) {
    var attr, ctxMethods, instanceProto, modelName, modelStruct, protoProps, staticProps, value;
    ctxMethods = {
      belongsToMany: function() {
        var args;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        return {
          type: 'belongsToMany',
          def: function() {
            return this.belongsToMany.apply(this, args);
          }
        };
      },
      hasMany: function() {
        var args;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        return {
          type: 'hasMany',
          def: function() {
            return this.hasMany.apply(this, args);
          }
        };
      },
      virtual: function(arg) {
        return {
          type: 'virtual',
          def: arg
        };
      },
      string: function(columnName) {
        return {
          type: 'column',
          def: {
            type: 'string',
            columnName: columnName
          }
        };
      }
    };
    ctxMethods.string.type = 'column';
    ctxMethods.string.def = {
      type: 'string',
      columnName: null
    };
    modelStruct = confFunc.apply(ctxMethods);
    protoProps = {};
    staticProps = {};
    instanceProto = buildModelInstanceProto(model);
    for (attr in modelStruct) {
      value = modelStruct[attr];
      if (!Model.validInstanceAttrName(attr)) {
        throw new Error("Invalid attribute name \"" + attr + "\".");
      }
      switch (attr) {
        case 'model':
          modelName = value;
          break;
        case 'tableName':
          protoProps.tableName = value;
          break;
        case 'static':
          staticProps = value;
          break;
        default:
          if (value.type) {
            defineModelInstAttr(instanceProto, protoProps, attr, value);
          } else {
            throw new Error("Bad definition for attribute " + attr + ".");
          }
      }
    }
    return [modelName, protoProps, staticProps, instanceProto];
  };

  defineModelInstAttr = function(instanceProto, protoProps, attr, column) {
    var base, defInstAttr, get, readOnlyW, set;
    defInstAttr = function(config) {
      config.enumerable = true;
      Object.defineProperty(instanceProto, attr, config);
      return readOnly(instanceProto.$attrs, attr, (function() {
        return column.type;
      }), true);
    };
    readOnlyW = function() {
      return console.error("WARNING: " + this.$model.name + "::" + attr + " is read only.");
    };
    switch (column.type) {
      case 'belongsToMany':
        protoProps[attr] = column.def;
        return defInstAttr({
          get: function() {
            return Model._getRelated(model, column.attr);
          },
          set: readOnlyW
        });
      case 'hasMany':
        protoProps[attr] = column.def;
        return defInstAttr({
          get: function() {
            return Model._getRelated(model, attr);
          },
          set: readOnlyW
        });
      case 'virtual':
        get = column.def.get != null ? column.def.get : column.def;
        set = column.def.set != null ? column.def.set : readOnlyW;
        return defInstAttr({
          get: get,
          set: set
        });
      case 'column':
        if ((base = column.def).columnName == null) {
          base.columnName = attr;
        }
        get = function() {
          return this._bookshelfModelInst.get(column.def.columnName);
        };
        set = function(value) {
          return this._bookshelfModelInst.set(column.def.columnName, value);
        };
        return defInstAttr({
          get: get,
          set: set
        });
      default:
        throw new Error("Unknown model attribute type \"" + type + "\" for " + attr + ".");
    }
  };

  Bookrack.Model = Model = (function() {
    function Model(bookrack, confFunc) {
      var attr, get, instProto, name, protoProps, readOnlyW, ref1, set, staticProps, value;
      readOnly(this, '$models', (function(_this) {
        return function() {
          return bookrack;
        };
      })(this));
      ref1 = buildMetaData(this, confFunc), name = ref1[0], protoProps = ref1[1], staticProps = ref1[2], instProto = ref1[3];
      if (!validModelNameER.test(name)) {
        throw new Error("\"" + name + "\" is not a valid model name. It shoud match " + validModelNameER + ".");
      }
      readOnly(this, 'name', (function(_this) {
        return function() {
          return name;
        };
      })(this));
      readOnly(bookrack, name, ((function(_this) {
        return function() {
          return _this;
        };
      })(this)), true);
      readOnly(this, '_bookshelfModel', (function(_this) {
        return function() {
          return bookrack._bookshelf.model(name, protoProps, staticProps);
        };
      })(this));
      readOnly(this, "_" + this.name + "Constructor", (function(_this) {
        return function() {
          var klass;
          klass = (function() {});
          klass.prototype = instProto;
          return klass;
        };
      })(this));
      readOnlyW = function() {
        return console.error("WARNING: " + this.name + "." + attr + " is read only.");
      };
      for (attr in staticProps) {
        value = staticProps[attr];
        if (!Model.validStaticAttrName(attr)) {
          throw new Error("Invalid attribute name \"" + attr + "\".");
        }
        get = value.get != null ? value.get : value;
        set = value.set != null ? value.set : readOnlyW;
        Object.defineProperty(this, attr, {
          get: get,
          set: set,
          enumerable: true
        });
      }
    }

    Model.prototype["new"] = function(attributes) {
      var instance, obj;
      if (attributes == null) {
        attributes = {};
      }
      instance = new this["_" + this.name + "Constructor"];
      if (attributes._previousAttributes) {
        obj = attributes;
      } else {
        obj = this._bookshelfModel(attributes);
      }
      readOnly(instance, '_bookshelfModelInst', (function(_this) {
        return function() {
          return obj;
        };
      })(this));
      return instance;
    };

    Model.prototype.create = function(attributes) {
      var instance;
      instance = this["new"](attributes);
      instance.save();
      return instance;
    };

    Model.prototype.find = function(query, callback) {
      if (callback != null) {
        return new this._bookshelfModel(query).fetch().asCallback((function(_this) {
          return function(err, obj) {
            if (err) {
              return callback(err);
            }
            if (obj) {
              obj = _this["new"](obj);
            }
            return callback(null, obj);
          };
        })(this));
      } else {

      }
    };

    return Model;

  })();

  Model.restrictedStaticAttrNames = '$models name new create'.split(' ');

  Model.restrictedInstanceAttrNames = '$model virtuals save update get set related'.split(' ');

  Model.validStaticAttrName = function(name) {
    return !(indexOf.call(Model.restrictedStaticAttrNames, name) >= 0);
  };

  Model.validInstanceAttrName = function(name) {
    return !(indexOf.call(Model.restrictedInstanceAttrNames, name) >= 0);
  };

  Model._getRelated = function(model, attr) {
    return model._bookshelfModelInst.related(attr);
  };

}).call(this);
