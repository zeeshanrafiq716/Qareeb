FROM node:22-alpine

WORKDIR /app
ENV NODE_ENV=staging

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY src ./src
COPY migrations ./migrations
COPY uploads/.gitkeep ./uploads/.gitkeep

EXPOSE 3000
CMD ["node", "src/index.js"]
