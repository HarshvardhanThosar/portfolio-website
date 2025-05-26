# Use official Node.js image as the base
FROM node:20-alpine AS base

# Set working directory
WORKDIR /app

# Install dependencies separately for better caching
COPY package.json package-lock.json* pnpm-lock.yaml* ./
RUN npm install

# Copy rest of the application code
COPY . .

# Build the application for production
RUN npm run build

# Production image
FROM node:20-alpine AS runner

# Set working directory
WORKDIR /app

# Copy only the build output and necessary files
COPY --from=base /app/public ./public
COPY --from=base /app/.next ./.next
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app/package.json ./package.json

# Set environment variable for production
ENV NODE_ENV=production

# Expose port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]