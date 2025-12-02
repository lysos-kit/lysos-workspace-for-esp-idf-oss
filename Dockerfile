# ESP-IDF Development Environment
ARG ESPIDF_IMAGE_VERSION=v5.5.1
FROM espressif/idf:${ESPIDF_IMAGE_VERSION}

RUN echo "Using ESP-IDF version ${ESPIDF_IMAGE_VERSION}"

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

# Set up ESP-IDF environment for root user (for interactive shells)
RUN echo '. /opt/esp/idf/export.sh > /dev/null 2>&1' >> /root/.bashrc

# Allow git to access the workspace directory
RUN git config --system --add safe.directory /workspace

# Keep container running and allow interactive shell
CMD ["/bin/bash"]

