#TODO try to remove the nocache hack again and somehow make it not crash loading video

if (Meteor.isClient)

  Router.map ->
    this.route("admin",
      path: "/admin"
      waitOn: ->
        [stateSubscription, mediaSubscription]
      action: ->
        this.render() if this.ready()
    )
    this.route("hyundai",
      path: "/"
      waitOn: ->
        [stateSubscription, mediaSubscription]
      action: ->
        console.log("hyundai route subscribe data ready", this.ready())
        this.render() if this.ready()
    )

  videoPlayer = null

  Meteor.startup ->
    Session.set("isFullscreen", document.webkitFullscreenElement?)


  Session.set("playingMedia",null)

  #loadMedia = (media) ->
  #  videoPlayer.src = media.url()


  Template.hyundai.rendered = ->
    console.log("hyundai rendered",this)
    videoPlayer = this.find("#hyundai_vid")

    Meteor.videoPlayer = videoPlayer
    console.log("setting video player source")
    #console.log("getCurrentPlayingMedia",getCurrentPlayingMedia())
    #loadMedia(getCurrentPlayingMedia())

    if this.data?.inAdminPanel
      Meteor.defer ->
        attachRemoteCamToVideoElement("camera")
    else
      document.documentElement.webkitRequestFullScreen()
      startStreamingWebcam("camera")
#      Deps.autorun ->
#        if (getState("media").adminRemoteViewEnabled)
#          startStreamingWebcam("camera")
#        else
#          stopStreamingWebcam("camera")
      setClientAspectRatio($(window).width() / $(window).height())

    lastVideoURL = null
    Deps.autorun ->
      videoURL = getCurrentPlayingMedia().url()
      if (lastVideoURL != videoURL)
        lastVideoURL = videoURL
        console.log("playing video at URL:",videoURL)
        videoPlayer.src = videoURL+"?noCache="+ _.random(0,100000)

        videoPlayer.load()
        videoPlayer.play()


  nextMedia = ->
    Meteor.call("nextMedia", (err,newMedia) ->
      console.log("media loaded",err,newMedia)

#      Meteor.setTimeout(
#        videoPlayer?.load?()
#      ,200)
    )
  Template.hyundai.events
    "click .fsbutton": ->
      document.documentElement.webkitRequestFullScreen()

    "ended #hyundai_vid": ->
      console.log("ended")
      nextMedia()

    "timeupdate .hyundai_vid": (e)->
      #console.log("timeupdate",e)

  Template.hyundai.fullscreen = -> Session.get("isFullscreen")

  Template.hyundai.media = ->
    media.find()
  Template.hyundai.currentMedia = ->
    #console.log("current playing media res",getCurrentPlayingMedia())
   getCurrentPlayingMedia()

  document.onwebkitfullscreenchange = (event) ->
    Session.set("isFullscreen", document.webkitFullscreenElement?)


if (Meteor.isServer)
  setState("media",{adminRemoteViewEnabled: false})