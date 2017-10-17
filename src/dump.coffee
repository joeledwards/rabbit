amqp = require 'amqplib'
durations = require 'durations'

args = require 'yargs'
  # Queue name
  .string 'queue'
  .alias 'queue', 'q'
  .default 'queue', 'messages'
  # Duration to listen for messages
  .number 'duration'
  .alias 'duration', 'd'
  .default 'duration', 1000
  # RabbitMQ hostname
  .string 'host'
  .alias 'host', 'h'
  .default 'host', 'localhost'
  # RabbitMQ port
  .number 'port'
  .alias 'port', 'p'
  .default 'port', 5672
  # Authentication (optional)
  .string 'username'
  .alias 'username', 'U'
  .string 'password'
  .alias 'password', 'P'
  # Require both if either is supplied
  .implies 'username', 'password'
  .implies 'password', 'username'
  # Custom v-host
  .string 'vhost'
  .alias 'vhost', 'v'
  # Extract arguments
  .argv

auth = if args.username? then "#{args.username}:#{args.password}@" else ""
server = "#{args.host}:#{args.port}"
vhost = if args.vhost? then "/#{args.vhost}" else ""

url = "amqp://#{auth}#{server}#{vhost}"
queueName = args.queue

readDuration = 1000
shouldAck = false

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

  # Close the connection after reading for the desired duration
  setTimeout shutdown, readDuration

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

