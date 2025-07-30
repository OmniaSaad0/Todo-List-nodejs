
# Stage 1: Build dependencies
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .


EXPOSE 4000
ENV PORT=4000

CMD ["index.js"]


