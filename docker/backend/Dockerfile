# ────────────────────────────────────────────────────────────
# Backend Dockerfile – Multi-stage build
# ────────────────────────────────────────────────────────────

# ── Stage 1: Base ────────────────────────────────────────────
FROM node:22-alpine AS base
WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Copy package files
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# ── Stage 2: Development ─────────────────────────────────────
FROM base AS development
ENV NODE_ENV=development
# Install dev dependencies too
COPY package*.json ./
RUN npm ci && npm cache clean --force

# Copy source
COPY . .

# Create logs directory
RUN mkdir -p logs

EXPOSE 3000 3001 9229

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "run", "dev"]

# ── Stage 3: Production ──────────────────────────────────────
FROM base AS production
ENV NODE_ENV=production

# Copy source (only what's needed)
COPY --chown=node:node src/ ./src/
COPY --chown=node:node .env.example ./.env.example

# Create logs dir with proper permissions
RUN mkdir -p logs && chown -R node:node /app

# Use non-root user
USER node

EXPOSE 3000 3001

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "src/app.js"]
