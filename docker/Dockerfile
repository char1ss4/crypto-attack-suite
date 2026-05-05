FROM ghcr.io/foundry-rs/foundry:latest

# Switching to root permissions to install packages
USER root

# Install Python
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project in
COPY . .

# Expose Anvil's default port
EXPOSE 8545

# Start Anvil when container runs
CMD ["anvil", "--host", "0.0.0.0", "--chain-id", "1337"]