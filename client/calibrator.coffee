

calcSize = ->
  ar = getClientAspectRatio()
  w = $(window).width()-50
  h = $(window).height()-50
  if (h*ar > w)
    h= w / ar
  else
    w= h*ar
  return {width:w, height:h}

Template.mediacalibrator.rotateMode = -> Session.get("rotateMode")

traqball = null
Template.mediacalibrator.rendered = ->
  scale= calcSize().width / getState("clientScreen").width
  tx =0
  ty =0
  sx=0
  sy=0
  rx=0
  ry=0
  m = this.data.media
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
    media.update(m._id, {$set: {transform: {translateX: 0, translateY: 0, scaleX: 1, scaleY: 1, rotateX: 0, rotateY: 0}}})

  console.log("making draggable",m)
  interact($("#video_holder")[0]).draggable(
    onstart: -> console.log("dragstart")
    onend: -> console.log("dragend")
    onmove: (e) ->
      if (!Session.get("rotateMode"))
        tx += e.dx/scale
        ty += e.dy/scale
        console.log("updating tx,ty",tx,ty)
        media.update(m._id, {$set: {"transform.translateX":tx, "transform.translateY":ty}})
      else
        ry += e.dx/5.0
        rx += e.dy/5.0
        console.log("updating rx,ry",rx,ry)
        media.update(m._id, {$set: {"transform.rotateX": rx, "transform.rotateY": ry}})

  )
  interact($("#video_holder")[0]).resizable(
    onstart: -> console.log("resizestart")
    onend: -> console.log("resizeend")
    onmove: (e) ->
      console.log("resize move",e)
      sx += e.dx/scale if e.dx
      sy += e.dy/scale if e.dy
      console.log("got new sx,sy,edx,edy",sx,sy, e.dx, e.dy)
      media.update(m._id, {$set: {"transform.scaleX":(m.mediaWidth+sx)/m.mediaWidth, "transform.scaleY": (m.mediaHeight+sy)/m.mediaHeight}})
  )
  #traqball = new Traqball({stage:"video_holder", impulse:false, perspective: 400})
  #traqball.disable()

Template.mediacalibrator.events
  "click button": ->
    rotateMode = !Session.get("rotateMode")
    Session.set("rotateMode", rotateMode)
    #if rotateMode
    #  traqball.activate()
    #  interact.enableDragging(false)
    #  interact.enableResizing(false)
    #else
    #  traqball.disable()
    #  interact.enableDragging(true)
    #  interact.enableResizing(true)

Template.mediacalibrator.scaleTransform = ->
  return cssTransforms([{scale3d: [calcSize().width / getState("clientScreen").width, calcSize().height / getState("clientScreen").height,1]}])