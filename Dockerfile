# Use official Python runtime
FROM python:3.14.6-slim

# Prevent Python from writing .pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# Prevent Python output buffering
ENV PYTHONUNBUFFERED=1

# Create working directory
WORKDIR /app

# Copy dependency file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Application Port
EXPOSE 5000

# Start Flask application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]