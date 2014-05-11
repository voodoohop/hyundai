Template.camera.rendered = ->
  console.log("cam rendered", this, this.find("video"))
  if (this.data.isRemote)
    attachRemoteCamToVideoElement(this.find("video"))
  else
    startStreamingWebcam(this.find("video"), (element, stream) ->
      Meteor.setTimeout( ->
        #console.log("started streaming", element, element.videoWidth, stream)
        setState("camera",{mediaWidth: element.videoWidth, mediaHeight: element.videoHeight})
      ,500)
    )

