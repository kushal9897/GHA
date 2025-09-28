FROM ghcr.io/fintronners/base-go:latest AS builder

WORKDIR /app

copy . . /

RUN go mod tidy
# GOMAXPROCS to control memory use during compilation
# GOMEMLIMIT to control CPU use during compilation
RUN GOOS=linux GOARCH=amd64 GOMEMLIMIT=12GiB GOMAXPROCS=2 go build --tags=UAT -o build/ftron/ftron cmd/ftron/main.go

FROM --platform=linux/amd64 alpine:3

WORKDIR /app

RUN apk update && apk add --no-cache tzdata

COPY --from=builder /app/build/ftron .

CMD ["./build/ftron/ftron"]