# ---------- base ----------
FROM node:20-alpine

# native build tools and pnpm shim
RUN apk add --no-cache git python3 make g++ \
 && corepack enable \
 && corepack prepare pnpm@latest --activate   # pin a version if you like

WORKDIR /usr/src/app
COPY . .

# monorepo deps
RUN pnpm install --frozen-lockfile

# the website build expects ./doc.json
RUN pnpm run jsdoc-json

# Astro dev port
EXPOSE 4321

# launch Strudel’s dev server on 0.0.0.0 so Docker can publish it
CMD ["pnpm", "--filter", "./website", "run", "dev", "--", "--host", "0.0.0.0", "--port", "4321"]
