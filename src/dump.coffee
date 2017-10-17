amqp = require 'amqplib'
durations = require 'durations'

url = "amqp://localhost"
queueName = "bubbles"

readInterval = 1000
shouldAck = true

watch = durations.stopwatch().start()
count = 0

open = amqp.connect url

open
.then (conn) ->
  console.log "Consumer connected."
  conn.createChannel()
  .then (chan) -> [conn, chan]

.then ([conn, chan]) ->
  console.log "Consumer channel created."
  chan.assertQueue queueName
  .then -> [conn, chan]

.then ([conn, chan]) ->
  shutdown = ->
    conn.close()
    .then ->
      console.log "Consumed #{count} messages over #{watch}"

  # Close the connection after reading for the desired interval
  setTimeout shutdown, readInterval

  console.log "Consuming messages from queue '#{queueName}'"

  # Consume from the queue logging every message and
  # acknowleding if configured to do so
  chan.consume queueName, (message) ->
    if message?
      count++
      console.log "Received message: #{message.content}"
      #console.log "Received message:", message
      chan.ack message if shouldAck
.catch (error) ->
  console.error "Error subscribing to queue '#{queueName}'", error

