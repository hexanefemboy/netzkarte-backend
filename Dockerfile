# --- Stage 1: Build a statically-linked application ---
FROM rust:1.85 as builder

# --- THIS IS THE FIX ---
# Install the MUSL C compiler toolchain, which is needed by some dependencies.
RUN apt-get update && apt-get install -y musl-tools
# ---------------------

# Install the MUSL target for static compilation
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/app

# Create a dummy project to cache dependencies for the MUSL target
RUN cargo new --bin dummy
WORKDIR /usr/src/app/dummy
COPY ../Cargo.toml ../Cargo.lock ./
RUN cargo build --target x86_64-unknown-linux-musl --release

# Copy your actual source code
COPY ./src ./src

# Build the real application as a statically linked binary
RUN cargo build --target x86_64-unknown-linux-musl --release

# --- Stage 2: Create the final, minimal image ---
FROM scratch

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/app/dummy/target/x86_64-unknown-linux-musl/release/netzkarte-backend /netzkarte-backend

# Set the command to run your application
CMD ["/netzkarte-backend"]
