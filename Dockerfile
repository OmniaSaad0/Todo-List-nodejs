# # Use specific Node.js version for reproducible builds and security
# FROM node:18.19-alpine3.18

# # Set working directory
# WORKDIR /app

# # Install security updates and create non-root user in a single layer
# RUN apk add --no-cache --update libc6-compat && \
#     rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# # Copy package files first for better layer caching
# COPY --chown=node:node package.json package-lock.json* ./

# # Install dependencies with security best practices
# RUN npm ci --only=production --audit=false --fund=false --loglevel=error && \
#     npm cache clean --force && \
#     # Remove npm cache and temporary files
#     rm -rf ~/.npm /tmp/* /var/tmp/*

# # Copy application code with proper ownership
# COPY --chown=node:node . .

# # Create necessary directories with proper permissions
# RUN mkdir -p /app/logs /app/tmp && \
#     chown -R node:node /app && \
#     chmod -R 755 /app

# # Switch to non-root user for security
# USER node

# # Expose port
# EXPOSE 4000

# # Set environment variables with security defaults
# ENV NODE_ENV=production \
#     PORT=4000 \
#     NODE_OPTIONS="--max-old-space-size=512" \
#     # Security: Disable source maps in production
#     GENERATE_SOURCEMAP=false \
#     # Security: Set proper umask
#     UMASK=0022

# # Security: Set proper file permissions
# RUN umask 0022

# # Health check with security considerations
# HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
#   CMD node -e "require('http').get('http://localhost:4000', (res) => { \
#     process.exit(res.statusCode === 200 ? 0 : 1) \
#   }).on('error', () => process.exit(1)).setTimeout(5000)" || exit 1

# # Security: Use exec form for CMD
# CMD ["node", "--max-old-space-size=512", "index.js"] 

# ------------------------------------------------------------

# # Use official Node.js LTS image as base
# FROM node:18-alpine

# # Set working directory inside container
# WORKDIR /app

# # Copy only package.json and package-lock.json first for caching
# COPY package*.json ./

# # Install dependencies
# RUN npm install && \
#     npm cache clean --force && \
#     rm -rf ~/.npm /tmp/* /var/tmp/*

# # Copy the rest of the app files
# COPY . .

# # Expose the port the app runs on
# EXPOSE 4000

# # Define environment variable for port
# ENV PORT=4000

# # Start the app
# CMD ["npm", "start"]

# -----------------------------------------

# Stage 1: Build dependencies
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

# # Stage 2: Use distroless (no shell, no package manager, just app)
# FROM gcr.io/distroless/nodejs18-debian11

# WORKDIR /app
# COPY --from=builder /app .

EXPOSE 4000
ENV PORT=4000

CMD ["index.js"]

#  ----------------------------------------------------

# # Stage 1: Build app
# FROM node:18-alpine AS builder

# WORKDIR /app
# COPY package*.json ./
# RUN npm ci && npm prune --production
# COPY . .

# # Stage 2: Use minimal distroless
# FROM gcr.io/distroless/nodejs18:nonroot

# WORKDIR /app
# COPY --from=builder /app .

# EXPOSE 4000
# ENV PORT=4000

# # Must use absolute path to entry point
# CMD ["index.js"]


