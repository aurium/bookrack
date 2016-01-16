# Builds a hash with the common features of model instances
# The model itsel is not a class, it is an object that knows the model and
# can build model instances based on a stored prototype.
buildModelInstanceProto = (model)->
  instanceProto = {
    save: -> console.log 'TODO'
    set: (x)-> console.error "WARNING: you dont need to use `#{@$model.name}::set(#{x})`."
    get: (x)-> console.error "WARNING: you dont need to use `#{@$model.name}::get(#{x})`."
  }
  readOnly instanceProto, '$model', => model
  instanceProto


# Run the model function definition with a special context where we have the
# definition of `@belongsToMany`, `@virtual`, and others... Than returns a
# list of meta data hashes to create bookshelf model and bookrack model instances.
buildMetaData = (model, confFunc)->
  # Define methods to extract raw model:
  ctxMethods =
    belongsToMany: (args...)-> type:'belongsToMany', def: -> @belongsToMany args...
    hasMany: (args...)-> type:'hasMany', def: -> @hasMany args...
    virtual: (arg)-> type:'virtual', def:arg
    string: (columnName)-> type:'column', def:{ type:'string', columnName:columnName }
  ctxMethods.string.type = 'column'
  ctxMethods.string.def = { type:'string', columnName:null }
  # Build raw model structure from confFunc returned hash:
  modelStruct = confFunc.apply ctxMethods
  # Store values to be used by bookshelf model constructor:
  protoProps = {}
  staticProps = {}
  instanceProto = buildModelInstanceProto model
  # Build bookshelf definition data and set instanceProto attributes:
  for attr, value of modelStruct
    unless Model.validInstanceAttrName attr
      throw new Error "Invalid attribute name \"#{attr}\"."
    switch attr
      when 'model'     then modelName = value
      when 'tableName' then protoProps.tableName = value
      when 'static'    then staticProps = value
      else
        #convertUncalledMethodsFromMetaData ctxMethods, 
        if value.type
          defineModelInstAttr instanceProto, protoProps, attr, value
        else
          throw new Error "Bad definition for attribute #{attr}."

  [ modelName, protoProps, staticProps, instanceProto ]


# Set relations and static definitions to bookshelf model meta data
defineModelInstAttr = (instanceProto, protoProps, attr, column)->
  # define getters and setters to be used on instances:
  defInstAttr = (config)->
    config.enumerable = true
    Object.defineProperty instanceProto, attr, config
  readOnlyW = -> console.error "WARNING: #{@$model.name}::#{attr} is read only."
  # TODO: register the attr type for future "Auto DB Builder"
  switch column.type
    when 'belongsToMany'
      protoProps[attr] = column.def
      defInstAttr
        get: -> Model._getRelated model, column.attr
        set: readOnlyW
    when 'hasMany'
      protoProps[attr] = column.def
      defInstAttr
        get: -> Model._getRelated model, attr
        set: readOnlyW
    when 'virtual'
      get = if column.def.get? then column.def.get else column.def
      set = if column.def.set? then column.def.set else readOnlyW
      defInstAttr get: get, set: set
    when 'column'
      column.def.columnName ?= attr
      get = ->
        @_bookshelfModelInst.get column.def.columnName
      set = (value)-> @_bookshelfModelInst.set column.def.columnName, value
      defInstAttr get: get, set: set
    else
      throw new Error "Unknown model attribute type \"#{type}\" for #{attr}."


Bookrack.Model = class Model

  constructor: (bookrack, confFunc)->
    readOnly this, '$models', => bookrack
    [ name, protoProps, staticProps, instProto ] = buildMetaData this, confFunc
    unless validModelNameER.test name
      throw new Error "\"#{name}\" is not a valid model name.
                       It shoud match #{validModelNameER}."
    readOnly this, 'name', => name
    # Append this model as a bookrack instance property:
    # (this allows bookrack instance to be a directory of models)
    readOnly bookrack, name, (=> this), true
    readOnly this, '_bookshelfModel', =>
      bookrack._bookshelf.model name, protoProps, staticProps
    readOnly this, "_#{@name}Constructor", =>
      klass = (->)
      klass.prototype = instProto
      klass
    readOnlyW = -> console.error "WARNING: #{@name}.#{attr} is read only."
    for attr, value of staticProps
      unless Model.validStaticAttrName attr
        throw new Error "Invalid attribute name \"#{attr}\"."
      get = if value.get? then value.get else value
      set = if value.set? then value.set else readOnlyW
      Object.defineProperty this, attr, get: get, set: set, enumerable: true
    # TODO: Load table structure to add columns as model instance attributes.

  # Build a model instance, witout saving it.
  new: (attributes)->
    instance = new @["_#{@name}Constructor"]
    if attributes._previousAttributes
      obj = attributes
    else
      obj = @_bookshelfModel attributes
    readOnly instance, '_bookshelfModelInst', => obj
    instance

  # Build a model instance, and save it.
  create: (attributes)->
    instance = @new attributes
    do instance.save
    instance

  find: (query, callback)->
    if callback?
      new @_bookshelfModel(query).fetch().asCallback (err, obj)=>
        obj = @new obj unless err?
        callback err, obj
    else
      # TODO promisse fashon

Model.restrictedStaticAttrNames = '$models name new create'.split ' '
Model.restrictedInstanceAttrNames = '$model virtuals save update get set related'.split ' '
Model.validStaticAttrName = (name)-> not( name in Model.restrictedStaticAttrNames )
Model.validInstanceAttrName = (name)-> not( name in Model.restrictedInstanceAttrNames )


Model._getRelated = (model, attr)->
  #TODO: encapsulate it!
  model._bookshelfModelInst.related attr

