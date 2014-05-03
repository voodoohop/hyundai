if (Meteor.isClient)

  Router.map ->
    this.route("admin",
      path: "/admin"
    )
    this.route("hyundai",
      path: "/"
    )

  videoPlayer = null

  Meteor.startup ->
    Session.set("isFullscreen", document.webkitFullscreenElement?)


  Session.set("playingMedia",null)

  Template.hyundai.rendered = ->
    console.log("hyundai rendered",this)
    videoPlayer = this.find("#hyundai_vid")
    Meteor.videoPlayer = videoPlayer
    if this.data?.inAdminPanel
      Meteor.defer ->
        attachRemoteCamToVideoElement("camera")
    else
      document.documentElement.webkitRequestFullScreen()
      startStreamingWebcam("camera")
      setClientAspectRatio($(window).width() / $(window).height())
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

  Template.hyundai.currentMedia = ->
    getCurrentPlayingMedia()

  document.onwebkitfullscreenchange = (event) ->
    Session.set("isFullscreen", document.webkitFullscreenElement?)


