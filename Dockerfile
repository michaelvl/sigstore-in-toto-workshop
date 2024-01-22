FROM golang:1.21.6-alpine3.19 as builder

WORKDIR /app

COPY main.go go.mod go.sum ./
RUN go build -o main ./

####################
FROM scratch

WORKDIR /app

COPY --from=builder /app/main .

USER 10000
 
ENTRYPOINT ["/app/main"]
