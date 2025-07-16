# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Install Python
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean

# Create app directory
WORKDIR /app

# Copy server script into container
COPY python_http_server.py .

# Expose the server port
EXPOSE 8000

# Run the server
CMD ["python3", "python_http_server.py"]
