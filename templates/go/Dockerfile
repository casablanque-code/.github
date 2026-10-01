# syntax=docker/dockerfile:1

FROM golang:1.26-alpine AS build
ARG VERSION=dev
WORKDIR /src
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" -o /out/__NAME__ ./cmd/__NAME__

FROM gcr.io/distroless/static-debian12 AS runtime
USER nonroot:nonroot
COPY --from=build /out/__NAME__ /__NAME__
ENTRYPOINT ["/__NAME__"]
