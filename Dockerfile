FROM node:22-alpine

WORKDIR /app
ARG NODE_ENV=staging
ENV NODE_ENV=${NODE_ENV}

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY src ./src
COPY migrations ./migrations
COPY uploads/.gitkeep ./uploads/.gitkeep

EXPOSE 3000
CMD ["node", "src/index.js"]
