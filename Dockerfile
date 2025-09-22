# ---- Build stage ----
FROM node:20-alpine AS build
WORKDIR /app

# Nur das Nötigste kopieren für besseren Cache
COPY package.json package-lock.json* ./
RUN npm ci --include=dev

# Rest des Projekts
COPY . .
# Falls du ENV brauchst (z.B. BASE_URL), hier setzen
# ENV BASE_URL=/ 
RUN npm run build

# ---- Serve stage ----
FROM nginx:alpine
# Healthcheck (optional)
HEALTHCHECK CMD wget -qO- http://127.0.0.1 || exit 1
# Astro baut standardmäßig nach /dist
COPY --from=build /app/dist /usr/share/nginx/html
# Expose (Dokku/Compose nutzen Host-Mapping)
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
