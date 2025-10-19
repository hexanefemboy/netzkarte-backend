# --- Stage 1: Build a statically-linked application ---
FROM rust:1.85 as builder

# Install the MUSL C compiler toolchain
RUN apt-get update && apt-get install -y musl-tools

# Install the MUSL target for static compilation
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/app

# Copy your manifests
COPY Cargo.toml Cargo.lock ./

# Copy your actual source code
COPY src ./src

# Build the application. This is the only build step.
RUN cargo build --target x86_64-unknown-linux-musl --release

# --- Stage 2: Create the final, minimal image ---
FROM scratch

# Copy the compiled binary from the builder stage.
# IMPORTANT: 'netzkarte-backend' must match the name in your Cargo.toml
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/netzkarte-backend /netzkarte-backend

# Set the command to run your application
CMD ["/netzkarte-backend"]
