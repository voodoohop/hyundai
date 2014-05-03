if (Meteor.isServer)
  webRTC = Meteor.require('webrtc.io').listen(8001);
if (Meteor.isClient)
  rtc.connect('ws://localhost:8001');

  @startStreamingWebcam = (element = null) ->
    rtc.createStream
      video:
        mandatory:
          minWidth: 1280,
          minHeight: 720
    , (stream) ->
      rtc.attachStream(stream,element) if element
  @attachRemoteCamToVideoElement = (elementId) ->
    rtc.on('add remote stream', (stream) ->
      console.log("remote stream", stream, elementId)
      rtc.attachStream(stream, elementId);
      rtc.fire("ready")
    )