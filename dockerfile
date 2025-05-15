# Use an official Node.js runtime as a parent image
FROM node:16-slim

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port that Cloud Run will use
EXPOSE 8080

# Start the app (make sure this matches the way your app starts)
CMD ["npm", "start"]
