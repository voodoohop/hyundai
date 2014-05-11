


@media = new FS.Collection("media",
  stores: [new FS.Store.FileSystem("media")] #, {path: ". /media_hyundai"})]
)

@bgImages = new FS.Collection("bgimages",
  stores: [new FS.Store.FileSystem("bgimages")]
)


@getOrderedMedias = (uploadComplete=true) ->
  condition = if uploadComplete then {uploadedAt: {$exists: true}} else {}
  media.find(condition, {sort: {rank: 1}})

@getCurrentPlayingMedia = ->

  #console.log("media state", getState("media"))
  mediaId = getState("media")?.currentPlaying
  if (!mediaId?)
    medias = getOrderedMedias().fetch()
    return null if medias.length ==0
    first = medias[0]._id
    setState("media", {currentPlaying: first ? null})
    mediaId = first
  #console.log("current media no:"+mediaNo)
  if mediaId?
    return media.findOne(mediaId)
  else
    return null

if Meteor.isClient
  @mediaSubscription = Meteor.subscribe "media"
  @bgImageSubscription = Meteor.subscribe "bgimages"

if Meteor.isServer
  Meteor.publish("media",-> media.find({}))
  Meteor.publish("bgimages",-> bgImages.find({}))

  media.allow (
    insert: -> true
    update: -> true
    remove: -> true
  )
  bgImages.allow (
    insert: -> true
    update: -> true
    remove: -> true
  )

  setState("media", {currentPlaying: 0}) unless getState("media")

@getNextPlayingMedia = ->
  medias= getOrderedMedias().fetch()
  return null if medias.length == 0
  currentId = getState("media").currentPlaying
  currentNo = -1
  _.each(medias, (m,i) ->
    if m._id == currentId
      currentNo = i
  )
  nextMedia = medias[(currentNo+1) % medias.length]
  return nextMedia

Meteor.startup ->
  if Meteor.isServer
    Meteor.methods
      "nextMedia": ->
        next = getNextPlayingMedia()
        return null unless next?
        setState("media", {currentPlaying: next._id})
        console.log("next media", next)
        return next._id
      "playMedia": (id) ->

        setState("media", {currentPlaying: id})
        return id
