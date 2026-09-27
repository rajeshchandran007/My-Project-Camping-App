# 1. Use the official Node 24 lightweight Alpine runtime image
FROM node:24-alpine

# 2. Set the working directory inside the container
WORKDIR /app

# 3. Copy application package definition files
COPY package*.json ./

# 4. Run a clean install for dependencies
#RUN npm ci --only=production
RUN npm install

# 5. Copy the rest of the project source files
COPY . .

# 6. Expose the port your Camping App listens on
EXPOSE 3000

# 7. Start the application
CMD ["npm", "start"]
