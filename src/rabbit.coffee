amqp = require 'amqplib'

url = "amqp://localhost"
queueName = "bubbles"


open = amqp.connect url
conn = undefined

open
.then (c) ->
  conn = c
  console.log "Producer connected."
  conn.createChannel()
.then (chan) ->
  console.log "Producer channel created."
  chan.assertQueue queueName
  .then ->
    console.log "Sending message."
    chan.sendToQueue queueName, Buffer.from("cobra")
.catch (error) ->
  console.error "Error subscribing to queue '#{queueName}'", error

open
.then (c) ->
  conn = c
  console.log "Consumer connected."
  conn.createChannel()
.then (chan) ->
  console.log "Consumer channel created."
  chan.assertQueue queueName
  .then ->
    chan.consume queueName, (message) ->
      if message?
        console.log "Received message: #{message.content}"
        chan.ack message
        conn.close()
.catch (error) ->
  console.error "Error subscribing to queue '#{queueName}'", error

