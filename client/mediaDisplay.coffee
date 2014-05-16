

videoPlayer = null

unloadVideo = ->
  console.log("unloading video",videoPlayer?.src)
  $(videoPlayer)?.removeAttr("src")
  videoPlayer?.load()

videoUpdateComputation = null

lastMediaId = null

Template.mediaDisplay.rendered = ->
  console.log("hyundai rendered",this)
  videoPlayer = this.find("#hyundai_vid")
  lastMediaId = null
  loadVideo(this.data.media)
  Meteor.videoPlayer = videoPlayer

  #trick to change video unloading previous one


window.onbeforeunload = ->
    unloadVideo()

Template.mediaDisplay.destroyed = ->
  console.log("mediaDisplay destroyed",this)
  unloadVideo()
  lastMediaId = null

loadVideo = (media) ->
  return null unless videoPlayer
  console.log("current media", media)
  return unless media
  mediaId = media._id
  if mediaId != lastMediaId
    lastMediaId = mediaId
    console.log("media changed src mediaId", videoPlayer.src,mediaId)
    unloadVideo()
    Meteor.setTimeout( ->
      console.log("loading and playing",mediaId)
      Meteor.FSCache(media.url()).then( (cachedURL) ->
        console.log("got cached url:"+cachedURL)
        $(videoPlayer).attr("src",cachedURL)
        videoPlayer.load()
      )
    ,100)

Template.mediaDisplay.reactiveVideoUpdater = ->
  loadVideo(this.media)
  return null

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
  unloadVideo()
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
      nextMedia()
      #Session.set("videosPlayed",Session.get("videosPlayed")+1)

  "loadeddata #hyundai_vid": () ->
    size = {mediaWidth: videoPlayer.videoWidth, mediaHeight: videoPlayer.videoHeight}
    console.log(this)

    m = this.media
    unless (m.mediaWidth == size.mediaWidth and m.mediaHeight==size.mediaHeigth)
      media.update(m._id, {$set: size})
    console.log("loaded video data")
    videoPlayer.play()


  "timeupdate #hyundai_vid": (event,tmplInstance) ->
    #if !this.loopMedia and event.target.currentTime > 1
    #  event.target.pause()
    #  nextMediaDebounced()
      #Session.set("videosPlayed",Session.get("videosPlayed")+1)

    if (this.media.usePhoto)
      time = event.target.currentTime
      if (time > this.media.photoSeconds)
        console.log("take photo...")
        takePhoto(tmplInstance.find("#hyundai_vid"),tmplInstance.find("#camera"))

