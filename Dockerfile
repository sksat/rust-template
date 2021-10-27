FROM gcr.io/distroless/cc
LABEL maintainer "sksat <sksat@sksat.net>"

# get package name
FROM rust:1.56.0 as metadata
WORKDIR metadata
RUN apt-get update -y && apt-get install -y jq
ADD . .
RUN cargo metadata --format-version=1 | jq --raw-output '.packages[0].name' > app_name

# build
FROM rust:1.56.0 as builder
WORKDIR build
ADD . .
RUN cargo build --release

# change binary name to /app/bin
FROM alpine as tmp
WORKDIR app
COPY --from=metadata /metadata/app_name /tmp
COPY --from=builder /build/target/release /build
RUN cp /build/$(cat /tmp/app_name) bin

FROM gcr.io/distroless/cc
WORKDIR app
COPY --from=tmp /app/bin .
CMD ["/app/bin"]
