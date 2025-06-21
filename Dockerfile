# --- Build Stage (common for all target operating systems) ---
# Use an official Go image as the builder.
FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS builder

# Set build-time arguments for target OS and architecture.
# These will be passed in during the 'docker build' command.
ARG TARGETOS
ARG TARGETARCH

# Set the working directory inside the container.
WORKDIR /app

# Copy the Go module files.
COPY go.mod ./

# Download dependencies using a cache mount for efficiency.
RUN --mount=type=cache,target=/go/pkg/mod go mod download

# Copy the rest of the application's source code.
COPY *.go ./

# Build the application.
# The output is a static binary named 'main' in the /app directory.
# The GOOS and GOARCH variables allow for cross-compilation.
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-w -s" -v -o /app/main .

# --- Final Stage for Linux ---
# This stage builds the final image for a Linux target.
FROM --platform=linux/${TARGETARCH} gcr.io/distroless/static-debian12

WORKDIR /

# Copy the compiled binary from the 'builder' stage.
COPY --from=builder /app/main /main

# Expose the application port.
EXPOSE 8080

# Set labels
LABEL org.opencontainers.image.source=https://github.com/gawbul/kubernetes-example-application
LABEL org.opencontainers.image.description="Kubernetes Example Application"
LABEL org.opencontainers.image.title="Kubernetes Example Application"

# Set the command to run when the container starts.
CMD ["/main"]
