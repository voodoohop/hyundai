
insertMediaFromEvent = (event) ->
  FS.Utility.eachFile event, (file) ->
    orderPos = 0
    existing = media.find().fetch()
    if (existing.length > 0)
      orderPos = _.max(existing, (m) -> m.rank)
    media.insert file, (err, fileObj) ->
      console.log(err,fileObj)
      meteor.update(file._id,{$set:{rank: orderPos+1}})


Template.mediauploader.events
  "dropped #dropzone": (event, template) ->
    insertMediaFromEvent(event)
  "change #fileselect": (event) ->
    insertMediaFromEvent(event)


Template.contentList.events
  "click .playbtn": (event) ->
    console.log(this)
    Meteor.call("playMedia", this._id, (err,res) -> console.log(err,res))
  "click .removebtn": (event) ->
    console.log(this)
    media.remove(this._id)
    Meteor.setTimeout(->
      Meteor.call("nextMedia")
    ,100)

Template.contentList.isCurrentlyPlaying = ->
  console.log("checking if currently playing", this)
  return (getCurrentPlayingMedia()?._id == this?._id)

Template.admin.rendered = ->
  attachRemoteCamToVideoElement("remote")



Template.contentList.sortedMedia = ->
  media.find {}, {sort: {rank: 1}}



SimpleRationalRanks =
  beforeFirst: (firstRank) ->
    firstRank - 1

  between: (beforeRank, afterRank) ->
    (beforeRank + afterRank) / 2

  afterLast: (lastRank) ->
    lastRank + 1

Template.contentList.rendered = ->
  # uses the 'sortable' interaction from jquery ui
  $(@find("#list")).sortable stop: (event, ui) -> # fired when an item is dropped
    el = ui.item.get(0)
    before = ui.item.prev().get(0)
    after = ui.item.next().get(0)
    newRank = undefined
    unless before # moving to the top of the list
      newRank = SimpleRationalRanks.beforeFirst(UI.getElementData(after).rank)
    else unless after # moving to the bottom of the list
      newRank = SimpleRationalRanks.afterLast(UI.getElementData(before).rank)
    else
      newRank = SimpleRationalRanks.between(UI.getElementData(before).rank, UI.getElementData(after).rank)
    media.update UI.getElementData(el)._id,
      $set:
        rank: newRank

    return

  return