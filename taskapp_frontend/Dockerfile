# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Serve stage
FROM nginx:alpine
# Copy built files to NGINX HTML directory
COPY --from=build /app/dist /usr/share/nginx/html
# Setup custom NGINX config if needed (we'll just use default for now, or fallback config)
COPY nginx-production.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
