const fs = require('fs')

const schemaDirPath = 'schema/specification/2.0/schema'
const swiftDirPath = 'Source/Common/schema'
const structPrefix = 'GLTF'

/**
 * @type {Map<string, Promise>}
 */
const schemaPromises = {}

/**
 * @type {Map<string, function>}
 */
const resolveFunctions = {}

/**
 * @type {Map<string, function>}
 */
const rejectFunctions = {}

/**
 * @type {Map<string, Object>}
 */
const schemas = {}

/**
 * @type {Map<string, string>}
 */
const typeLUT = {
  'string': 'String',
  'integer': 'Int',
  'number': 'Float', // should be Double?
  'boolean': 'Bool'
}

// functions

/**
 * get a struct name from a file name
 * @param {string} fileName - file name
 * @param {boolean} lookup - 
 * @returns {string} - struct name
 */
const getStructNameFromFileName = (fileName, lookup = true) => {
  if(lookup && typeLUT.hasOwnProperty(fileName)){
    return typeLUT[fileName]
  }

  const names = fileName.split('.')

  // remove 'schema.json'
  names.pop()
  names.pop()

  return structPrefix + names.map((n) => n.charAt(0).toUpperCase() + n.slice(1)).join('')
}

/**
 * resolve $ref values recursively
 * @param {Object} - json object
 * @returns {void}
 */
const resolveRef = (json) => {
  const promises = []
  if(json.$ref){
    promises.push(schemaPromises[json.$ref].then((refObj) => {
      json._ref = refObj
    }))
  }
  for(const key in json){
    if(typeof json[key] === 'object'){
      promises.push(resolveRef(json[key]))
    }
  }
  return promises
}

/**
 * @param {Object} json - json object
 * @param {string} paramName - name of the parameter
 * @returns {boolean} - true if the json has the property
 */
const hasParam = (json, paramName) => {
  if(typeof json[paramName] !== 'undefined'){
    return true
  }
  if(json._ref){
    return hasParam(json._ref, paramName)
  }
  return false
}

/**
 * @param {Object} json - json object
 * @param {string} paramName - name of the parameter
 * @returns {Object|string|number} - parameter of the json object
 */
const getParam = (json, paramName) => {
  if(typeof json[paramName] !== 'undefined'){
    return json[paramName]
  }
  if(json._ref){
    return getParam(json._ref, paramName)
  }
  return null
}

/**
 * @param {Object} json -
 * @returns {string} - swift type
 */
const getType = (json) => {
  if(json.$ref){
    return getStructNameFromFileName(json.$ref)
  }

  const allOf = getParam(json, 'allOf')
  if(allOf){
    if(allOf.length !== 1){
      throw new Error('unknown definition: allOf.length !== 1')
    }
    return getStructNameFromFileName(allOf[0].$ref)
  }

  const anyOf = getParam(json, 'anyOf')
  if(anyOf){
    return getType(json.anyOf[json.anyOf.length - 1])
  }

  const type = getParam(json, 'type')
  if(!type){
    return null
  }

  if(typeLUT.hasOwnProperty(type)){
    return typeLUT[type]
  }

  if(type === 'array'){
    const items = getParam(json, 'items')
    const itemType = getType(items)
    return `[${itemType}]`
  }else if(type === 'object'){
    const addProp = getParam(json, 'additionalProperties')
    if(addProp){
      const valueType = getType(addProp)
      return `[String:${valueType}]`
    }
    return '[String:Any]'
  }

  throw new Error('unknown type: ' + type)
}

/**
 * @param {Object} json -
 * @param {string} propName -
 * @returns {string} - property type
 */
const getPropertyType = (json, propName) => {
  const prop = json.properties[propName]
  let type = null
  if(prop){
    type = getType(prop)
  }
  if(type){
    return type
  }

  if(json.allOf){
    for(const refItem of json.allOf){
      const t = getPropertyType(refItem._ref, propName)
      if(t){
        return t
      }
    }
  }

  throw new Error(`type is not defined: ${propName}`)
}

