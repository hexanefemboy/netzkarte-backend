# --- Stage 1: Build a statically-linked application ---
FROM rust:1.85 as builder

# Install the MUSL C compiler toolchain
RUN apt-get update && apt-get install -y musl-tools

# Install the MUSL target for static compilation
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/app

# Create a dummy project to cache dependencies for the MUSL target
RUN cargo new --bin dummy
WORKDIR /usr/src/app/dummy

# Copy manifests from the build context root into the dummy directory
COPY ../Cargo.toml ../Cargo.lock ./
# Build dependencies
RUN cargo build --target x86_64-unknown-linux-musl --release

# --- THIS IS THE FIX ---
# Copy your actual source code from the build context root, overwriting the dummy files.
COPY ../src ./src
# ---------------------

# Build the real application. This will be fast because dependencies are cached.
RUN cargo build --target x86_64-unknown-linux-musl --release

# --- Stage 2: Create the final, minimal image ---
FROM scratch

# Copy the final, correct binary from the builder stage.
# Make sure 'netzkarte-backend' matches your package name in Cargo.toml.
COPY --from=builder /usr/src/app/dummy/target/x86_64-unknown-linux-musl/release/netzkarte-backend /netzkarte-backend

# Set the command to run your application
CMD ["/netzkarte-backend"]
