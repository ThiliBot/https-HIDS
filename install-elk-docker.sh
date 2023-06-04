#!/bin/bash
#use this if you need your own log server instance to get logs from Mobile agent. If you have existing ELK or central log server then configure those server entry point in Docker file of mobile agent
# Create a Docker network for the containers
docker network create elk

# Start Elasticsearch container
docker run -d \
  --name elasticsearch \
  --net elk \
  -p 9200:9200 \
  -p 9300:9300 \
  -e "discovery.type=single-node" \
  elasticsearch:7.12.0

# Wait for Elasticsearch to start up
sleep 30

# Start Kibana container
docker run -d \
  --name kibana \
  --net elk \
  -p 5601:5601 \
  kibana:7.12.0


#docker run -d --name logstash --net elk -v /path/to/logstash/config:/usr/share/logstash/pipeline/ -p 9600:9600 logstash:7.12.0
docker run -d --net elk --name ids-mobileagent -v /var/log/nginx:/var/log/nginx ids-mobileagent
