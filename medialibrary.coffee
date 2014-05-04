


@media = new FS.Collection("media",
  stores: [new FS.Store.FileSystem("media")] #, {path: ". /media_hyundai"})]
);


@getCurrentPlayingMedia = ->

  #console.log("media state", getState("media"))
  mediaNo = getState("media")?.currentPlaying
  #console.log("current media no:"+mediaNo)
  if (mediaNo?)
    res =   media.find({}, {sort: {rank: 1}}).fetch()[mediaNo]
    console.log("currentMedia",res)
    return res
  else
    return null


if Meteor.isClient
  @mediaSubscription = Meteor.subscribe "media"
  UI.registerHelper("mediaStore", ->
    #console.log("media:",media)
    media.find {}, {sort: {rank: 1}}
  )

if Meteor.isServer
  Meteor.publish("media",-> media.find({}))

  media.allow (
    insert: -> true
    update: -> true
    remove: -> true
  )

  setState("media", {currentPlaying: 0}) unless getState("media")

Meteor.startup ->

    Meteor.methods
      "nextMedia": ->
        next = (getState("media").currentPlaying+1) % media.find().count()
        setState("media", {currentPlaying: next})
        console.log("next media", next)
        return next
      "playMedia": (id) ->
        medias =  media.find( {}, {sort: {rank: 1}}).fetch()
        mediaNo = null
        _.each(medias, (m,i) ->
          if (m._id == id)
            mediaNo = i
        )
        if (mediaNo?)
          setState("media", {currentPlaying: mediaNo})
        return mediaNo
