

videoPlayer = null
nextVideoPlayer = null

Template.mediaDisplay.rendered = ->
  console.log("hyundai rendered",this)
  videoPlayer = this.find("#hyundai_vid")
  nextVideoPlayer = this.find("#next_hyundai_vid")

  Meteor.videoPlayer = videoPlayer
  console.log("setting video player source")
  #console.log("getCurrentPlayingMedia",getCurrentPlayingMedia())
  #loadMedia(getCurrentPlayingMedia())

  if this.data.isRemote
    #Meteor.defer ->
    #  attachRemoteCamToVideoElement("camera")
  else

    #setClientAspectRatio($(window).width(),$(window).height())
    #$(window).resize ->
    #  setClientAspectRatio($(window).width(),$(window).height())

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


nextMediaWithVideoUnload = ->
  $(videoPlayer).prop("src",false)
  #$(nextVideoPlayer).prop("src",false)
  videoPlayer.src=false
  videoPlayer.load()
  #nextVideoPlayer.load()
  Meteor.setTimeout( ->
    nextMedia()
  ,100)

nextMediaDebounced = _.debounce( ->
  nextMediaWithVideoUnload()
,300)


Template.mediaDisplay.events
  "ended #hyundai_vid": (e,tmplInst) ->
    console.log("ended",this,tmplInst)
    unless this.isRemote
      nextMediaWithVideoUnload()
      #Session.set("videosPlayed",Session.get("videosPlayed")+1)

  "loadeddata #hyundai_vid": () ->
    size = {mediaWidth: videoPlayer.videoWidth, mediaHeight: videoPlayer.videoHeight}
    console.log(this)

    m = this.media
    unless (m.mediaWidth == size.mediaWidth and m.mediaHeight==size.mediaHeigth)
      media.update(m._id, {$set: size})
    console.log("loaded video data")
  "timeupdate #hyundai_vid": (event,tmplInstance) ->
    #if !this.loopMedia and event.target.currentTime > 1
    #  event.target.pause()
    #  nextMediaDebounced()
      #Session.set("videosPlayed",Session.get("videosPlayed")+1)

    thata = this
    if (this.media.usePhoto)
      time = event.target.currentTime
      if (time > this.media.photoSeconds)
        console.log("take photo...")
        takePhoto(tmplInstance.find("#hyundai_vid"),tmplInstance.find("#camera"))

