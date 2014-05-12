

videoPlayer = null

Template.mediaDisplay.rendered = ->
  console.log("hyundai rendered",this)
  videoPlayer = this.find("#hyundai_vid")

  Meteor.videoPlayer = videoPlayer
  console.log("setting video player source")
  #console.log("getCurrentPlayingMedia",getCurrentPlayingMedia())
  #loadMedia(getCurrentPlayingMedia())

  if this.data.isRemote
    #Meteor.defer ->
    #  attachRemoteCamToVideoElement("camera")
  else

    setClientAspectRatio($(window).width(),$(window).height())
    $(window).resize ->
      setClientAspectRatio($(window).width(),$(window).height())


Meteor.startup ->
  Session.set("videosPlayed", 0)

Template.mediaDisplay.videoURL = ->
  videoURL = this.media.url()+"?sequenceNo_forNoCache="+Session.get("videosPlayed")
  return videoURL

Template.mediaDisplay.nextVideoURL = ->
  nextVideo = if this.loopMedia then this.media else this.nextMedia
  videoURL = nextVideo.url()+"?sequenceNo_forNoCache="+(Session.get("videosPlayed")+1)
  return videoURL


nextMedia = ->
  Meteor.call("nextMedia", (err,newMedia) ->
    console.log("media loaded",err,newMedia)

#      Meteor.setTimeout(
#        videoPlayer?.load?()
#      ,200)
  )

Template.mediaDisplay.backgroundImage = ->
  return null unless this.media.backgroundImage
  return bgImages.findOne(this.media.backgroundImage)

mediaCssTransforms = (m) ->
  console.log("csstransforms", this)
  return unless m.transform
  transforms =[
    {rotateX: [""+m.transform.rotateX.toFixed(3)+"deg"]}
    {rotateY: [""+m.transform.rotateY.toFixed(3)+"deg"]}
    {translate3d: [""+m.transform.translateX.toFixed(3)+"px", ""+m.transform.translateY.toFixed(3)+"px","0px"]}
    {scale3d: [m.transform.scaleX.toFixed(3), m.transform.scaleY.toFixed(3),1]}
  ]
  return cssTransforms(transforms);

Template.mediaDisplay.csstransforms = ->
  return mediaCssTransforms(this.media)

Template.mediaDisplay.mediaStyle = ->
  if (this.media.fullHeight)
    return "height: 100%; width: auto; margin: auto;"
  else
    return "width: #{this.media.mediaWidth}px; height: #{this.media.mediaHeight}px; -webkit-transform: #{mediaCssTransforms this.media}"

Template.mediaDisplay.cameraStyle = ->
  if (this.fullHeight)
    return "height: 100%; width: auto; margin: auto;"
  else
    return "width: #{this.mediaWidth}px; height: #{this.mediaHeight}px; -webkit-transform: #{mediaCssTransforms this}"

Template.mediaDisplay.events
  "ended #hyundai_vid": (e,tmplInst) ->
    console.log("ended",this,tmplInst)
    if this.loopMedia
      Session.set("videosPlayed",Session.get("videosPlayed")+1)
    else
      nextMedia()
      Session.set("videosPlayed",Session.get("videosPlayed")+1)

  "loadeddata #hyundai_vid": () ->
    size = {mediaWidth: videoPlayer.videoWidth, mediaHeight: videoPlayer.videoHeight}
    console.log(this)

    m = this.media
    unless (m.mediaWidth == size.mediaWidth and m.mediaHeight==size.mediaHeigth)
      media.update(m._id, {$set: size})
    console.log("loaded video data")
  "timeupdate #hyundai_vid": (event,tmplInstance) ->
    if (this.media.usePhoto)
      time = event.target.currentTime
      if (time > this.media.photoSeconds)
        console.log("take photo...")
        takePhoto(tmplInstance.find("#hyundai_vid"),tmplInstance.find("#camera"))

