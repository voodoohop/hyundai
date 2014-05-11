

calcSize = ->
  ar = getClientAspectRatio()
  w = Session.get("windowSize")[0]-50
  h = Session.get("windowSize")[1]-50
  if (h*ar > w)
    h= w / ar
  else
    w= h*ar
  return {width:w, height:h}

Template.mediacalibrator.rotateMode = -> Session.get("rotateMode")

Meteor.startup ->
  (updateWindowSize = -> Session.set("windowSize", [$(window).width(),$(window).height()]))()
  $(window).resize ->
    updateWindowSize()

traqball = null
Template.mediacalibrator.rendered = ->
  scale= calcSize().width / getState("clientScreen").width
  tx =0
  ty =0
  sx=0
  sy=0
  rx=0
  ry=0

  isCam = this.data.calibrateCamera
  if isCam
    m = getState("camera")
  else
    m = this.data.media

  saveTransform = (props) ->
    if isCam
      setState("camera", props)
    else
      media.update(m._id, {$set: props})

  t = {}
  if (m.transform)
    console.log("before reading previous tranform data",m)
    t = m.transform
    tx = t.translateX if t.translateX?
    ty = t.translateY if t.translateY?
    sx = t.scaleX*m.mediaWidth-m.mediaWidth if t.scaleX?
    sy = t.scaleY*m.mediaHeight-m.mediaHeight if t.scaleY?
    rx = t.rotateX if t.rotateX?
    ry = t.rotateY if t.rotateY?
  else
    saveTransform({transform: {translateX: 0, translateY: 0, scaleX: 1, scaleY: 1, rotateX: 0, rotateY: 0}})

  console.log("making draggable",m)
  interactElement = if isCam then $("#camera_holder")[0] else $("#video_holder")[0]
  interact(interactElement).draggable(
    onstart: -> console.log("dragstart")
    onend: -> console.log("dragend")
    onmove: (e) ->
      if (!Session.get("rotateMode"))
        tx += e.dx/scale
        ty += e.dy/scale
        console.log("updating tx,ty",tx,ty)

        saveTransform({"transform.translateX":tx, "transform.translateY":ty})
      else
        ry += e.dx/5.0
        rx += e.dy/5.0
        console.log("updating rx,ry",rx,ry)
        saveTransform({"transform.rotateX": rx, "transform.rotateY": ry})

  )
  interact(interactElement).resizable(
    onstart: -> console.log("resizestart")
    onend: -> console.log("resizeend")
    onmove: (e) ->
      console.log("resize move",e)
      sx += e.dx/scale if e.dx
      sy += e.dy/scale if e.dy
      console.log("got new sx,sy,edx,edy",sx,sy, e.dx, e.dy)
      saveTransform({"transform.scaleX":(m.mediaWidth+sx)/m.mediaWidth, "transform.scaleY": (m.mediaHeight+sy)/m.mediaHeight})
  )

Template.mediacalibrator.events
  "click button": ->
    rotateMode = !Session.get("rotateMode")
    Session.set("rotateMode", rotateMode)


Template.mediacalibrator.scaleTransform = ->
  return cssTransforms([{scale3d: [calcSize().width / getState("clientScreen").width, calcSize().height / getState("clientScreen").height,1]}])