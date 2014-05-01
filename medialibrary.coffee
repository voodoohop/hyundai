
@state = new Meteor.Collection("state")


@media = new FS.Collection("media",
  stores: [new FS.Store.FileSystem("media", {path: "~/media_hyundai"})]
);


UI.registerHelper("mediaStore", ->
  console.log("media:",media)
  media.find()
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


if Meteor.isServer

  Meteor.startup ->

    state.insert({_id: "media", currentPlaying: 0}) unless (state.findOne("media"))

    Meteor.methods
      "nextMedia": ->
        next = (state.findOne("media").currentPlaying+1) % media.find().count()
        state.update("media", {$set: {currentPlaying: next}})
        console.log("next media", next)
        return next

