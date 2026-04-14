# ===== Stage 1: Build the BongoScript transpiler =====
FROM gcc:latest AS builder

RUN apt-get update && apt-get install -y \
    flex \
    bison \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Copy only the files needed for building the transpiler
COPY lexer.l parser.y ./

# Build: Bison → Flex → GCC
RUN bison -d parser.y \
    && flex lexer.l \
    && gcc parser.tab.c lex.yy.c -o banglish

# ===== Stage 2: Production image =====
FROM node:20-slim

# Install GCC for compiling generated C code at runtime
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json ./
RUN npm ci --production

# Copy the built transpiler from stage 1
COPY --from=builder /build/banglish ./banglish
RUN chmod +x ./banglish

# Copy application files
COPY server.js ./
COPY index.html about.html team.html favicon.png ./

# Railway provides PORT env variable
ENV PORT=3000

EXPOSE 3000

CMD ["node", "server.js"]
