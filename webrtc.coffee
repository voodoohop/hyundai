if (Meteor.isServer)
  webRTC = Meteor.require('webrtc.io').listen(8011);


if (Meteor.isClient)
  console.log("webrtc connecting to ",'ws://'+location.hostname+':8001','hyundai')
  rtc.connect('ws://'+location.hostname+':8011','hyundai');

  previousStream = null
  @startStreamingWebcam = (element = null, camId = null, callback = null) ->
    if previousStream?
      rtc.attachStream(previousStream,element) if element
      callback?(element, previousStream)
      return
    rtc.createStream
      video:
        mandatory:
          minWidth: 1280
          minHeight: 720
          sourceId: camId
    , (stream) ->
      rtc.attachStream(stream,element) if element
      previousStream = stream
      callback?(element, stream)

  @stopStreamingWebcam = (element =null) ->
    #nothing yet
    return false

  @attachRemoteCamToVideoElement = (elementId) ->
    if previousStream?
      rtc.attachStream(previousStream, elementId);
      return
    rtc.on('add remote stream', (stream) ->
      console.log("remote stream", stream, elementId)
      rtc.attachStream(stream, elementId);
      previousStream = stream;
    )
    rtc.fire("ready")
