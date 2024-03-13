# syntax=docker/dockerfile:1

##
## Build the application from source
##

FROM golang:1.22.1 AS build-stage

WORKDIR /app

RUN go env -w GOCACHE=/go-cache && go env -w GOMODCACHE=/gomod-cache

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/gomod-cache \ 
    go mod download

COPY *.go ./

RUN --mount=type=cache,target=/gomod-cache \
    --mount=type=cache,target=/go-cache \
    CGO_ENABLED=0 GOOS=linux go build -o /docker-gs-ping

##
## Run the tests in the container
##

FROM build-stage AS run-test-stage

RUN go env -w GOCACHE=/go-cache && go env -w GOMODCACHE=/gomod-cache

RUN --mount=type=cache,target=/go-cache \
    --mount=type=cache,target=/gomod-cache \
    go test -v ./...

##
## Deploy the application binary into a lean image
##

FROM gcr.io/distroless/base-debian11 AS build-release-stage

WORKDIR /

COPY --from=build-stage /docker-gs-ping /docker-gs-ping

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/docker-gs-ping"]
