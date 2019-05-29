FROM golang:1.12.5-alpine3.9 as builder

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
ENV GO111MODULE=on

RUN apk update && apk add --no-cache git ca-certificates tzdata && update-ca-certificates

RUN adduser -D -g '' appuser

ADD . ${GOPATH}/src/app/
WORKDIR ${GOPATH}/src/app

RUN go build -mod=vendor -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/microproxy

FROM scratch


COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd

COPY --from=builder /go/bin/microproxy /go/bin/microproxy

USER appuser

ENTRYPOINT [ "/go/bin/microproxy" ]