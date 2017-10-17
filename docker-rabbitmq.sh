#!/bin/bash

# Launch a RabbitMQ container for testing
docker run \
  --publish 4369:4369 \
  --publish 5671:5671 \
  --publish 5672:5672 \
  --publish 25672:25672 \
  --daemon \
  --rm \
  --name=rabbitmq \
  rabbitmq:3.6.12
