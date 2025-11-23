# ----------- STAGE 1: Dependencies -----------
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

# ----------- STAGE 2: Runtime -----------
FROM node:20-alpine
WORKDIR /app

# Copy only necessary parts
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Copy healthcheck script BEFORE switching user
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

# Create app user
RUN addgroup -S app && adduser -S -G app app

# Switch user now
USER app

EXPOSE 3000
CMD ["node", "src/index.js"]

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD /usr/local/bin/healthcheck.sh
