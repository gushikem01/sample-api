# Use the offical golang image to create a binary.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.18-buster as builder

# Create and change to the app directory.
WORKDIR /go/src

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
# Expecting to copy go.mod and if present go.sum.
COPY go.* ./
RUN go mod download

# Copy local code to the container image.
# COPY . ./
COPY . .

# Build the binary.
# RUN go build -mod=readonly -v -o main
RUN CGO_ENABLED=0 GOOS=linux go build -mod=readonly -v -o main

# Use the official Debian slim image for a lean production container.
# https://hub.docker.com/_/debian
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM debian:buster-slim
RUN set -x && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates && \
  rm -rf /var/lib/apt/lists/*

EXPOSE 8080
# Copy the binary to the production image from the builder stage.
COPY --from=builder /go/src/main /main
ENTRYPOINT ["/main"]