FROM ghcr.io/foundry-rs/foundry:latest

# Install Python
RUN apk add --no-cache python3 py3-pip

# Set working directory
WORKDIR /app

# Copy project in
COPY . .

# Expose Anvil's default port
EXPOSE 8545

# Start Anvil when container runs
CMD ["anvil", "--host", "0.0.0.0", "--chain-id", "1337"]