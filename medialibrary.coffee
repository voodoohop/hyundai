
@state = new Meteor.Collection("state")


@media = new FS.Collection("media",
  stores: [new FS.Store.FileSystem("media")] #, {path: ". /media_hyundai"})]
);


UI.registerHelper("mediaStore", ->
  console.log("media:",media)
  media.find {}, {sort: {rank: 1}}
)

@getCurrentPlayingMedia = ->
  mediaNo = state.findOne("media")?.currentPlaying
  console.log("current media no:"+mediaNo)
  if (mediaNo?)
    res =   media.find({}, {sort: {rank: 1}}).fetch()[mediaNo]
    console.log("currentMedia",res)
    return res
  else
    return null

@setClientAspectRatio = (aspectRatio) ->
  state.insert({_id:"clientScreen", aspectRatio: aspectRatio}) unless (state.findOne("clientScreen"))
  state.update("clientScreen",{$set:{aspectRatio: aspectRatio}})

@getClientAspectRatio = ->
  state.findOne("clientScreen")?.aspectRatio

if Meteor.isServer

  Meteor.startup ->

    state.insert({_id: "media", currentPlaying: 0}) unless (state.findOne("media"))

    Meteor.methods
      "nextMedia": ->
        next = (state.findOne("media").currentPlaying+1) % media.find().count()
        state.update("media", {$set: {currentPlaying: next}})
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
          state.update("media", {$set: {currentPlaying: mediaNo}})
        return mediaNo
