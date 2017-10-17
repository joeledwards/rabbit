amqp = require 'amqplib'
durations = require 'durations'
uuid = require 'uuid'

args = require 'yargs'
  # Queue name
  .string 'queue'
  .alias 'queue', 'q'
  .default 'queue', 'messages'
  # Number of messages to generate
  .number 'fillCount'
  .alias 'fillCount', 'f'
  .default 'fillCount', 10
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

messageCount = args.fillCount
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

