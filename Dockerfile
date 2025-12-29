FROM golang:1.13 as builder
WORKDIR /app
COPY . ./
RUN CGO_ENABLED=0 GOOS=linux go build -o server

FROM alpine:3
RUN apk add --no-cache ca-certificates
COPY --from=builder /app/* /
CMD ["/server"]