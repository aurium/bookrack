# Recognize valid model module extensions
moduleExtRE = /\.(coffee|js|co|eg|iced|litcoffee|ls)$/
validModelNameER = /^[A-Z][a-zA-Z0-9_]*$/

# Define read-only attributes
readOnly = (obj, attr, func, enumerable=false)->
  Object.defineProperty obj, attr,
    get: func
    set: -> console.error "WARNING: #{@constructor.name}.#{attr}
                           is a read only property."
    enumerable: !!enumerable

readOnlyEnum = (obj, attr, func)->
  enumerable

# Convert file names to class names
file2class = (fileName)->
  fileName.replace /^(.)|[-_](.)/g, (s,g1,g2)-> (g1||g2).toUpperCase()

# Path methods and attributes
{join:joinPath, sep:pathSep, resolve:resolvePath} = require 'path'

