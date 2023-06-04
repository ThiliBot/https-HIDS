FROM golang:1.18-buster as build

ARG VERSION

LABEL description="Real-time HTTP Intrusion Detection"
LABEL repository="https://github.com/kitabisa/teler"
LABEL maintainer="dwisiswant0"

WORKDIR /app

# download teler code from the repository
RUN git clone https://github.com/kitabisa/teler.git .

COPY go.mod .
RUN echo "go.mod file content: " && cat go.mod && go mod download && echo "Downloaded files in go.mod:" && ls -la && ls -la /go/pkg/mod

# Install nginx
RUN apt-get update && apt-get install -y nginx

# Copy teler.yaml file
COPY teler.yaml /app/

RUN echo "Copied source files to /app directory:" && ls -la && CGO_ENABLED=0 go build -ldflags \
        "-s -w -X teler.app/common.Version=${VERSION}" \
        -o ./bin/teler .

FROM docker.elastic.co/logstash/logstash:7.16.3

USER root

COPY --from=build /app/bin/teler /bin/teler
COPY --from=build /app/teler.yaml /app/teler.yaml
COPY logstash.conf /usr/share/logstash/pipeline/logstash.conf
COPY logstash.yml /usr/share/logstash/config/logstash.yml

# Create access log file and directory
RUN mkdir -p /var/log/nginx
RUN touch /var/log/nginx/access.log
RUN chown -R logstash:logstash /var/log/nginx
RUN mkdir -p /usr/share/logstash/logs

# Copy access log file from host - to just keep a copy and this will be replaced with the mounted log file used in docker entry point
COPY access.log /var/log/nginx/access.log
COPY logstash-plain.log /usr/share/logstash/logs

# Add a volume for the logs
VOLUME /var/log/nginx

ENV HOME /


ENTRYPOINT ["sh", "-c", "/usr/share/logstash/bin/logstash -f /usr/share/logstash/pipeline/logstash.conf & tail -f /var/log/nginx/access.log | /bin/teler -c /app/teler.yaml"]
