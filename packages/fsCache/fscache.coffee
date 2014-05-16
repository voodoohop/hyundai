
fileSystem = null

downloadFile = (url) ->
  return new Promise (resolve,reject) ->
    xhr = new XMLHttpRequest()
    xhr.open "GET", url, true
    xhr.responseType = "blob"
    xhr.onreadystatechange = ->
      resolve(xhr.response) if xhr.readyState is 4
    xhr.send null


saveFile = (data, path) ->
  return unless fileSystem
  console.log("attempting save", data, path)
  fileSystem.root.getFile( path, {create: true}, ((fileEntry) ->
    fileEntry.createWriter( (writer) ->
      console.log("writing data",data," to: ", fileEntry)
      writer.write data
    )
  ))

readFile = (path) ->
  return new Promise (resolve,reject) ->
    fileSystem.root.getFile path, {}, ((fileEntry) ->
      fileEntry.file ((file) ->
        reader = new FileReader()
        reader.onloadend = (e) ->
          resolve(@result)
        reader.readAsText file
      ), reject
    ), reject

existsFile = (fileName) ->
  return new Promise( (resolve) ->
    fileSystem.root.getFile fileName, {create: false}, (entry) ->
      resolve(entry)
    , ->
      resolve(false)
  )


Meteor.startup ->
  size = 1000*1024*1024
  navigator.webkitPersistentStorage.requestQuota size, ->
    window.webkitRequestFileSystem(window.PERMANENT, size,
    (fs) ->
      fileSystem = fs
      console.log("fsCache got FS",fs)
      Meteor.FSCache = (url) -> new Promise( (resolve) ->
        fileName = encodeURIComponent(url)
        console.log("cache file name", fileName)
        existsFile(fileName).then( (exists)->
          console.log("exists in cache:",exists)
          if (exists)
            console.log("returning file entry", exists)
            resolve(exists.toURL())
          else
            downloadFile(url).then( (data) ->
              console.log("downloaded ",url, " got:",data)
              saveFile(data, fileName)
            )
            resolve(url);
        )
      )
    , (err) ->
      console.log("fsCache err",err)
    );