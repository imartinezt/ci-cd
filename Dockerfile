# Use an official Python base image compatible with ARM architecture
FROM python:3.11-slim

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all other files
COPY . .
COPY keys.json /app/keys.json
COPY pro.json /app/pro.json

# Expose the port
EXPOSE 9819

# Run the application using uvicorn
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "9819"]
