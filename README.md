# https-HIDS
Real-time HTTP Intrusion Detection

DockerFile - To create teler based container and ship needed logs to central server / Elastic server by using Logstash in the client end which can trim logs.

For user who want to use their existing server to ship logs from mobile agent container configure the IP and port in teler.yml

If you need your own server to be configured proceed below

install-elk-docker.sh - To create your elastic search server which will have only Elastic service and kibana service. Please note the logstash is kept in mobile agent to bring minimal logs to this server.

Other sample yml files as well present for reference.