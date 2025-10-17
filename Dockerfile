# --- Stage 1: Build the application ---
# Use the official Rust image as a builder
FROM rust:1.79 as builder

# Create a new empty workspace
WORKDIR /usr/src/app

# Copy over your manifests
COPY Cargo.toml Cargo.lock ./

# This build step will cache your dependencies
RUN mkdir src/
RUN echo "fn main() {println!(\"dummy build\")}" > src/main.rs
RUN cargo build --release
RUN rm -f target/release/deps/my_api*

# Copy your actual source code
COPY src ./src

# Build the application for release
RUN cargo build --release

# --- Stage 2: Create the final, minimal image ---
# Use a slim Debian image for a small footprint
FROM debian:bullseye-slim

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/app/target/release/netzkarte-backend /usr/local/bin/netzkarte-backend

# Set the command to run your application
# The server will listen on 0.0.0.0 to be accessible from outside the container
CMD ["/usr/local/bin/netzkarte-backend"]
