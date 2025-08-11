# ---------- Build Stage ----------
FROM golang:1.24.4 AS builder

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum for dependency caching
COPY go.mod  ./
RUN go mod download

# Copy the rest of the application code
COPY . .

# Build a statically linked binary
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# ---------- Runtime Stage ----------
FROM gcr.io/distroless/base

# Set working directory
WORKDIR /app

# Copy binary and static assets from builder stage
COPY --from=builder /app/main .
COPY --from=builder /app/static ./static

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["./main"]
