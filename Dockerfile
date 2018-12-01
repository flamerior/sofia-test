# Stage 1. Build the binary
FROM golang:1.11

ENV RELEASE 0.0.1

# add a non-privileged user
RUN useradd -u 10001 myapp

RUN mkdir -p /go/src/github.com/flamerior/sofia-test
ADD . /go/src/github.com/flamerior/sofia-test
WORKDIR /go/src/github.com/flamerior/sofia-test

# build the binary with go build
RUN CGO_ENABLED=0 go build \
	-ldflags "-s -w -X github.com/flamerior/sofia-test/internal/version.Version=${RELEASE}" \
	-o bin/go-sofia sofia-test/cmd/go-sofia

# Stage 2. Run the binary
FROM scratch

ENV PORT 8080
ENV DIAG_PORT 8585

COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=0 /etc/passwd /etc/passwd
USER myapp

COPY --from=0 /go/src/github.com/flamerior/sofia-test/bin/go-sofia /go-sofia
EXPOSE $PORT
EXPOSE $DIAG_PORT

CMD ["/go-sofia"]
