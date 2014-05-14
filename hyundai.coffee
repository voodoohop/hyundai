#TODO try to remove the nocache hack again and somehow make it not crash loading video

FS.debug=true

if (Meteor.isClient)

  Router.map ->
    this.route("mediacalibrator",
      path: "/calibrate/:id"
      waitOn: ->
        [stateSubscription, mediaSubscription, bgImageSubscription]
      action: ->
        this.render() if this.ready()
      data: ->
        if (this.params.id == "camera")
          {media: null, calibrateCamera: true}
        else
          {media: media.findOne(this.params.id)}

    )
    this.route("admin",
      path: "/admin"
      waitOn: ->
        [stateSubscription, mediaSubscription, bgImageSubscription]
      action: ->
        this.render() if this.ready()
      data: ->
        {medias: getOrderedMedias(false), currentPlaying: getCurrentPlayingMedia(),  bgImages: bgImages.find()}
    )
    this.route("hyundaiDisplay",
      path: "/"
      waitOn: ->
        [stateSubscription, mediaSubscription, bgImageSubscription]
      action: ->
        console.log("hyundai route subscribe data ready", this.ready())
        this.render() if this.ready()
      data: ->
        {media: getCurrentPlayingMedia()}
    )



  Template.hyundaiDisplay.events
    "click .fsbutton": ->
      document.documentElement.webkitRequestFullScreen()



  Template.hyundaiDisplay.fullscreen = -> Session.get("isFullscreen")



  document.onwebkitfullscreenchange = (event) ->
    Session.set("isFullscreen", document.webkitFullscreenElement?)


if (Meteor.isServer)
  setState("media",{adminRemoteViewEnabled: false})