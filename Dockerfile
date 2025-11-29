# ESP-IDF v5.5.1 Development Environment
FROM espressif/idf:v5.5.1

# Install additional useful tools
RUN apt-get update && apt-get install -y \
    git \
    vim \
    nano \
    curl \
    wget \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /workspace

# Create non-root user for development (optional but recommended for security)
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} espuser || true && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash espuser || true

# Ensure the workspace directory is writable
RUN chown -R ${USER_ID}:${GROUP_ID} /workspace || true

# Keep container running and allow interactive shell
CMD ["/bin/bash"]

