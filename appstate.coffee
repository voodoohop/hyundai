
broadcastStream = new Meteor.Stream("hyundai_broadcast_stream")

state = new Meteor.Collection("state")

if (Meteor.isServer)
  Meteor.publish("state", -> state.find())

  state.allow (
    insert: -> true
    update: -> true
    remove: -> true
  )

readyHandlers = []
subscriptionReadyHandler = ->
  _.each(readyHandlers, (handler) -> handler())

@onStateAvailable = (handler) ->
  readyHandlers.push(handler)

if Meteor.isClient
  @stateSubscription = Meteor.subscribe("state", subscriptionReadyHandler)

@getState = (category) ->
  if (Meteor.isClient)
    if !stateSubscription.ready()
      console.log("WARNING: trying to get state information but subscription not ready yet")
      console.trace()

  state.findOne(category)

@setState = (category, props) ->
  if (Meteor.isClient)
    if ! stateSubscription.ready()
      onStateAvailable( -> setState(category,props))
      return

  if (state.findOne(category))
    state.update(category, {$set: props})
  else
    console.log("inserting into state", {_id:category}, props)
    state.insert(_.extend({_id: category},props))

@setClientAspectRatio = (aspectRatio) ->
  state.insert({_id:"clientScreen", aspectRatio: aspectRatio}) unless (state.findOne("clientScreen"))
  state.update("clientScreen",{$set:{aspectRatio: aspectRatio}})

@getClientAspectRatio = ->
  state.findOne("clientScreen")?.aspectRatio


@broadcastMessage = (category, message) ->
  broadcastStream.emit(category, message)

@broadcastListen = (category, handler) ->
  broadcastStream.on(category, handler)