ARG GOLANG_VERSION=1.26
FROM golang:${GOLANG_VERSION}-alpine AS build
ARG TARGETOS
ARG TARGETARCH

WORKDIR /tmp/duckdns-go

RUN apk --no-cache add ca-certificates
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags '-s -w' -o duckdns-go ./

FROM scratch
LABEL name="duckdns-go"

WORKDIR /root
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /tmp/duckdns-go/duckdns-go duckdns-go

CMD ["./duckdns-go", "-update-ip"]
