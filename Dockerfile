# syntax=docker/dockerfile:1

FROM golang:1.22.1 AS dependencies

ARG CI_PROJECT_DIR

WORKDIR $CI_PROJECT_DIR

##
## Build the application from source
##

FROM golang:1.22.1 AS build-stage

ARG CI_PROJECT_DIR

WORKDIR /app

RUN go env -w GOMODCACHE=/app/cache/modcache
RUN go env -w GOCACHE=/app/cache/buildcache

COPY --from=dependencies $CI_PROJECT_DIR/go.mod $CI_PROJECT_DIR/go.sum ./

RUN go mod download

COPY --from=dependencies $CI_PROJECT_DIR/cache ./cache
COPY --from=dependencies $CI_PROJECT_DIR/*.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /docker-gs-ping

##
## Run the tests in the container
##

FROM build-stage AS run-test-stage
RUN go test -v ./...

##
## Deploy the application binary into a lean image
##

FROM gcr.io/distroless/base-debian11 AS build-release-stage

WORKDIR /

COPY --from=build-stage /docker-gs-ping /docker-gs-ping

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/docker-gs-ping"]
