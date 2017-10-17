amqp = require 'amqplib'

url = "amqp://localhost"
queueName = "bubbles"


open = amqp.connect url

open
.then (conn) ->
  console.log "Producer connected."
  conn.createChannel()
.then (chan) ->
  console.log "Producer channel created."
  chan.assertQueue queueName
  .then (queue) ->
    console.log "Sending message."
    chan.sendToQueue queue, Buffer.from("cobra")
.catch (error) ->
  console.error "Error subscribing to queue '#{queueName}'", error

open
.then (conn) ->
  console.log "Consumer connected."
  conn.createChannel()
.then (chan) ->
  console.log "Consumer channel created."
  chan.assertQueue queueName
  .then (queue) ->
    chan.consume queue, (message) ->
      if message?
        console.log "Received message:", message
        chan.ack message
        conn.close()
.catch (error) ->
  console.error "Error subscribing to queue '#{queueName}'", error

