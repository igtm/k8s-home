# syntax=docker/dockerfile:experimental
FROM golang:1.19.2 AS build

RUN mkdir -p /go/src

WORKDIR /go/src
COPY . /go/src

RUN --mount=type=ssh \
    --mount=type=cache,target=/go/pkg \
    --mount=type=cache,target=/root/.cache \
    mkdir -p -m 0600 ~/.ssh && ssh-keyscan -H github.com >> ~/.ssh/known_hosts && \
    git config --global url.ssh://git@github.com.insteadOf https://github.com  && \
    GOOS=linux GOARCH=arm64 go build -o ping .


FROM gcr.io/distroless/base
WORKDIR /root/
COPY . .

COPY --from=build /go/src/ping /usr/local/bin/ping

CMD ["ping"]
