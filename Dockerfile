# Base image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create and set work directory with proper permissions
RUN mkdir -p /app/templates /app/static && \
    chmod -R 755 /app
WORKDIR /app

# Install dependencies
COPY requirements.txt /app/
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy project files
COPY . /app/

# Debug: List contents
RUN echo "Contents of /app:" && \
    ls -la /app && \
    echo "Contents of /app/templates:" && \
    ls -la /app/templates

# Ensure proper permissions
RUN chown -R root:root /app && \
    chmod -R 755 /app

# Expose the port
EXPOSE 5000

# Set entrypoint with explicit directory
CMD ["python", "-u", "/app/app.py"] 