context = null
Template.photoCanvas.rendered = ->
  context = this.find("#photoCanvas").getContext("2d")
@takePhoto = (videoElement,cameraElement)->
  context.drawImage(videoElement,0,0,100,100)