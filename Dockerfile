# Base image with Corepack → pnpm already included
FROM node:20-alpine

# Build-time tools needed by some native deps
RUN apk add --no-cache git python3 make g++ \
    && corepack enable \
    && corepack prepare pnpm@latest --activate   # pin if you prefer

WORKDIR /usr/src/app
COPY . .

# 1. install monorepo deps
RUN pnpm install --frozen-lockfile

# 2. generate docs once – JsDoc.jsx expects this file
RUN pnpm run jsdoc-json      # produces ./doc.json :contentReference[oaicite:0]{index=0}

# Expose Astro’s default dev port
EXPOSE 4321    # default per Astro docs :contentReference[oaicite:1]{index=1}

# 3. launch the dev server, listen on all interfaces
CMD ["pnpm", "dev", "--", "--host", "0.0.0.0", "--port", "4321"]
