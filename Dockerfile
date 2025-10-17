# --- Stage 1: Build the application ---
FROM rust:1.85 as builder

WORKDIR /usr/src/app

# Copy manifests
COPY Cargo.toml Cargo.lock ./

# Build ONLY dependencies using a dummy project.
# The dummy main.rs is now empty, as it's just for compilation.
RUN mkdir src
RUN echo "fn main() {}" > src/main.rs
RUN cargo build --release

# Now, copy your actual source code. This invalidates the cache for the next step.
COPY ./src ./src

# Build the actual application. This will reuse the cached dependencies and be much faster.
RUN cargo build --release

# --- Stage 2: Create the final, minimal image ---
FROM debian:bookworm-slim

# Copy the final, correct binary from the builder stage.
# Make sure 'netzkarte-backend' matches your package name in Cargo.toml.
COPY --from=builder /usr/src/app/target/release/netzkarte-backend /usr/local/bin/netzkarte-backend

# Set the command to run your application
CMD ["/usr/local/bin/netzkarte-backend"]
