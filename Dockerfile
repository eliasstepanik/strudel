# ---------- build stage ----------
FROM node:20-alpine AS builder

# pnpm is the package manager used by Strudel
RUN corepack enable && npm install -g pnpm  # corepack ships with Node 20 :contentReference[oaicite:0]{index=0}

# native deps needed for sharp and other Astro plugins to compile on Alpine Linux :contentReference[oaicite:1]{index=1}
RUN apk add --no-cache git python3 make g++

WORKDIR /app
COPY . .

# deterministic install & build
RUN pnpm install --frozen-lockfile  # workspace root uses pnpm :contentReference[oaicite:2]{index=2}
RUN pnpm build                     # produces website/dist (Astro default) :contentReference[oaicite:3]{index=3}

# ---------- runtime stage ----------
FROM nginx:alpine
LABEL org.opencontainers.image.source="https://github.com/tidalcycles/strudel"

# copy the static site produced above
COPY --from=builder /app/website/dist /usr/share/nginx/html

EXPOSE 80
HEALTHCHECK CMD wget -qO- http://localhost/ || exit 1
CMD ["nginx","-g","daemon off;"]
