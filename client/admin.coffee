
insertImageFromEvent = (event) ->
  FS.Utility.eachFile event, (file) ->
    bgImages.insert file, (err, fileObj) ->
      console.log("uploading, image",fileObj)


insertMediaFromEvent = (event) ->
  FS.Utility.eachFile event, (file) ->
    orderPos = 0
    existing = getOrderedMedias().fetch()
    console.log("getting max order pos of existing",existing)
    if (existing.length > 0)
      orderPos = existing[existing.length-1].rank
    if (isNaN(orderPos) or ! orderPos?)
      orderPos = 0
    media.insert file, (err, fileObj) ->
      #Session.set("uploading")
      console.log("uploaded, orderPos",orderPos)
      console.log(err,fileObj)
      media.update(fileObj._id,{$set:{rank: orderPos+1}})


Template.mediauploader.events
  "dropped #dropzone": (event, template) ->
    insertMediaFromEvent(event)
  "change #fileselect": (event) ->
    insertMediaFromEvent(event)

Template.imageuploader.events
  "change #fileselect": (event) ->
    insertImageFromEvent(event)

Template.contentList.events
  "click .playbtn": (event) ->
    console.log(this)
    Meteor.call("playMedia", this._id, (err,res) -> console.log(err,res))
  "click .removebtn": (event) ->
    console.log(this)
    media.remove(this._id)
    Meteor.setTimeout(->
      Meteor.call("nextMedia")
    ,250)
  "click .alpha_check": ->
    media.update(this._id, {$set:{isAlpha: !this.isAlpha}})
  "click .full_height_check": ->
    media.update(this._id, {$set:{fullHeight: !this.fullHeight}})

  "change .bgImageSelector": (event) ->
    bgImgId = event.target.value
    console.log("selected bgimgid", bgImgId,this)
    media.update(this._id, {$set: {backgroundImage: bgImgId}})

Template.contentList.selectedBGImage = (mediaBGImage) ->
  console.log("selectedBGImage",this,mediaBGImage)
  return mediaBGImage == this._id

Template.contentList.isCurrentlyPlaying = ->
  console.log("checking if currently playing", this)
  return (getCurrentPlayingMedia()?._id == this?._id)

Template.admin.rendered = ->
  #attachRemoteCamToVideoElement("remote")

Template.admin.remoteViewWidth = -> 300
Template.admin.remoteViewHeight = -> 300/getClientAspectRatio()
Template.admin.scaleTransform = ->
  return cssTransforms([{scale3d: [300 / getState("clientScreen").width, 300 / getState("clientScreen").width,1]}])


SimpleRationalRanks =
  beforeFirst: (firstRank) ->
    firstRank - 1

  between: (beforeRank, afterRank) ->
    (beforeRank + afterRank) / 2

  afterLast: (lastRank) ->
    lastRank + 1


Template.admin.enabledStreaming = ->
  getState("media").adminRemoteViewEnabled

Template.admin.events
  "click .startstreamingbtn": ->
    setState("media",{ adminRemoteViewEnabled: ! getState("media").adminRemoteViewEnabled })

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