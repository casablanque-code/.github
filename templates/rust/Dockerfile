# syntax=docker/dockerfile:1

FROM rust:1-slim AS build
ARG BIN=__NAME__
WORKDIR /src
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo build --locked --release \
 && cp "target/release/${BIN}" /app

FROM gcr.io/distroless/cc-debian12 AS runtime
USER nonroot:nonroot
COPY --from=build /app /app
ENTRYPOINT ["/app"]
