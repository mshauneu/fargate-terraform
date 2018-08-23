FROM golang:latest

ADD . /go/src/github.com/mshauneu/golang-docker

RUN go install github.com/mshauneu/golang-docker

ENTRYPOINT ["/go/bin/golang-docker"]

EXPOSE 3000 