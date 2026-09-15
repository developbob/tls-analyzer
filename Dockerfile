# Build stage
FROM golang:1.25-alpine AS builder

ARG VERSION=dev
ARG COMMIT=none
ARG DATE=unknown

WORKDIR /src

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build the tlsanalyzer binary
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w -X main.version=${VERSION} -X main.commit=${COMMIT} -X main.date=${DATE}" \
    -o /usr/local/bin/tlsanalyzer ./cmd/tlsanalyzer

# Runtime stage
FROM alpine:3.19

RUN apk --no-cache add ca-certificates

WORKDIR /workspace

COPY --from=builder /usr/local/bin/tlsanalyzer /usr/local/bin/tlsanalyzer

ENTRYPOINT ["tlsanalyzer"]
CMD ["--help"]