/**
 * @param {Object} json - json object
 * @param {string} structName - name of the struct
 * @returns {string}
 */
const convertToSwift = (json, structName) => {
  let text = ''
  const br = '\n'
  const required = json.required || []

  // header
  text += '//' + br
  text += `// ${structName}.swift` + br
  text += '//' + br
  if(json.title){
    text += `// ${json.title}` + br
  }
  if(json.description){
    text += `// ${json.description}` + br
  }
  text += '//' + br + br

  // define typealias if it is not object type.
  if(json.type !== 'object'){
    const type = getType(json)
    if(type){
      text += `typealias ${structName} = ${type}` + br + br
      return text
    }
  }

  text += 'import Foundation' + br + br

  text += `struct ${structName}: Codable {` + br
  const codingKeys = []
  for(const propName in json.properties){
    const prop = json.properties[propName]
    //const propType = getType(prop)
    const propType = getPropertyType(json, propName)

    text += br

    let desc = getParam(prop, 'gltf_detailedDescription', json)
    if(!desc){
      desc = getParam(prop, 'description', json)
    }
    if(desc){
      text += `  /** ${desc} */` + br
    }

    let defaultValue = ''
    if(typeof prop.default !== 'undefined'){
      if(propType === 'String'){
        defaultValue = `"${prop.default}"`
      }else if(propType.charAt(0) === '['){
        defaultValue = `[${prop.default}]`
      }else{
        defaultValue = `${prop.default}`
      }
    }
    const optional = required.includes(propName) ? '' : '?'

    if(defaultValue === ''){
      text += `  let ${propName}: ${propType}${optional}${defaultValue}` + br
      codingKeys.push({name: propName})
    }else{
      text += `  let _${propName}: ${propType}?` + br
      text += `  var ${propName}: ${propType} {` + br
      text += `    get { return self._${propName} ?? ${defaultValue} }` + br
      text += `  }` + br
      codingKeys.push({name: `_${propName}`, key: propName})
    }
  }

  if(codingKeys.length > 0){
    text += br + `  private enum CodingKeys: String, CodingKey {` + br
    for(const codingKey of codingKeys){
      let key = ''
      if(codingKey.key){
        key = ` = "${codingKey.key}"`
      }
      text += `    case ${codingKey.name}${key}` + br
    }
    text += `  }` + br
  }

  text += '}' + br + br

  return text
}

// Main

// read schema json files
const readPromise = new Promise((resolve, reject) => {
  fs.readdir(schemaDirPath, (err, files) => {
    if(err){
      throw new Error(`readdir error: ${schemaDirPath}: ${err}`)
    }

    const promises = []
    for(const file of files){
      const filePath = `${schemaDirPath}/${file}`

      promises.push(new Promise((res, rej) => {
        fs.readFile(filePath, (err, data) => {
          if(err){
            throw new Error(`readFile error: ${file}: ${err}`)
          }
          schemas[file] = JSON.parse(data)
          res()
        })
      }))
    }
    Promise.all(promises).then(() => resolve())
  })
})

// resolve $ref values
readPromise.then(() => {

  // initialize promises
  for(const fileName in schemas){
    schemaPromises[fileName] = new Promise((resolve, reject) => {
      resolveFunctions[fileName] = resolve
      rejectFunctions[fileName] = reject
    })
  }

  for(const fileName in schemas){
    const json = schemas[fileName]

    // resolve $ref values
    const promises = resolveRef(json)
    Promise.all(promises).then(() => {
      resolveFunctions[fileName](json)
    })
  }

  return Promise.all(Object.values(schemaPromises))
}).then(() => {

  // convert json to swift
  for(const fileName in schemas){
    const json = schemas[fileName]
    const structName = getStructNameFromFileName(fileName, false)
    const swiftText = convertToSwift(json, structName)
    const swiftFilePath = `${swiftDirPath}/${structName}.swift`
    fs.writeFile(swiftFilePath, swiftText, (err) => {
      if(err){
        throw new Error(`writeFile error: ${swiftFileName}: ${err}`)
      }
    })
  }
})

