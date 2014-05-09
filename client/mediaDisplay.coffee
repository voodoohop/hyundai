

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

    document.documentElement.webkitRequestFullScreen()
    #startStreamingWebcam("camera")
    setClientAspectRatio($(window).width(),$(window).height())
    $(window).resize ->
      setClientAspectRatio($(window).width(),$(window).height())


lastVideoURL = null
Template.mediaDisplay.videoURL = ->
  videoURL = this.media.url()
  if lastVideoURL != videoURL
    lastVideoURL = videoURL
    console.log("playing video at URL:",videoURL)
    Meteor.setTimeout( ->
      videoPlayer.src = videoURL+"?noCache="+ _.random(0,100000)
      videoPlayer.load()
      videoPlayer.play()
    ,100)
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

Template.mediaDisplay.events
  "ended #hyundai_vid": (e,tmplInst) ->
    console.log("ended",this,tmplInst)
    if this.loopMedia
      videoPlayer.load()
      videoPlayer.play()
    else
      nextMedia()

  "loadeddata": () ->
    size = {mediaWidth: videoPlayer.videoWidth, mediaHeight: videoPlayer.videoHeight}
    console.log(this)

    m = this.media
    unless (m.mediaWidth == size.mediaWidth and m.mediaHeight==size.mediaHeigth)
      media.update(m._id, {$set: size})
    console.log("loaded video data")
