# --- Stage 1: Build a statically-linked application ---
FROM rust:1.85 as builder

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
# This will be fast because dependencies are cached
RUN cargo build --target x86_64-unknown-linux-musl --release

# --- Stage 2: Create the final, minimal image ---
# We can use the 'scratch' image because the binary is fully self-contained
FROM scratch

# Copy the compiled binary from the builder stage
# Note the different path for the MUSL target
COPY --from=builder /usr/src/app/dummy/target/x86_64-unknown-linux-musl/release/netzkarte-backend /netzkarte-backend

# Set the command to run your application
CMD ["/netzkarte-backend"]

