if (Meteor.isServer)
  webRTC = Meteor.require('webrtc.io').listen(8001);
if (Meteor.isClient)
  rtc.connect('ws://localhost:8001');

  @startStreamingWebcam = () ->
    rtc.createStream {video:true}, (stream) ->

  @attachRemoteCamToVideoElement = (elementId) ->
    rtc.on('add remote stream', (stream) ->
      console.log("remote stream", stream, elementId)
      rtc.attachStream(stream, elementId);
    )