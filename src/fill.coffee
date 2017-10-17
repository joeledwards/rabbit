amqp = require 'amqplib'
durations = require 'durations'
uuid = require 'uuid'

url = "amqp://localhost"
queueName = "bubbles"

messageCount = 10
watch = durations.stopwatch().start()

open = amqp.connect url

open
.then (conn) ->
  console.log "Producer connected."
  conn.createChannel()
  .then (chan) -> [conn, chan]

.then ([conn, chan]) ->
  console.log "Producer channel created."
  chan.assertQueue queueName
  .then -> [conn, chan]

.then ([conn, chan]) ->
  addMessage = (remaining) ->
    if remaining > 0
      now = new Date()
      record =
        id: uuid.v1()
        timestamp: now.toISOString()
        year: now.year
        month: now.month
        day: now.day
        hour: now.hour
        minute: now.minute
        second: now.second
      message = JSON.stringify(record)

      console.log "Adding message", message

      chan.sendToQueue queueName, Buffer.from(message)
      setImmediate -> addMessage(--remaining)
    else
      console.log "All messages published in #{watch}."
      conn.close()

  console.log "Publishing #{messageCount} messages to queue '#{queueName}'"
  addMessage messageCount

.catch (error) ->
  console.error "Error subscribing to queue '#{queueName}'", error

