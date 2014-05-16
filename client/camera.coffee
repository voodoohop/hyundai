Template.camera.rendered = ->
  console.log("cam rendered", this, this.find("video"))
  if (this.data.isRemote)
    attachRemoteCamToVideoElement(this.find("video"))
  else
    MediaStreamTrack.getSources( (sources) ->
      videoSources = _.filter(sources, (s)-> s.kind == "video")
      setState("camera", {sources: videoSources})
    )
    if (getState("camera").selectedPrimaryCam)
      startStreamingWebcam(this.find("video"), getState("camera").selectedPrimaryCam, (element, stream) ->
        Meteor.setTimeout( ->
          #console.log("started streaming", element, element.videoWidth, stream)
          setState("camera",{mediaWidth: element.videoWidth, mediaHeight: element.videoHeight})
        ,500)
      )

